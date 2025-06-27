class Validador {
  static String? validarCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }

    String numericCPF = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericCPF.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    return null;
  }

  static String? validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória';
    }

    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }

    return null;
  }

  static String? validarObrigatorio(
    String? value, {
    required String nomeCampo,
  }) {
    if (value == null || value.trim().isEmpty) {
      String text = nomeCampo.toLowerCase();
      return '$text é obrigatório';
    }
    return null;
  }

  static String? validarIntObrigatorio(
    int? value, {
    required String nomeCampo,
  }) {
    if (value == null) {
      String text = nomeCampo.toLowerCase();
      return '$text é obrigatório';
    }
    return null;
  }

  static String? validarObjectObrigatorio<T>(
    T? value, {
    required String nomeCampo,
  }) {
    if (value == null) {
      return '$nomeCampo é obrigatório';
    }
    return null;
  }
}
