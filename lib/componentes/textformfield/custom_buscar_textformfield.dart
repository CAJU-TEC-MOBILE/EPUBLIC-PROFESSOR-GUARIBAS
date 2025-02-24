import 'package:flutter/material.dart';

class CustomBuscarTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Color borderColor;
  final Color labelColor;
  final Color cursorColor;
  final String? Function(String?)? validator;
  final Future<String?>? fetchValue; // Função para buscar o valor inicial
  final VoidCallback onSearch; // Callback para ação de buscar

  const CustomBuscarTextFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.borderColor = Colors.blue,
    this.labelColor = Colors.black,
    this.cursorColor = Colors.blue,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.fetchValue,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<CustomBuscarTextFormField> createState() => _CustomBuscarTextFormFieldState();
}

class _CustomBuscarTextFormFieldState extends State<CustomBuscarTextFormField> {
  final FocusNode _focusNode = FocusNode();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialValue();
  }

  Future<void> _loadInitialValue() async {
    if (widget.fetchValue != null) {
      setState(() => _loading = true);
      try {
        final value = await widget.fetchValue!;
        if (value != null) {
          widget.controller.text = value;
        }
      } catch (e) {
        debugPrint('Failed to fetch value: $e');
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            cursorColor: widget.cursorColor,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: widget.labelColor,
              ),
              hintText: widget.hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: widget.borderColor,
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                color: widget.borderColor,
                onPressed: widget.onSearch, // Chama a função de busca
              ),
            ),
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
          );
  }
}
