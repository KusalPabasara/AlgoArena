import 'package:flutter/material.dart';

/// A widget that makes content keyboard-aware by:
/// 1. Automatically scrolling to focused text fields
/// 2. Adding padding when keyboard is visible
/// 3. Ensuring text fields are always visible when typing
/// 
/// Usage:
/// ```dart
/// KeyboardAwareWrapper(
///   child: Column(
///     children: [
///       TextField(...),
///       TextField(...),
///     ],
///   ),
/// )
/// ```
class KeyboardAwareWrapper extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final bool autoScrollToFocused;
  final double extraBottomPadding;
  final ScrollPhysics? physics;
  
  const KeyboardAwareWrapper({
    super.key,
    required this.child,
    this.scrollController,
    this.padding,
    this.autoScrollToFocused = true,
    this.extraBottomPadding = 20.0,
    this.physics,
  });
  
  @override
  State<KeyboardAwareWrapper> createState() => _KeyboardAwareWrapperState();
}

class _KeyboardAwareWrapperState extends State<KeyboardAwareWrapper> {
  late ScrollController _scrollController;
  bool _isUsingInternalController = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else {
      _scrollController = ScrollController();
      _isUsingInternalController = true;
    }
  }
  
  @override
  void dispose() {
    if (_isUsingInternalController) {
      _scrollController.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Get keyboard height
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    
    return GestureDetector(
      // Dismiss keyboard when tapping outside text fields
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Allow scroll notifications to propagate
          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: widget.physics ?? const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            left: widget.padding?.left ?? 0,
            right: widget.padding?.right ?? 0,
            top: widget.padding?.top ?? 0,
            // Add extra padding at bottom when keyboard is visible
            bottom: (widget.padding?.bottom ?? 0) + 
                   (isKeyboardVisible ? keyboardHeight + widget.extraBottomPadding : 0),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A text field wrapper that automatically scrolls itself into view when focused
/// 
/// Usage:
/// ```dart
/// KeyboardAwareTextField(
///   controller: _controller,
///   decoration: InputDecoration(labelText: 'Email'),
/// )
/// ```
class KeyboardAwareTextField extends StatefulWidget {
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final TextStyle? style;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final EdgeInsets scrollPadding;
  
  const KeyboardAwareTextField({
    super.key,
    this.controller,
    this.decoration,
    this.keyboardType,
    this.obscureText = false,
    this.focusNode,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.textInputAction,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.style,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.scrollPadding = const EdgeInsets.all(100.0),
  });
  
  @override
  State<KeyboardAwareTextField> createState() => _KeyboardAwareTextFieldState();
}

class _KeyboardAwareTextFieldState extends State<KeyboardAwareTextField> {
  late FocusNode _focusNode;
  bool _isUsingInternalFocusNode = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isUsingInternalFocusNode = true;
    }
    
    // Add listener to scroll into view when focused
    _focusNode.addListener(_onFocusChange);
  }
  
  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_isUsingInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }
  
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Ensure the field scrolls into view after a short delay
      // This allows the keyboard to appear first
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _focusNode.hasFocus) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.5, // Center the field in the visible area
            alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
          );
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      style: widget.style,
      autofocus: widget.autofocus,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      scrollPadding: widget.scrollPadding,
    );
  }
}

/// Extension on BuildContext to provide keyboard utilities
extension KeyboardUtils on BuildContext {
  /// Returns true if keyboard is currently visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;
  
  /// Returns the height of the keyboard
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;
  
  /// Hides the keyboard by unfocusing
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
  
  /// Scrolls a widget into view (useful for text fields)
  void scrollToWidget(BuildContext widgetContext, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    Scrollable.ensureVisible(
      widgetContext,
      duration: duration,
      curve: curve,
      alignment: 0.5,
    );
  }
}

/// Mixin to make a StatefulWidget keyboard-aware
/// 
/// Usage:
/// ```dart
/// class MyScreen extends StatefulWidget {
///   // ...
/// }
/// 
/// class _MyScreenState extends State<MyScreen> with KeyboardAwareMixin {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       resizeToAvoidBottomInset: true,
///       body: buildKeyboardAwareBody(
///         child: YourContent(),
///       ),
///     );
///   }
/// }
/// ```
mixin KeyboardAwareMixin<T extends StatefulWidget> on State<T> {
  final ScrollController keyboardAwareScrollController = ScrollController();
  
  @override
  void dispose() {
    keyboardAwareScrollController.dispose();
    super.dispose();
  }
  
  /// Build a keyboard-aware body that scrolls properly
  Widget buildKeyboardAwareBody({
    required Widget child,
    EdgeInsets? padding,
    double extraBottomPadding = 20.0,
  }) {
    return KeyboardAwareWrapper(
      scrollController: keyboardAwareScrollController,
      padding: padding,
      extraBottomPadding: extraBottomPadding,
      child: child,
    );
  }
  
  /// Scroll to a specific position
  void scrollToPosition(double position, {Duration? duration}) {
    keyboardAwareScrollController.animateTo(
      position,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  /// Scroll to bottom
  void scrollToBottom({Duration? duration}) {
    if (keyboardAwareScrollController.hasClients) {
      keyboardAwareScrollController.animateTo(
        keyboardAwareScrollController.position.maxScrollExtent,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
