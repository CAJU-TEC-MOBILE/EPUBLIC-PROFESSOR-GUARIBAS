import 'package:flutter/material.dart';

import '../../constants/app_tema.dart';

class CustomDialogs {
  static const double btnWidth = 30.0;

  static Future<bool?> dialogFrequencia(
      BuildContext context, String mensagemFrequencia) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.only(left: 24, right: 24, top: 24),
          title: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -10,
                top: -10,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: Text('Frequência'),
              ),
            ],
          ),
          content: Text(mensagemFrequencia),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: btnWidth),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Falta',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: btnWidth - 10.0),
                    backgroundColor: AppTema.primaryAmarelo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: const Text(
                    'Presença',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static void showLoadingDialog(BuildContext context,
      {required bool show, String? message}) {
    if (show) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppTema.primaryAmarelo,
                  ),
                  const SizedBox(width: 16.0),
                  Text(message ?? 'Carregando...'),
                ],
              ),
            ),
          );
        },
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}
