String retornarDiaDaSemana({required String dataBrasileira}) {
  try {
    // Converta a data brasileira para DateTime
    final List<String> partes = dataBrasileira.split('/');
    final int dia = int.parse(partes[0]);
    final int mes = int.parse(partes[1]);
    final int ano = int.parse(partes[2]);

    final DateTime data = DateTime(ano, mes, dia);

    final List<String> diasDaSemana = [
      'Domingo',
      'Segunda-Feira',
      'Terça-Feira',
      'Quarta-Feira',
      'Quinta-Feira',
      'Sexta-Feira',
      'Sábado'
    ];

    return diasDaSemana[data.weekday];
  } catch (e) {
    return 'Data inválida';
  }
}
