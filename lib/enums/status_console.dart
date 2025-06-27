enum StatusConsole {
  sucesso,
  error,
  informacao,
  alerta;

  String getDescricao() {
    switch (this) {
      case StatusConsole.sucesso:
        return 'Operação realizada com sucesso.';
      case StatusConsole.error:
        return 'Ocorreu um erro durante a operação.';
      case StatusConsole.informacao:
        return 'Informação relevante para o usuário.';
      case StatusConsole.alerta:
        return 'Atenção: algo importante precisa ser verificado.';
    }
  }

  String getCor() {
    switch (this) {
      case StatusConsole.sucesso:
        return '\x1B[32m';
      case StatusConsole.error:
        return '\x1B[31m';
      case StatusConsole.informacao:
        return '\x1B[34m';
      case StatusConsole.alerta:
        return '\x1B[33m';
    }
  }
}
