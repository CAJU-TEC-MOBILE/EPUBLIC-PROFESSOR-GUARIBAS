import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/auth_model.dart';
import 'package:professor_acesso_notifiq/models/professor_model.dart';

class AuthServiceAdapter {
  AuthModel exibirAuth() {
    Box authBox = Hive.box('auth');

    final authData = authBox.get('auth') as Map<dynamic, dynamic>?;

    if (authData == null) {
      throw Exception('No authentication data found');
    }

    AuthModel authModel = AuthModel.fromJson(authData);

    return authModel;
  }

  Professor exibirProfessor() {
    Box authBox = Hive.box('auth');

    final authData = authBox.get('auth') as Map<dynamic, dynamic>?;

    if (authData == null) {
      throw Exception('No authentication data found');
    }

    AuthModel authModel = AuthModel.fromJson(authData);

    final professor = authModel.professor;

    if (professor == null) {
      return Professor.vazio();
    }

    return professor;
  }

  void removerDadosAuth() {
    Box authBox = Hive.box('auth');
    authBox.clear();
  }
}
