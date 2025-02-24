import 'package:flutter/material.dart';

class SnackBarServiceWidget {
  static void mostrarSnackBar(BuildContext context,
      {String mensagem = '',
      Color backgroundColor = Colors.red,
      IconData icon = Icons.abc,
      Color iconColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(
              mensagem,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
