# Demo Success Screenshot Placeholder

## Purpose
This file serves as a placeholder for `demo_trace.png` - the success screenshot showing the validation pass result.

## How to Generate

1. Run the demo script:
   ```bash
   ./scripts/demo.sh
   ```

2. Wait for STEP 3 to complete (green ✅ success message)

3. Capture screenshot showing:
   - Terminal with green success message
   - "✅ STEP 3 Complete: All validations passed!"
   - List of generated artifacts
   - Duration confirmation (< 10 minutes)

4. Save as `assets/demo_trace.png`

5. Delete this placeholder file

## Screenshot Specs

- **Format**: PNG
- **Resolution**: 1920×1080 or 1280×720
- **Focus**: Terminal output showing success
- **Crop**: Remove unnecessary terminal chrome
- **Timing**: Capture at 00:35 mark (per demo-outline.md)

## Expected Content

```
✅ STEP 3 Complete: All validations passed!

📊 Generated Artifacts:
  📄 reports/demo-fail-report.html  (FAIL scenario)
  📄 reports/demo-pass-report.html  (PASS scenario)
  📄 assets/demo-incomplete.trace.json
  📄 assets/demo-complete.trace.json
  📄 contracts/flows/demo-flow.flowspec.yaml

✓ Duration: < 10 minutes
✓ Steps: 3 (Setup → Fail → Pass)
✓ Reproducible: ✅
```

## Alternative: Auto-generate

If running in CI or headless environment, this placeholder documents what the screenshot should contain for manual capture later.

---

**Note**: This is a documentation placeholder. Replace with actual screenshot after running `./scripts/demo.sh`.