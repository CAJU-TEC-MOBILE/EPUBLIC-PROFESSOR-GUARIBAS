// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../constants/app_tema.dart';
import '../../models/aula_totalizador_model.dart';

class CustomTotalizadorCard extends StatefulWidget {
  AulaTotalizador totalizador;

  CustomTotalizadorCard({
    super.key,
    required this.totalizador,
  });

  @override
  State<CustomTotalizadorCard> createState() => _CustomTotalizadorCardState();
}

class _CustomTotalizadorCardState extends State<CustomTotalizadorCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTema.primaryWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aulas',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppTema.primaryDarkBlue,
                  ),
                ),
                widget.totalizador.id != -1
                    ? Text(
                        widget.totalizador.anoAtual.toString(),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppTema.primaryDarkBlue,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text("Aula confirmada:"),
                      const SizedBox(width: 8.0),
                      Text(
                        widget.totalizador.qntConfirmada.toString(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: AppTema.primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Aguardando confirmação:",
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        widget.totalizador.qntAguardandoConfirmacao.toString(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: AppTema.primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text("Aula rejeitada por falta:"),
                      const SizedBox(width: 8.0),
                      Text(
                        widget.totalizador.qntFalta.toString(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: AppTema.primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text("Aula inválida:"),
                      const SizedBox(width: 8.0),
                      Text(
                        widget.totalizador.qntInvalida.toString(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: AppTema.primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text("Aula em conflito:"),
                      const SizedBox(width: 8.0),
                      Text(
                        widget.totalizador.qntConflito.toString(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: AppTema.primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
