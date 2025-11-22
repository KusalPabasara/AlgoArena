# AlgoArena - Flutter Animation Implementation Guide

## Overview
This guide documents the Material Design animations implemented from Figma designs and provides patterns for implementing the remaining 71 designs.

## ✅ Implemented Screens with Animations

### 1. Splash Screen (`splash_screen.dart`)
**Animations:**
- Phase transitions (lion left → lion center + logo)
- Fade animations
- Pulsing dots at bottom
- Screen fade-out transition

**Animation Controllers:**
```dart
- _phase1Controller: Duration(milliseconds: 800)
- _phase2Controller: Duration(milliseconds: 1200)
- _dotsController: Duration(milliseconds: 1500) - repeating
- _transitionController: Duration(milliseconds: 600)
```

### 2. Login Screen (`login_screen.dart`)
**Animations:**
- Floating decorative bubbles (background)
- Material ripple effects on buttons
- Smooth transitions

**Features:**
- RadialGradient bubbles with opacity
- Material InkWell for touch feedback
- Social login buttons with icons

### 3. Register Screen (`register_screen.dart`)
**Animations:**
- Rotating bubble backgrounds
- Form field focus animations
- Checkbox animations
- Button press effects

**Features:**
- Decorative bubbles positioned as per Figma
- Material Design form fields
- Custom styled inputs

### 4. Notifications Screen (`notifications_screen.dart`)
**Animations:**
- Floating bubbles (20 second loop)
- Staggered list item animations
- Header slide-in animation
- Card entry animations
- Material ripple on taps

**Animation Pattern:**
```dart
// Staggered animation
final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(
    parent: _listController,
    curve: Interval(
      index * 0.08,  // Stagger delay
      index * 0.08 + 0.4,  // Duration
      curve: Curves.easeOut,
    ),
  ),
);
```

### 5. Pages/Clubs Screen (`pages_screen.dart`)
**Animations:**
- Floating bubbles with sin/cos motion
- Staggered card reveal (slide + fade)
- Hero animations for logos
- Material ripple effects
- Follow button state animations

**Material Widgets:**
- InkWell with custom ripple colors
- SnackBar with floating behavior
- Material elevation on cards

## 🎨 Animation Patterns & Techniques

### Pattern 1: Floating Bubbles
```dart
// In initState
_bubblesController = AnimationController(
  duration: const Duration(seconds: 20),
  vsync: this,
)..repeat();

// In build
AnimatedBuilder(
  animation: _bubblesController,
  builder: (context, child) {
    return Positioned(
      left: baseX + math.sin(_bubblesController.value * 2 * math.pi) * amplitude,
      top: baseY + math.cos(_bubblesController.value * 2 * math.pi) * amplitude,
      child: Transform.rotate(
        angle: _bubblesController.value * 2 * math.pi * rotationSpeed,
        child: Container(...),
      ),
    );
  },
)
```

### Pattern 2: Staggered List Animations
```dart
// Create intervals for each item
final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(
    parent: _listController,
    curve: Interval(
      index * 0.1,  // Delay increases per item
      index * 0.1 + 0.5,  // Animation duration
      curve: Curves.easeOut,
    ),
  ),
);

// Apply to widget
AnimatedBuilder(
  animation: animation,
  builder: (context, child) {
    return Transform.translate(
      offset: Offset(0, 30 * (1 - animation.value)),
      child: Opacity(
        opacity: animation.value,
        child: child,
      ),
    );
  },
  child: YourWidget(),
)
```

### Pattern 3: Hero Animations
```dart
// Wrap widget on source screen
Hero(
  tag: 'unique_id_${item.id}',
  child: YourWidget(),
)

// Same tag on destination screen
Hero(
  tag: 'unique_id_${item.id}',
  child: YourWidget(),
)
```

### Pattern 4: Material Ripple Effects
```dart
Material(
  color: backgroundColor,
  borderRadius: BorderRadius.circular(radius),
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(radius),
    splashColor: Colors.white.withOpacity(0.3),
    highlightColor: Colors.white.withOpacity(0.1),
    child: Container(...),
  ),
)
```

### Pattern 5: Slide-In Transitions
```dart
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(-1, 0),  // From left
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  )),
  child: YourWidget(),
)
```

