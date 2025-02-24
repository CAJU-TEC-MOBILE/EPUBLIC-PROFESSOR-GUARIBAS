import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';

class CustomDefauldeGrafico extends StatelessWidget {
  const CustomDefauldeGrafico({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100.0,
          height: 100.0,
          child: Image.asset('assets/estatisticas.png'),
        ),
        const Text(
          'Nenhuma franquia',
          style: TextStyle(
            color: AppTema.primaryDarkBlue,
          ),
        ),
        const Text(
          'disponível no momento',
          style: TextStyle(
            color: AppTema.primaryDarkBlue,
          ),
        ),
      ],
    );
  }
}
