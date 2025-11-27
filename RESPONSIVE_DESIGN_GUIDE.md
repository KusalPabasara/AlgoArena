# Material Design 3 Responsive Design System

## Overview

This document outlines the responsive design system implemented in the Leo Connect app to ensure **universal compatibility** across all Android devices from small phones to tablets.

**Reference Design:** Pixel 9 Pro (412 x 915 dp)

---

## 📱 Device Support Matrix

| Device Category | Screen Width | Scale Factor |
|-----------------|--------------|--------------|
| Small Phones    | < 360dp      | 0.75 - 0.87  |
| Normal Phones   | 360-400dp    | 0.87 - 0.97  |
| Large Phones    | 400-600dp    | 0.97 - 1.35  |
| Tablets         | ≥ 600dp      | 1.0 - 1.35   |

---

## 🎯 Material Design 3 Standards

### Input Field Dimensions

| Property | M3 Standard | Implementation |
|----------|-------------|----------------|
| Height | 56dp | `ResponsiveUtils.inputHeight` |
| Touch Target | 48dp min | `ResponsiveUtils.minTouchTarget` |
| Corner Radius | 4-8dp | `ResponsiveUtils.inputRadius` |
| Border (Normal) | 1dp | `M3DesignSystem.inputBorderNormal` |
| Border (Focused) | 2dp | `M3DesignSystem.inputBorderFocused` |

### Input Field Padding

| Location | Size |
|----------|------|
| Start/End | 16dp (`spacingM`) |
| Top/Bottom | 12dp |
| Icon to Text | 8dp (`spacingS`) |

### Typography (SP units)

| Element | Size | Weight | Usage |
|---------|------|--------|-------|
| Display Large | 57sp | 400 | Hero text |
| Display Medium | 45sp | 400 | Large titles |
| Display Small | 36sp | 400 | Section headers |
| Headline Large | 32sp | 400 | Page titles |
| Headline Medium | 28sp | 400 | Subtitles |
| Headline Small | 24sp | 400 | Cards |
| Title Large | 22sp | 500 | Dialog titles |
| Title Medium | 16sp | 500 | List items |
| Title Small | 14sp | 500 | Tabs |
| **Body Large** | **16sp** | 400 | **Input text** |
| Body Medium | 14sp | 400 | Body text |
| **Body Small** | **12sp** | 400 | **Helper/Error text** |
| Label Large | 14sp | 500 | Buttons |
| Label Medium | 12sp | 500 | Floating label |
| Label Small | 11sp | 500 | Captions |

### Spacing

| Size | Value | Usage |
|------|-------|-------|
| XS | 4dp | Icon padding, small gaps |
| S | 8dp | Between related items |
| M | 16dp | Between input fields |
| L | 24dp | Between input and button |
| XL | 32dp | Between sections |
| XXL | 48dp | Large sections |

### Icons

| Type | Size |
|------|------|
| Standard | 24dp |
| Small (clear) | 20dp |
| Large | 32dp |

### Buttons

| Property | Value |
|----------|-------|
| Height (Prominent) | 56dp |
| Height (Standard) | 40dp |
| Corner Radius | 28dp (pill) |
| Padding Horizontal | 24dp |

---

## 🛠 Usage Guide

### Initializing ResponsiveUtils

Always initialize in your `build()` method:

```dart
@override
Widget build(BuildContext context) {
  ResponsiveUtils.init(context);
  
  return Scaffold(
    // Your content
  );
}
```

### Using Responsive Values

```dart
// Font sizes (SP)
Text(
  'Hello',
  style: TextStyle(
    fontSize: ResponsiveUtils.bodyLarge, // 16sp scaled
  ),
);

// Spacing (DP)
SizedBox(height: ResponsiveUtils.spacingM), // 16dp scaled

// Input height
SizedBox(
  height: ResponsiveUtils.inputHeight, // 56dp scaled
  child: TextField(...),
);

// Adaptive padding
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: ResponsiveUtils.adaptiveHorizontalPadding,
  ),
  child: ...
);
```

### Extension Methods

```dart
// Using extensions on num
16.sp  // Scaled font size
24.dp  // Scaled dimension
50.w   // 50% of screen width
30.h   // 30% of screen height
```

---

## 📐 Layout Guidelines

### Making Scrollable Content

