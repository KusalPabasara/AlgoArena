import 'package:flutter/material.dart';

/// Mixin to manage animation lifecycle - stops animations when app is paused
/// This prevents memory leaks and CPU usage when app is in background
mixin AnimationLifecycleMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  /// List of animation controllers that should be paused/resumed
  List<AnimationController> get animationControllers;
  
  /// Whether animations should auto-resume when app resumes
  final bool autoResume = true;
  
  /// Track which controllers were repeating before pause
  final Map<AnimationController, bool> _wasRepeating = {};
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
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

