import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';

import '../../services/launcher/launcher_controller.dart';

class CustomSugestaoCard extends StatelessWidget {
  final String titulo;
  final String imagem;

  const CustomSugestaoCard({
    super.key,
    required this.titulo,
    required this.imagem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () async {
          LauncherController launcherController = LauncherController();
          await launcherController.openWhatsApp(
            numero: '5586999880525',
            message: 'Olá, venho direto do Aplicativo pedir uma ajuda!',
          );
        },
        child: Card(
          color: AppTema.primaryWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 1.0,
          child: Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precisa de ajuda?\nContate-nos!',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppTema.primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  imagem,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
