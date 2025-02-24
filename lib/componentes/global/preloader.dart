import 'package:flutter/material.dart';

import '../../constants/app_tema.dart';

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: AppTema.primaryWhite,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppTema.primaryAmarelo,
              ),
              SizedBox(width: 16.0),
              Text('Carregando...'),
            ],
          ),
        ),
      );
    },
  );
}

void hideLoading(BuildContext context) {
  Navigator.of(context).pop();
}
