// widgets/custom_passwordfield.dart
import 'package:flutter/material.dart';

import '../utils/paleta_cor.dart';
import '../utils/app_theme.dart';

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color fillColor;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry contentPadding;
  final String? Function(String?)? validator;

  const CustomPasswordField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.prefixIcon = Icons.lock_outline,
    this.borderColor = Colors.grey,
    this.focusedBorderColor = AppTheme.primaryColor,
    this.fillColor = Colors.transparent,
    this.labelStyle,
    this.contentPadding = const EdgeInsets.symmetric(
      vertical: 15.0,
      horizontal: 10.0,
    ),
    this.validator,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = true;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        labelStyle: const TextStyle(color: PaletaCor.primaryDarkBlue),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: PaletaCor.primaryAmarelo,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        fillColor: widget.fillColor,
        contentPadding: widget.contentPadding,
      ),
    );
  }
}
