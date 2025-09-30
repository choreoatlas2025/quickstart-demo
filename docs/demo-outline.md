# ChoreoAtlas CLI Demo - 30-45 Second Recording Script

**Purpose**: Quick visual demo for README, 官网, 社媒复用
**Duration**: 30-45 seconds
**Flow**: Fail → Fix → Pass
**Target**: Developers, DevOps engineers, Technical decision-makers

---

## 🎬 Recording Setup

- **Resolution**: 1920×1080 (16:9) or 1280×720
- **Terminal**: Dark theme, large font (14-16pt)
- **Screen**: Clean desktop, close unnecessary windows
- **Audio**: Optional (can add voiceover or music in post)
- **Tool**: Screen recorder (QuickTime/OBS/Loom)

---

## 📝 Shot-by-Shot Storyboard (45 seconds)

### 00:00-00:05 | Shot 1: Title Card
**Visual**:
```
╔═══════════════════════════════════════════╗
║  ChoreoAtlas CLI Demo                     ║
║  Fail → Fix → Pass in 3 Steps             ║
╚═══════════════════════════════════════════╝
```

**Action**: Display title overlay or terminal banner
**Text Overlay**: "Contract-as-Code for Microservices"

---

### 00:05-00:15 | Shot 2: FAIL Scenario (10s)
**Command**:
```bash
$ ./scripts/demo.sh
```

**Visual Highlights**:
1. Script starts, shows "STEP 2/3: Validate (Fail)"
2. Terminal output shows validation running
3. **RED ❌ appears**: "Validation FAILED"
4. Error message: "Missing steps: payment.processPayment"

**Text Overlay**: "❌ Incomplete trace detected"

**Key Frame** (5 seconds in): Red failure message visible

---

### 00:15-00:30 | Shot 3: FIX Process (15s)
**Visual**:
1. Terminal shows "STEP 3/3: Fix & Re-validate"
2. Quick glimpse of complete trace being created:
   ```json
   {
     "steps": [
       "createOrder",
       "checkInventory",
       "processPayment",  ← NEW STEP ADDED
       "confirmOrder"
     ]
   }
   ```
3. Validation re-running with spinner/progress

**Text Overlay**: "✏️ Adding missing payment step"

**Transition**: Smooth fade from red terminal to green

---

### 00:30-00:40 | Shot 4: PASS Result (10s)
**Visual**:
1. **GREEN ✅ appears**: "Validation PASSED"
2. Terminal shows:
   ```
   ✅ STEP 3 Complete: All validations passed!

   📊 Generated Artifacts:
     ✓ reports/demo-pass-report.html
     ✓ Duration: < 10 minutes
     ✓ Reproducible: ✅
   ```
3. Browser window opens showing HTML report (optional)

**Text Overlay**: "✅ Choreography validated"

**Key Frame** (35 seconds in): Green success + report preview

---

### 00:40-00:45 | Shot 5: Call to Action (5s)
**Visual**:
```
╔═══════════════════════════════════════════╗
║  Try it yourself:                         ║
║  $ git clone choreoatlas2025/quickstart   ║
║  $ ./scripts/demo.sh                      ║
║                                           ║
║  🌐 choreoatlas.com                       ║
╚═══════════════════════════════════════════╝
```

**Text Overlay**:
- "Get Started: github.com/choreoatlas2025/quickstart-demo"
- "Learn More: choreoatlas.com"

---

## 🎨 Visual Style Guide

### Color Coding
- **RED (#FF6B6B)**: Failures, missing steps
- **GREEN (#51CF66)**: Success, validation passed
- **YELLOW (#FFD43B)**: In-progress, warnings
- **BLUE (#339AF0)**: Info, section headers

### Typography
- **Headers**: Bold, 18-20pt
- **Code**: Monospace (Fira Code, JetBrains Mono)
- **Overlays**: Sans-serif, high contrast

### Animations
- **Transitions**: 0.3s fade between shots
- **Text overlays**: Slide in from left (0.2s)
- **Terminal output**: Natural typing speed (not instant)

---

## 📸 Screenshot Capture Points

### For `assets/demo_trace.png`
**Timing**: 00:35 (Shot 4 - PASS Result)
**Content**:
- Terminal showing green ✅ success message
- List of generated artifacts
- Duration < 10 minutes confirmation

**Crop**: Focus on success message + artifact list (no unnecessary terminal chrome)

---

## 🎥 Alternative: 3 Separate Clips

For social media (Twitter/LinkedIn), split into 3 clips:

### Clip 1 (15s): "The Problem"
- Show FAIL scenario
- Text: "❌ Your microservices are out of sync"

### Clip 2 (15s): "The Solution"
- Show CLI validation in action
- Text: "🔍 ChoreoAtlas detects missing steps"

### Clip 3 (15s): "The Result"
- Show PASS after fix
- Text: "✅ Contract-as-Code keeps services aligned"

---

## 📋 Pre-Recording Checklist

- [ ] Clean terminal (clear history)
- [ ] Test `./scripts/demo.sh` runs successfully
- [ ] Terminal font size readable at 720p
- [ ] Dark theme with good contrast
- [ ] Screen recording software tested
- [ ] Demo runs in < 10 minutes (for editing flexibility)
- [ ] Generated reports exist in `reports/`

---

## 🎬 Post-Production Tips

1. **Speed up** long pauses (e.g., Docker pulls) to 2×
2. **Add** subtle background music (upbeat, tech-oriented)
3. **Highlight** key terminal lines with zoom/spotlight
4. **Export** multiple formats:
   - 1920×1080 (YouTube/Website)
   - 1280×720 (Twitter/LinkedIn)
   - 1080×1080 (Instagram)

---

## 📊 KPI Tracking

After publishing demo:

- **Video views**: Track on each platform
- **Click-through rate**: Monitor GitHub stars/clone rate spike
- **Reproducibility**: Track GitHub Issues mentioning "demo failed"
- **Engagement**: Comments, shares, likes

Target:
- Demo completion time: ≤ 10 minutes
- Steps: 3 (Setup → Fail → Pass)
- Reproducible: ≥ 95% success rate

---

## 🔗 Usage Context

- **README.md**: Embed as GIF (first 30s only)
- **Website**: Full 45s video with CTA button
- **Twitter/X**: 15s Clip 1 + 15s Clip 3
- **LinkedIn**: Full video with technical explanation
- **YouTube**: Full video + extended walkthrough

---

**Version**: 1.0
**Last Updated**: 2025-09-30
**Maintainer**: ChoreoAtlas Team