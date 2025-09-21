#!/usr/bin/env python3
"""
ChoreoAtlas Quickstart — Trace Converter (Jaeger/OTLP JSON -> CE internal format)

Usage:
  python3 scripts/convert-trace.py input.json -o output.trace.json [--map demo|--map-file mapping.json]

Notes:
  - Jaeger JSON: expects spans[*].operationName, spans[*].process.serviceName, startTime/duration (microseconds), tags map.
  - OTLP JSON: expects resourceSpans[].scopeSpans[].spans[] with startTimeUnixNano/endTimeUnixNano and attributes list.
  - Operation name mapping:
      * --map demo: apply built-in mapping for the Sock Shop endpoints to match the demo ServiceSpec names.
      * --map-file: JSON mapping file, e.g. {"payment POST /paymentAuth": "authorizePayment"}.
  - Response body heuristics: when possible, derive minimal response.body from log fields (demo-focused heuristics).
"""

import argparse
import json
import sys
from typing import Any, Dict, List, Optional


def load_json(path: str) -> Any:
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_json(path: str, obj: Any) -> None:
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)


def to_int(x: Any, default: int = 0) -> int:
    try:
        return int(x)
    except Exception:
        return default


def camelize(segment: str) -> str:
    s = ''.join(ch for ch in segment if ch.isalnum())
    if not s:
        return ''
    return s[0].upper() + s[1:]


def derive_name_from_method_path(method: str, path: str) -> str:
    method = (method or '').strip().upper()
    norm_path = (path or '').strip()
    if not norm_path:
        return method.lower() or 'op'
    # choose last non-empty segment
    parts = [p for p in norm_path.split('/') if p and not p.startswith('{')]
    last = parts[-1] if parts else 'op'
    base = camelize(last)
    # heuristic verbs
    verb = {
        'GET': 'get',
        'POST': 'create',
        'PUT': 'update',
        'PATCH': 'patch',
        'DELETE': 'delete',
    }.get(method, method.lower())
    return f"{verb}{base}"


def apply_demo_mapping(service: str, method: str, path: str, op_name: str) -> str:
    key = f"{service.strip().lower()} {method.strip().upper()} {path.strip()}".strip()
    demo_map = {
        'catalogue GET /catalogue': 'getCatalogue',
        'cart POST /carts/{id}': 'addToCart',
        'orders POST /orders': 'createOrder',
        'payment POST /paymentAuth': 'authorizePayment',
        'shipping POST /shipping': 'createShipment',
    }
    return demo_map.get(key, op_name)


def apply_custom_mapping(mapping: Dict[str, str], service: str, method: str, path: str, op_name: str) -> str:
    key = f"{service.strip()} {method.strip().upper()} {path.strip()}"
    return mapping.get(key, op_name)


def jaeger_to_internal(data: Dict[str, Any], mapping_kind: str, mapping_file: Optional[str]) -> Dict[str, Any]:
    # optional mapping file
    custom_map: Dict[str, str] = {}
    if mapping_file:
        try:
            custom_map = load_json(mapping_file)
        except Exception:
            custom_map = {}

    spans_out: List[Dict[str, Any]] = []
    spans = data.get('spans') or []
    for sp in spans:
        service = (
            (sp.get('process') or {}).get('serviceName')
            or (sp.get('process', {}).get('service'))
            or 'unknown-service'
        )
        op_name = sp.get('operationName') or ''

        # derive method/path from operationName when possible
        method = ''
        path = ''
        if op_name:
            parts = op_name.split(' ', 1)
            if len(parts) == 2 and parts[0].isalpha():
                method = parts[0]
                path = parts[1]

        # tags
        tags = sp.get('tags') or {}
        http_status = tags.get('http.status_code')
        url = tags.get('http.url')
        if not path and isinstance(url, str):
            # fallback to URL path part
            try:
                path = '/' + url.split('://', 1)[-1].split('/', 1)[-1]
            except Exception:
                pass

        # derive operation id
        derived = derive_name_from_method_path(method, path)
        if mapping_kind == 'demo':
            derived = apply_demo_mapping(service, method, path, derived)
        if custom_map:
            derived = apply_custom_mapping(custom_map, service, method, path, derived)

        start_us = to_int(sp.get('startTime'), 0)
        dur_us = to_int(sp.get('duration'), 0)
        start_ns = start_us * 1000
        end_ns = (start_us + dur_us) * 1000 if dur_us else start_ns

        attributes: Dict[str, Any] = {}
        if http_status is not None:
            attributes['http.status_code'] = http_status

        # demo-focused heuristics from logs -> response.body
        body: Dict[str, Any] = {}
        for log in sp.get('logs') or []:
            fields = log.get('fields') or {}
            ev = fields.get('event') or ''
            if ev == 'order.created':
                if 'order_id' in fields:
                    body.setdefault('id', fields['order_id'])
            if ev == 'payment.authorized':
                body['authorised'] = True
                if 'authorization_id' in fields:
                    body['authorizationID'] = fields['authorization_id']
            if ev == 'shipment.created':
                if 'tracking_number' in fields:
                    body['trackingNumber'] = fields['tracking_number']
            if ev == 'item.added':
                if 'item_id' in fields:
                    body['itemID'] = fields['item_id']
                if 'quantity' in fields:
                    body['quantity'] = fields['quantity']
        if body:
            attributes['response.body'] = body

        spans_out.append({
            'name': derived,
            'service': service,
            'startNanos': start_ns,
            'endNanos': end_ns,
            'attributes': attributes,
        })

    return {'spans': spans_out}


