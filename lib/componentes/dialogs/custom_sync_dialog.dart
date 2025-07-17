import 'package:flutter/material.dart';
import '../../constants/app_tema.dart';

class CustomSyncDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final String message;
  final Future<void> Function() onConfirm;

  const CustomSyncDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.message = 'Deseja realmente sincronizar esta aula?',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0.0,
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  SizedBox(width: 12),
                  Text(
                    'Sincronizar',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onCancel,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.close, size: 20.0),
                ),
              ),
            ],
          ),
          Center(
            child: Image.asset(
              'assets/sincronizar.png',
              width: 82.0,
              height: 82.0,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 36.0,
          child: ElevatedButton(
            onPressed: () async {
              await onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTema.primaryAmarelo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('Confirmar'),
          ),
        ),
        const SizedBox(
          height: 8.0,
        ),
      ],
    );
  }
}
