import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/auth_model.dart';
import 'package:professor_acesso_notifiq/models/professor_model.dart';

class AuthServiceAdapter {
  Auth exibirAuth() {
    Box authBox = Hive.box('auth');
    // Retrieve the auth data, which might be null
    final authData = authBox.get('auth') as Map<dynamic, dynamic>?;

    if (authData == null) {
      // Handle the case where authData is null
      throw Exception('No authentication data found');
    }

    // Safely create an Auth model
    Auth authModel = Auth.fromJson(authData);

    return authModel;
  }

  Professor exibirProfessor() {
    Box authBox = Hive.box('auth');
    // Retrieve the auth data, which might be null
    final authData = authBox.get('auth') as Map<dynamic, dynamic>?;

    if (authData == null) {
      // Handle the case where authData is null
      throw Exception('No authentication data found');
    }

    // Safely create an Auth model
    Auth authModel = Auth.fromJson(authData);

    // Safely access the professor property
    final professor = authModel.professor;
    if (professor == null) {
      throw Exception('No professor data found');
    }

    return professor;
  }

  void removerDadosAuth() {
    Box authBox = Hive.box('auth');
    authBox.clear(); // Remove todos os dados do Box 'auth'
  }
}
