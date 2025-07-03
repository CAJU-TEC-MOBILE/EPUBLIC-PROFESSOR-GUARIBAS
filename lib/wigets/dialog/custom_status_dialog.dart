import 'package:flutter/material.dart';

class CustomStatusDialog {
  static void _showDialog(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color iconColor,
    VoidCallback? onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        title: Row(
          children: [
            Icon(icon, size: 22.0, color: iconColor),
            const SizedBox(width: 4.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.left,
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        actions: [
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: Navigator.of(context).pop,
                child: const Text(
                  "Cancelar",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: iconColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: onConfirm,
                child: const Text("Confirmar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void sucesso(
    BuildContext context, {
    String mensagem = '',
    VoidCallback? onConfirm,
  }) {
    _showDialog(
      context,
      'Sucesso',
      mensagem,
      Icons.check_circle_outline,
      Colors.green,
      onConfirm,
    );
  }

  static void erro(
    BuildContext context, {
    String mensagem = '',
    VoidCallback? onConfirm,
  }) {
    _showDialog(
      context,
      'Erro',
      mensagem,
      Icons.error_outline,
      Colors.red,
      onConfirm,
    );
  }

  static void aviso(
    BuildContext context, {
    String mensagem = '',
    VoidCallback? onConfirm,
  }) {
    _showDialog(
      context,
      'Aviso',
      mensagem,
      Icons.warning_amber_rounded,
      Colors.orange,
      onConfirm,
    );
  }

  static void informacao(
    BuildContext context, {
    String mensagem = '',
    VoidCallback? onConfirm,
  }) {
    _showDialog(
      context,
      'Informação',
      mensagem,
      Icons.info_outline,
      Colors.grey,
      onConfirm,
    );
  }
}
