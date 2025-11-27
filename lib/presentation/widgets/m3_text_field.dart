import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/m3_design_system.dart';

/// Material Design 3 compliant TextField
/// 
/// Features:
/// - Proper M3 dimensions (56dp height)
/// - Correct padding (16dp horizontal, 12dp vertical)
/// - Standard font sizes (16sp input, 12sp label/error)
/// - All states (normal, focused, error, disabled)
/// - Universal device compatibility
class M3TextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showClearButton;
  final FocusNode? focusNode;
  
  // Style variants
  final M3TextFieldStyle style;
  final bool isDarkBackground;
  final bool isPillShaped;
  
  const M3TextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearButton = false,
    this.focusNode,
    this.style = M3TextFieldStyle.filled,
    this.isDarkBackground = false,
    this.isPillShaped = false,
  });

  @override
  State<M3TextField> createState() => _M3TextFieldState();
}

class _M3TextFieldState extends State<M3TextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;
  
  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _errorText = widget.errorText;
  }
  
  @override
  void didUpdateWidget(M3TextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      _errorText = widget.errorText;
    }
  }
  
  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }
  
  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Initialize M3 design system
    M3DesignSystem.init(context);
    
    final hasError = _errorText != null && _errorText!.isNotEmpty;
    final isDisabled = !widget.enabled;
    
    // Determine colors based on state and background
    final colors = widget.isDarkBackground 
        ? _getDarkColors(hasError, isDisabled, _isFocused)
        : _getLightColors(hasError, isDisabled, _isFocused);
    
    // Border radius
    final borderRadius = widget.isPillShaped 
        ? M3DesignSystem.inputRadiusPill 
        : M3DesignSystem.inputRadius;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label (if provided and not using floating label)
        if (widget.labelText != null && widget.style == M3TextFieldStyle.outlined) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              fontSize: M3DesignSystem.labelMedium,
              fontWeight: FontWeight.w500,
              color: hasError ? colors.errorColor : colors.labelColor,
            ),
          ),
          SizedBox(height: M3DesignSystem.spacingS),
        ],
        
        // Text field container
        SizedBox(
          height: widget.maxLines > 1 
              ? null 
              : M3DesignSystem.inputHeight,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText ? _obscureText : false,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            validator: (value) {
              if (widget.validator != null) {
                final error = widget.validator!(value);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _errorText = error;
                    });
                  }
                });
                return error;
              }
              return null;
            },
            onChanged: (value) {
              // Clear error on change
              if (_errorText != null) {
                setState(() {
                  _errorText = null;
                });
              }
              widget.onChanged?.call(value);
            },
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            // Ensure field scrolls into view when focused with keyboard
            scrollPadding: const EdgeInsets.all(100.0),
            style: TextStyle(
              fontSize: M3DesignSystem.inputTextSize,
              fontWeight: FontWeight.w400,
              color: colors.textColor,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: M3DesignSystem.hintTextSize,
                fontWeight: FontWeight.w400,
                color: colors.hintColor,
              ),
              labelText: widget.style == M3TextFieldStyle.filled 
                  ? widget.labelText 
                  : null,
              labelStyle: TextStyle(
                fontSize: M3DesignSystem.bodyLarge,
                fontWeight: FontWeight.w400,
                color: colors.labelColor,
              ),
              floatingLabelStyle: TextStyle(
                fontSize: M3DesignSystem.floatingLabelSize,
                fontWeight: FontWeight.w500,
                color: _isFocused ? colors.focusedBorderColor : colors.labelColor,
              ),
              helperText: widget.helperText,
              helperStyle: TextStyle(
                fontSize: M3DesignSystem.helperTextSize,
                fontWeight: FontWeight.w400,
                color: colors.helperColor,
              ),
              errorText: null, // We handle error below
              counterText: '', // Hide counter
              filled: widget.style == M3TextFieldStyle.filled || widget.isDarkBackground,
              fillColor: colors.fillColor,
              contentPadding: widget.prefixIcon != null
                  ? M3DesignSystem.inputContentPaddingWithIcon
                  : M3DesignSystem.inputContentPadding,
              
              // Prefix icon
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: M3DesignSystem.inputPaddingHorizontal,
                        right: M3DesignSystem.iconTextPadding,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          size: M3DesignSystem.iconSize,
                          color: colors.iconColor,
                        ),
                        child: widget.prefixIcon!,
                      ),
                    )
                  : null,
              prefixIconConstraints: BoxConstraints(
                minWidth: M3DesignSystem.minTouchTarget,
                minHeight: M3DesignSystem.minTouchTarget,
              ),
              
              // Suffix icon
              suffixIcon: _buildSuffixIcon(colors),
              suffixIconConstraints: BoxConstraints(
                minWidth: M3DesignSystem.minTouchTarget,
                minHeight: M3DesignSystem.minTouchTarget,
              ),
              
              // Borders
              border: _buildBorder(borderRadius, colors.borderColor),
              enabledBorder: _buildBorder(borderRadius, colors.borderColor),
              focusedBorder: _buildBorder(
                borderRadius, 
                colors.focusedBorderColor,
                width: M3DesignSystem.inputBorderFocused,
              ),
              errorBorder: _buildBorder(
                borderRadius, 
                colors.errorColor,
                width: M3DesignSystem.inputBorderFocused,
              ),
              focusedErrorBorder: _buildBorder(
                borderRadius, 
                colors.errorColor,
                width: M3DesignSystem.inputBorderFocused,
              ),
              disabledBorder: _buildBorder(borderRadius, colors.disabledBorderColor),
            ),
          ),
        ),
        
        // Error text (fixed height container to prevent layout shift)
        SizedBox(
          height: M3DesignSystem.spacingL,
          child: _errorText != null && _errorText!.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    left: M3DesignSystem.inputPaddingHorizontal,
                    top: M3DesignSystem.spacingXS,
                  ),
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      fontSize: M3DesignSystem.helperTextSize,
                      fontWeight: FontWeight.w400,
                      color: colors.errorColor,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
  
  Widget? _buildSuffixIcon(_M3TextFieldColors colors) {
    final List<Widget> icons = [];
    
    // Clear button
    if (widget.showClearButton && 
        widget.controller != null && 
        widget.controller!.text.isNotEmpty) {
      icons.add(
        IconButton(
          icon: Icon(
            Icons.clear,
            size: M3DesignSystem.iconSizeSmall,
            color: colors.iconColor,
          ),
          onPressed: () {
            widget.controller?.clear();
            widget.onChanged?.call('');
          },
        ),
      );
    }
    
    // Password visibility toggle
    if (widget.obscureText) {
      icons.add(
        IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            size: M3DesignSystem.iconSize,
            color: colors.iconColor,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      );
    }
    
    // Custom suffix icon
    if (widget.suffixIcon != null) {
      icons.add(
        IconTheme(
          data: IconThemeData(
            size: M3DesignSystem.iconSize,
            color: colors.iconColor,
          ),
          child: widget.suffixIcon!,
        ),
      );
    }
    
    if (icons.isEmpty) return null;
    
    if (icons.length == 1) {
      return Padding(
        padding: EdgeInsets.only(right: M3DesignSystem.spacingS),
        child: icons.first,
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );
  }
  
  InputBorder _buildBorder(double radius, Color color, {double? width}) {
    if (widget.style == M3TextFieldStyle.filled && !widget.isDarkBackground) {
      return UnderlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        borderSide: BorderSide(
          color: color,
          width: width ?? M3DesignSystem.inputBorderNormal,
        ),
      );
    }
    
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: widget.isDarkBackground
          ? BorderSide.none
          : BorderSide(
              color: color,
              width: width ?? M3DesignSystem.inputBorderNormal,
            ),
    );
  }
  
  _M3TextFieldColors _getLightColors(bool hasError, bool isDisabled, bool isFocused) {
    return _M3TextFieldColors(
      textColor: isDisabled ? M3InputColors.textDisabled : Colors.black87,
      hintColor: M3InputColors.hintNormal,
      labelColor: hasError ? M3InputColors.labelError : M3InputColors.labelNormal,
      helperColor: M3InputColors.labelNormal,
      errorColor: M3InputColors.borderError,
      borderColor: M3InputColors.borderNormal,
      focusedBorderColor: M3InputColors.borderFocused,
      disabledBorderColor: M3InputColors.borderDisabled,
      fillColor: isDisabled 
          ? Colors.grey.shade100 
          : const Color(0xFFF7F2FA),
      iconColor: M3InputColors.labelNormal,
    );
  }
  
  _M3TextFieldColors _getDarkColors(bool hasError, bool isDisabled, bool isFocused) {
    return _M3TextFieldColors(
      textColor: M3InputColors.textDark,
      hintColor: M3InputColors.hintDark,
      labelColor: hasError ? Colors.red.shade300 : Colors.white70,
      helperColor: Colors.white70,
      errorColor: Colors.red.shade300,
      borderColor: M3InputColors.borderDark,
      focusedBorderColor: Colors.white,
      disabledBorderColor: Colors.white24,
      fillColor: M3InputColors.fillDark,
      iconColor: Colors.white70,
    );
  }
}

