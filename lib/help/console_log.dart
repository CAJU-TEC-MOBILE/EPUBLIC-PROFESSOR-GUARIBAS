class ConsoleLog {
  static void mensagem(
      {required String titulo,
      required String mensagem,
      required String tipo}) {
    String colorCode;

    switch (tipo) {
      case 'sucesso':
        colorCode = '\x1B[32m';
        break;
      case 'erro':
        colorCode = '\x1B[31m';

        break;
      case 'informacao':
        colorCode = '\x1B[34m';
        break;
      default:
        colorCode = '\x1B[33m';
        break;
    }
    String resetColor = '\x1B[0m';
    print('$colorCode$titulo: $mensagem$resetColor');
  }
}
