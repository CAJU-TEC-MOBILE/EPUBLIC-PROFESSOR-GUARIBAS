import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/professor_model.dart';
import '../../data/adapters/auth_adapter.dart';
import '../../enums/status_console.dart';
import '../../helpers/console_log.dart';
import '../../models/auth_model.dart';

class AuthController {
  Box<AuthModel>? box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(AuthAdapter().typeId)) {
      Hive.registerAdapter(AuthAdapter());
    }

    box = await Hive.openBox<AuthModel>('auths');
  }

  Future<int> clear() async {
    if (box == null) throw Exception("AuthController not initialized");
    return await box!.clear();
  }

  Future<void> add(AuthModel model) async {
    if (box == null) throw Exception("AuthController not initialized");
    try {
      await box!.add(model);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'auth-add-controller',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
  }

  Future<AuthModel> authFirst() async {
    if (box == null) throw Exception("AuthController not initialized");
    try {
      return box!.values.first;
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'auth-authFirst-controller',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return AuthModel.vazio();
    }
  }

  Future<void> updateAnoId({required int anoId}) async {
    if (box == null) throw Exception("AuthController not initialized");

    try {
      final auth = box!.values.first;

      final updatedAuth = auth.copyWith(anoId: anoId.toString());

      await box!.put(auth.id, updatedAuth);

      print('Atualizado com sucesso.');
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'auth-updateAnoId-controller',
        mensagem: e.toString(),
        tipo: StatusConsole.error,
      );
    }
  }

  Future<Professor> authProfessorFirst() async {
    if (box == null) throw Exception("AuthController not initialized");
    try {
      AuthModel auth = box!.values.first;
      Professor professor = auth.professor ?? Professor.vazio();
      return professor;
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'auth-authFirst-controller',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return Professor.vazio();
    }
  }
}
