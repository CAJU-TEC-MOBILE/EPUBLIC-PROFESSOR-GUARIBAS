// class AulasSituacoesConst {
//   static const String confirmada = 'Aula confirmada';
//   static const String aguardandoConfirmacao = 'Aguardando confirmação';
//   static const String rejeitada = 'Aula rejeitada por falta';
//   static const String invalida = 'Aula inválida';
//   static const String conflito = 'Aula em conflito';
// }
import 'package:flutter/material.dart';

class AulasSituacoesConst {
  static const Map<String, Color> situacoes = {
    'Aula confirmada': Color.fromARGB(255, 219, 178, 67),
    'Aguardando confirmação': Color.fromARGB(255, 170, 168, 168),
    'Aula rejeitada por falta': Color.fromARGB(255, 243, 76, 64),
    'Aula inválida': Color.fromARGB(255, 129, 102, 92),
    'Aula em conflito': Color.fromARGB(255, 219, 178, 67),
  };

  static const aulaEmConflitoIcon = Icon(Icons.help_outline);
}