Always wrap content in `SingleChildScrollView` with `ConstrainedBox`:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    ResponsiveUtils.init(context);
    
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: Column(
          children: [...],
        ),
      ),
    );
  },
);
```

### Preventing Overflow

1. **Use `Flexible` or `Expanded`** for items that should shrink
2. **Use `SingleChildScrollView`** for content that might exceed screen
3. **Use percentage heights** carefully (prefer `LayoutBuilder`)
4. **Use `ConstrainedBox`** to set min/max dimensions

### Adaptive Padding

```dart
// Automatic padding based on device size
EdgeInsets.symmetric(
  horizontal: ResponsiveUtils.adaptiveHorizontalPadding,
  // Small phones: 16dp
  // Normal phones: 24dp  
  // Tablets: 32dp
)
```

---

## 🎨 Input Field States

### State Colors

| State | Border | Label | Background |
|-------|--------|-------|------------|
| Normal | #79747E (1dp) | #49454F | Transparent |
| Focused | #6750A4 (2dp) | #6750A4 | Transparent |
| Error | #B3261E (2dp) | #B3261E | Transparent |
| Disabled | #1F1C1B1F (1dp) | 38% opacity | Light grey |

### Dark Background Colors (Auth Screens)

| Property | Value |
|----------|-------|
| Fill Color | Black 40% opacity |
| Text Color | White |
| Hint Color | #D2D2D2 |
| Border | None |
| Icon Color | White 70% |

---

## ⌨️ Keyboard Responsiveness

### Scaffold Configuration

All screens with input fields MUST have:

```dart
Scaffold(
  resizeToAvoidBottomInset: true,  // REQUIRED
  body: ...
)
```

### SingleChildScrollView Configuration

```dart
SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  physics: const ClampingScrollPhysics(),
  child: ...
)
```

### Keyboard Utilities

```dart
// Check if keyboard is visible
if (ResponsiveUtils.isKeyboardVisible(context)) {
  // Handle keyboard state
}

// Get keyboard height
final keyboardHeight = ResponsiveUtils.keyboardHeight(context);

// Get available height (minus keyboard)
final availableHeight = ResponsiveUtils.availableHeight(context);

// Add bottom padding when keyboard is visible
padding: EdgeInsets.only(
  bottom: ResponsiveUtils.keyboardBottomPadding(context),
)
```

### KeyboardAwareWrapper Widget

For complex layouts, use the `KeyboardAwareWrapper`:

```dart
import 'package:algoarena_app/presentation/widgets/keyboard_aware_wrapper.dart';

KeyboardAwareWrapper(
  child: Column(
    children: [
      TextField(...),
      TextField(...),
      ElevatedButton(...),
    ],
  ),
)
```

### Text Field Scroll Padding

All text fields should have `scrollPadding` to ensure visibility:

```dart
TextFormField(
  scrollPadding: const EdgeInsets.all(100.0),  // Ensures field is visible
  ...
)
```

---

## 📝 Files Structure

```
lib/
├── utils/
│   ├── responsive_utils.dart     # Core responsive utilities
│   ├── m3_design_system.dart     # M3 constants & tokens
│   └── app_constants.dart        # App-wide constants
├── presentation/
│   └── widgets/
│       ├── m3_text_field.dart    # M3 compliant TextField
│       └── responsive_widgets.dart # Responsive helper widgets
```

---

## ✅ Checklist for New Screens

- [ ] Initialize `ResponsiveUtils.init(context)` in build method
- [ ] Use `ResponsiveUtils.sp()` for all font sizes
- [ ] Use `ResponsiveUtils.dp()` for dimensions
- [ ] Use `ResponsiveUtils.inputHeight` for text fields
- [ ] Use `ResponsiveUtils.buttonHeight` for buttons
- [ ] Wrap in `SingleChildScrollView` if content might overflow
- [ ] Use `LayoutBuilder` for adaptive layouts
- [ ] Test on small phone (320dp) and tablet (600dp+)

---

## 🔧 Build Commands

```bash
# Development build
flutter build apk --debug

# Release build (optimized)
flutter build apk --release

# Build for specific ABIs
flutter build apk --release --split-per-abi
```

---

**Created:** November 2025
**Material Design Version:** 3.0
**Flutter Version:** 3.x