def otlp_to_internal(data: Dict[str, Any]) -> Dict[str, Any]:
    spans_out: List[Dict[str, Any]] = []
    for rs in data.get('resourceSpans', []):
        # service name from resource attributes
        service = 'unknown-service'
        for attr in (rs.get('resource') or {}).get('attributes', []):
            if attr.get('key') == 'service.name':
                v = attr.get('value', {}).get('stringValue')
                if v:
                    service = v
                    break
        for ss in rs.get('scopeSpans', []):
            for sp in ss.get('spans', []):
                name = sp.get('name') or ''
                start_ns = to_int(sp.get('startTimeUnixNano'), 0)
                end_ns = to_int(sp.get('endTimeUnixNano'), start_ns)
                attributes: Dict[str, Any] = {}
                for attr in sp.get('attributes', []):
                    key = attr.get('key')
                    val = attr.get('value') or {}
                    # pick one of available types
                    if 'stringValue' in val:
                        attributes[key] = val['stringValue']
                    elif 'intValue' in val:
                        try:
                            attributes[key] = int(val['intValue'])
                        except Exception:
                            attributes[key] = val['intValue']
                    elif 'doubleValue' in val:
                        try:
                            attributes[key] = float(val['doubleValue'])
                        except Exception:
                            attributes[key] = val['doubleValue']
                    elif 'boolValue' in val:
                        attributes[key] = bool(val['boolValue'])
                # normalize http status
                if 'http.status_code' in attributes:
                    pass
                elif 'response.status' in attributes:
                    attributes['http.status_code'] = attributes['response.status']

                spans_out.append({
                    'name': name,
                    'service': service,
                    'startNanos': start_ns,
                    'endNanos': end_ns,
                    'attributes': attributes,
                })
    return {'spans': spans_out}


def main():
    p = argparse.ArgumentParser(description='Convert Jaeger/OTLP JSON trace to CE internal format')
    p.add_argument('input', help='Input trace JSON path (Jaeger or OTLP JSON)')
    p.add_argument('-o', '--out', required=True, help='Output CE internal trace path (*.trace.json)')
    g = p.add_mutually_exclusive_group()
    g.add_argument('--map', choices=['demo'], help='Apply built-in mapping (demo) to derive operation names')
    g.add_argument('--map-file', help='Custom mapping JSON file: {"service METHOD /path": "operationId"}')
    args = p.parse_args()

    data = load_json(args.input)
    if isinstance(data, dict) and 'resourceSpans' in data:
        out = otlp_to_internal(data)
    elif isinstance(data, dict) and 'spans' in data and data['spans'] and isinstance(data['spans'][0], dict) and 'operationName' in data['spans'][0]:
        out = jaeger_to_internal(data, args.map or '', args.map_file)
    else:
        print('ERROR: Unrecognized input format. Expected OTLP resourceSpans or Jaeger spans[].operationName.', file=sys.stderr)
        sys.exit(2)

    save_json(args.out, out)
    print(f"✅ Converted: {args.input} -> {args.out}")
    print("   Hint: choreoatlas validate --flow contracts/flows/order-flow.graph.flowspec.yaml --trace", args.out)


if __name__ == '__main__':
    main()
