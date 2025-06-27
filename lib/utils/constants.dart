// utils/constants.dart
import 'package:flutter/material.dart';

class Constants {
  static List<String> tiposDeAulas = [
    "Aula Remota",
    "Aula Normal",
    "Reposição",
    "Aula Extra",
    "Substituição",
    "Aula Antecipada",
    "Atividade Extra-classe",
    "Recuperação",
  ];

  static List<Map<String, dynamic>> situacoesPlanos = [
    {"id": 1, "descricao": "Plano Confirmado", "cor": "green"},
    {"id": 2, "descricao": "Aguardando confirmação", "cor": "orange"},
    {"id": 3, "descricao": "Plano Inválido", "cor": "red"},
  ];

  static List<Map<String, dynamic>> situacoesAulasCor = [
    {"Aula confirmada": "green lighten-2"},
    {"Aguardando confirmação": "blue-grey lighten-2"},
    {"Aula rejeitada por falta": "red lighten-2"},
    {"Aula inválida": "brown lighten-3"},
    {"Aula em conflito": "amber lighten-2"},
  ];
  static const List<String> tipos = ['Fundamental', 'Infantil'];

  static List<String> meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static List<Map<String, dynamic>> mesesFundamental = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ]
      .map(
        (mes) => {
          'mes': mes,
          'form': {
            'unidadesTematicas': null,
            'objetosDoConhecimento': null,
            'habilidades': null,
            'observacoes': null,
            'metodologia': null,
            'recursosDidaticos': null,
            'avaliacaoDaAprendizagem': null,
            'referencias': null,
            'checkbox': false,
          },
          'controllers': {
            'unidadesTematicas': TextEditingController(),
            'objetosDoConhecimento': TextEditingController(),
            'habilidades': TextEditingController(),
            'observacoes': TextEditingController(),
            'metodologia': TextEditingController(),
            'recursosDidaticos': TextEditingController(),
            'avaliacaoDaAprendizagem': TextEditingController(),
            'referencias': TextEditingController(),
          },
        },
      )
      .toList();
}