### Pattern 6: Scale Animations
```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: const Duration(milliseconds: 400),
  curve: Curves.elasticOut,
  builder: (context, scale, child) {
    return Transform.scale(
      scale: scale,
      child: child,
    );
  },
  child: YourWidget(),
)
```

## 📋 Remaining Screens to Implement

### High Priority:
1. **Home/Feed Screen** - Post cards with staggered animation
2. **Event Detail Screen** - Hero animations, scroll effects
3. **Profile Screen** - Animated profile header
4. **Search Screen** - Animated search results
5. **Create Post Screen** - Image preview animations

### Medium Priority:
6. **Password Screen** - Form animations
7. **Forgot Password** - Form animations
8. **Verify SMS** - Code input animations
9. **Reset Password** - Success animations
10. **Settings Screen** - List tile animations
11. **About Screen** - Fade-in content
12. **Contact Us** - Form animations
13. **Executive Committee** - Card grid animations
14. **Leo Assist** - Interactive animations

## 🎯 Animation Guidelines

### Timing:
- **Micro-interactions:** 100-200ms (button press, checkbox)
- **Transitions:** 300-500ms (screen changes, slides)
- **Reveals:** 400-800ms (list items, cards appearing)
- **Ambient:** 10-30s (floating bubbles, subtle movements)

### Curves:
- **easeOut:** Items entering (default)
- **easeIn:** Items exiting
- **easeInOut:** Smooth both ways
- **elasticOut:** Playful bouncy effects
- **fastOutSlowIn:** Material Design default

### Performance:
- Use `const` constructors where possible
- Dispose controllers in `dispose()`
- Use `RepaintBoundary` for expensive widgets
- Prefer `AnimatedBuilder` over `setState` for animations
- Use `TickerProviderStateMixin` for multiple controllers

## 🛠️ Material Design Widgets Used

### Input/Forms:
- `TextField` - Material text input
- `Checkbox` - Material checkbox
- `InkWell` - Ripple effect container
- `Material` - Surface with elevation

### Feedback:
- `CircularProgressIndicator` - Loading spinner
- `SnackBar` - Toast notifications
- `Dialog` - Modal dialogs

### Navigation:
- `Hero` - Shared element transitions
- `PageRouteBuilder` - Custom transitions

## 📝 Code Checklist for New Screens

- [ ] Add `TickerProviderStateMixin` for animations
- [ ] Create `AnimationController`s in `initState`
- [ ] Dispose controllers in `dispose()`
- [ ] Use `AnimatedBuilder` for complex animations
- [ ] Add Material ripples with `InkWell`
- [ ] Implement staggered animations for lists
- [ ] Add floating bubbles if in Figma design
- [ ] Use `Hero` for shared elements
- [ ] Add `SnackBar` feedback for actions
- [ ] Test on both light and dark themes
- [ ] Verify animations are 60fps

## 🎨 Color Scheme from Figma

```dart
Primary: #FFD700 (Gold)
Secondary: #8F7902 (Dark Gold)
Background: #FFFFFF (White)
Surface: rgba(0,0,0,0.1) (Light Black)
Text Primary: #202020 (Near Black)
Text Secondary: #D2D2D2 (Light Gray)
Success: #00D390 (Green)
Error: #E53935 (Red)
```

## 📱 Screen Sizes (from Figma)

- Width: 402px
- Height: 874px (typical iPhone 13/14)
- Status Bar: 48px
- Bottom Indicator: 145.848px × 5.442px

## 🔄 Next Steps

1. Implement Home/Feed screen with post animations
2. Add pull-to-refresh animation
3. Implement Event Detail with scroll effects
4. Add page transition animations
5. Implement search animations
6. Add profile animations
7. Continue with remaining 60+ screens

## 💡 Tips

- Always preview animations at 0.5x speed during development
- Test on real devices for performance
- Use Chrome DevTools Timeline to debug janky animations
- Keep animation durations under 500ms for responsiveness
- Use `flutter run --profile` to test performance
- Add `debugPrintRebuildDirtyWidgets = true;` to find excessive rebuilds

## 📚 Resources

- [Flutter Animation Docs](https://docs.flutter.dev/development/ui/animations)
- [Material Motion System](https://material.io/design/motion/the-motion-system.html)
- [Flutter Animation Guide](https://flutter.dev/docs/development/ui/animations/tutorial)

