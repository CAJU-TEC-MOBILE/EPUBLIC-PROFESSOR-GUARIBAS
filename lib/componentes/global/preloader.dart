import 'package:flutter/material.dart';
import '../../constants/app_tema.dart';

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: AppTema.primaryWhite,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/ePUBLIC.png',
                width: 150,
                height: 124,
              ),
              SizedBox(height: 16.0),
              Text('Carregando dados...'),
              SizedBox(height: 16.0),
              LinearProgressIndicator(
                color: AppTema.primaryAmarelo,
                backgroundColor: Colors.grey[300],
              )
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
