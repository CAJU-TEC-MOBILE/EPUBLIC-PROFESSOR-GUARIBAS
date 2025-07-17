import 'package:flutter/material.dart';

import '../../models/aula_totalizador_model.dart';

class CustomTotalizadorAulaCartd extends StatefulWidget {
  AulaTotalizador totalizador;
  CustomTotalizadorAulaCartd({super.key, required this.totalizador});

  @override
  State<CustomTotalizadorAulaCartd> createState() =>
      _CustomTotalizadorAulaCartdState();
}

class _CustomTotalizadorAulaCartdState
    extends State<CustomTotalizadorAulaCartd> {
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        children: [],
      ),
    );
  }
}
