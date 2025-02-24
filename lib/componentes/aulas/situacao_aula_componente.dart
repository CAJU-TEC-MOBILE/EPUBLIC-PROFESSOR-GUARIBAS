import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/aulas/aulas_situacoes_const.dart';

// ignore: must_be_immutable
class SituacaoAulaComponente extends StatelessWidget {
  final String situacaoAula;
  String? situacaoAulaExibir;
  Color? colorAulaExibir;
  Color? corTextoExibir = Colors.white;
  double? fontSize = 12;
  double? widthContainer = 160;

  SituacaoAulaComponente({super.key, required this.situacaoAula});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    Map<String, dynamic> situacoesConst = AulasSituacoesConst.situacoes;
    AulasSituacoesConst.situacoes.forEach((key, value) {
      if (key == situacaoAula) {
        situacaoAulaExibir = key;
        colorAulaExibir = value;
        if (key == 'Aula inválida' || key == 'Aguardando confirmação') {
          corTextoExibir = Colors.black;
        }
      }
    });
    return SizedBox(
      width: widthContainer,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Define o raio da borda
        ),
        color: colorAulaExibir,
        child: Container(
          padding: const EdgeInsets.all(3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                situacaoAulaExibir.toString(),
                style: TextStyle(
                    fontSize: fontSize,
                    color: corTextoExibir,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