/// Color configuration for M3TextField
class _M3TextFieldColors {
  final Color textColor;
  final Color hintColor;
  final Color labelColor;
  final Color helperColor;
  final Color errorColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color disabledBorderColor;
  final Color fillColor;
  final Color iconColor;
  
  const _M3TextFieldColors({
    required this.textColor,
    required this.hintColor,
    required this.labelColor,
    required this.helperColor,
    required this.errorColor,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.disabledBorderColor,
    required this.fillColor,
    required this.iconColor,
  });
}

/// TextField style variants
enum M3TextFieldStyle {
  /// Filled style with underline border (M3 default)
  filled,
  
  /// Outlined style with full border
  outlined,
}

/// Convenience widget for M3 Password TextField
class M3PasswordField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool isDarkBackground;
  final bool isPillShaped;
  
  const M3PasswordField({
    super.key,
    this.controller,
    this.hintText = 'Password',
    this.labelText,
    this.errorText,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.isDarkBackground = false,
    this.isPillShaped = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return M3TextField(
      controller: controller,
      hintText: hintText,
      labelText: labelText,
      errorText: errorText,
      obscureText: true,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      isDarkBackground: isDarkBackground,
      isPillShaped: isPillShaped,
    );
  }
}

/// Convenience widget for M3 Email TextField
class M3EmailField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool isDarkBackground;
  final bool isPillShaped;
  
  const M3EmailField({
    super.key,
    this.controller,
    this.hintText = 'Email',
    this.labelText,
    this.errorText,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.isDarkBackground = false,
    this.isPillShaped = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return M3TextField(
      controller: controller,
      hintText: hintText,
      labelText: labelText,
      errorText: errorText,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      isDarkBackground: isDarkBackground,
      isPillShaped: isPillShaped,
    );
  }
}
