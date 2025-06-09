import '../../models/auth_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/professor_model.dart';

class AuthController {
  late Box box;

  Future<void> init() async {
    await Hive.initFlutter();

    box = await Hive.openBox('auth');
  }

  Future<void> getAll() async {
    var dado = box.values.toList();
    print('dado: $dado');
  }

  Future<Auth?> getAuth() async {
    if (box.isEmpty) {
      // print('---> O Box está vazio.');
      return null;
    }

    final dado = box.values.first;

    try {
      if (dado is Map) {
        final mapDado = Map<String, dynamic>.from(dado);
        return Auth.fromMap(mapDado);
      }

      if (dado is Auth) {
        return dado;
      }

      print('Tipo de dado inesperado: ${dado.runtimeType}');
      return null;
    } catch (e, stack) {
      print('Erro ao processar o dado: $e');
      print('Stack trace: $stack');
      return null;
    }
  }

  Future<void> updateName(String? name) async {
    if (box.isEmpty) {
      return;
    }

    Auth? dado = box.values.first;
    if (dado == null) {
      return;
    }
    dado.name = name.toString();

    await box.put(dado.id, dado);
  }

  Future<void> updateAnoId({required int anoId}) async {
    if (box.isEmpty) {
      // print('---> O Box está vazio.');
      return;
    }

    try {
      final dado = box.values.first;

      if (dado is Map) {
        final auth = Auth.fromMap(Map<String, dynamic>.from(dado));

        final updatedAuth = auth.copyWith(anoId: anoId.toString());

        await box.put(auth.id, updatedAuth.toMap());
        print('atualizado com sucesso.');
      } else {
        print('Tipo de dado inesperado: ${dado.runtimeType}');
      }
    } catch (e) {
      print('Erro ao atualizar ano_id: $e');
    }
  }

  Future<Auth?> updateAuthProfessor(Professor novoProfessor) async {
    if (box.isEmpty) {
      // print('---> O Box está vazio.');
      return null;
    }

    final dado = box.values.first;

    print('Tipo de dado armazenado no box: ${dado.runtimeType}');

    try {
      if (dado is Map) {
        final auth = Auth.fromMap(Map<String, dynamic>.from(dado));

        final updatedAuth = auth.copyWith(professor: novoProfessor);

        await box.put(box.keys.first, updatedAuth.toMap());

        print('Auth atualizado com sucesso: $updatedAuth');
        return updatedAuth;
      }

      if (dado is Auth) {
        final updatedAuth = dado.copyWith(professor: novoProfessor);

        await box.put(box.keys.first, updatedAuth.toMap());

        print('Auth atualizado com sucesso: $updatedAuth');
        return updatedAuth;
      }
      await getAll();
      print('Dado não é do tipo Auth');
      return null;
    } catch (e, stack) {
      print('Erro ao processar o dado: $e');
      print('Stack trace: $stack');
      return null;
    }
  }
}
