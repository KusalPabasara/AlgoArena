import 'package:flutter/material.dart';

/// Mixin to manage animation lifecycle - stops animations when app is paused
/// This prevents memory leaks and CPU usage when app is in background
mixin AnimationLifecycleMixin<T extends StatefulWidget> on State<T> implements WidgetsBindingObserver {
  /// List of animation controllers that should be paused/resumed
  List<AnimationController> get animationControllers;
  
  /// Whether animations should auto-resume when app resumes
  final bool autoResume = true;
  
  /// Track which controllers were repeating before pause
  final Map<AnimationController, bool> _wasRepeating = {};
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _pauseAnimations();
        break;
      case AppLifecycleState.resumed:
        if (autoResume) {
          _resumeAnimations();
        }
        break;
      case AppLifecycleState.detached:
        _pauseAnimations();
        break;
      case AppLifecycleState.hidden:
        _pauseAnimations();
        break;
    }
  }
  
  // Implement other WidgetsBindingObserver methods as no-ops
  @override
  void didChangeAccessibilityFeatures() {}
  
  @override
  void didChangeLocales(List<Locale>? locales) {}
  
  @override
  void didChangeMetrics() {}
  
  @override
  void didChangePlatformBrightness() {}
  
  @override
  void didChangeTextScaleFactor() {}
  
  @override
  void didChangeViewFocus(dynamic event) {}
  
  @override
  void didHaveMemoryPressure() {}
  
  @override
  Future<bool> didPopRoute() => Future<bool>.value(false);
  
  @override
  Future<bool> didPushRoute(String route) => Future<bool>.value(false);
  
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) => Future<bool>.value(false);
  
  // Note: didRequestAppExit is commented out due to Flutter version compatibility
  // It's not critical for animation lifecycle management
  // @override
  // Future<AppExitResponse> didRequestAppExit() async {
  //   return AppExitResponse.exit;
  // }
  
  @override
  void handleCancelBackGesture() {}
  
  @override
  void handleCommitBackGesture() {}
  
  @override
  bool handleStartBackGesture(dynamic backEvent) => false;
  
  @override
  void handleUpdateBackGestureProgress(dynamic backEvent) {}
  
  /// Pause all repeating animations
  void _pauseAnimations() {
    for (var controller in animationControllers) {
      if (controller.isAnimating) {
        _wasRepeating[controller] = controller.status == AnimationStatus.forward ||
                                   controller.status == AnimationStatus.reverse;
        controller.stop();
      }
    }
  }
  
  /// Resume animations that were repeating
  void _resumeAnimations() {
    for (var controller in animationControllers) {
      if (_wasRepeating[controller] == true && !controller.isAnimating) {
        // Check if it was repeating with reverse or without
        try {
          controller.repeat(reverse: true);
        } catch (e) {
          // If reverse fails, try without reverse
          controller.repeat();
        }
        _wasRepeating[controller] = false;
      }
    }
  }
  
  /// Manually pause all animations
  void pauseAllAnimations() {
    _pauseAnimations();
  }
  
  /// Manually resume all animations
  void resumeAllAnimations() {
    _resumeAnimations();
  }
}

