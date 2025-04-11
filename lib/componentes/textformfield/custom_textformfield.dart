import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // Importando o pacote

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Color borderColor;
  final Color labelColor;
  final Color cursorColor;
  final String? Function(String?)? validator;
  final String? mask;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.borderColor = Colors.blue,
    this.labelColor = Colors.black,
    this.cursorColor = Colors.blue,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.mask,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final FocusNode _focusNode = FocusNode();
  MaskTextInputFormatter? _maskFormatter;

  @override
  void initState() {
    super.initState();
    // Verificando se a máscara foi fornecida
    if (widget.mask != null) {
      _maskFormatter = MaskTextInputFormatter(
          mask: widget.mask, filter: {"#": RegExp(r'[0-9]')});
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      cursorColor: widget.cursorColor,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: widget.labelColor),
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: widget.borderColor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      // Adiciona a máscara, se houver
      inputFormatters: _maskFormatter != null ? [_maskFormatter!] : [],
      validator: widget.validator,
    );
  }
}
