import 'package:flutter/material.dart';

import '../../constants/app_tema.dart';

class CustomSyncDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final String? message;
  final Future<void> Function() onConfirm;

  const CustomSyncDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.message = '',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sincronizar'),
      content: message == ''
          ? const Text('Deseja sincronizar esta aula?')
          : Text(message!.toString()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onCancel,
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppTema.primaryDarkBlue),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppTema.primaryDarkBlue,
            backgroundColor: AppTema.primaryAmarelo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text('Confirmar'),
          onPressed: () async {
            await onConfirm();
          },
        ),
      ],
    );
  }
}
