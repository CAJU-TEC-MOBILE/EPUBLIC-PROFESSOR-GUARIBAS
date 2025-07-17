import 'package:hive_flutter/hive_flutter.dart';
import '../../enums/status_console.dart';
import '../../helpers/console_log.dart';
import '../../models/disciplina_model.dart';

class DisciplinaController {
  late Box<Disciplina> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(DisciplinaAdapter().typeId)) {
      Hive.registerAdapter(DisciplinaAdapter());
    }

    box = await Hive.openBox<Disciplina>('disciplinas');
  }

  Future<void> addDisciplinaLista(List<dynamic> disciplinas) async {
    for (var item in disciplinas) {
      Disciplina disciplina = Disciplina.fromJson(item);
      await box.add(disciplina);
    }
  }

  List<Disciplina> getAllDisciplinas() {
    return box.values.toList();
  }

  Future<void> close() async {
    await box.close();
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<bool> addDisciplina(Disciplina disciplina) async {
    try {
      if (!box.isOpen) {
        ConsoleLog.mensagem(
          titulo: 'aisciplina-add-controller',
          mensagem: 'Erro ao adicionar disciplina: A caixa está fechada',
          tipo: StatusConsole.error,
        );
        return false;
      }
      await box.add(disciplina);
      return true;
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'disciplina-add-controller',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return false;
    }
  }

  Future<List<Disciplina>> getAllDisciplinasPeloTurmaId({
    required String turmaId,
    required String idtId,
  }) async {
    if (box.isOpen) {
      try {
        final disciplinasFiltradas = box.values
            .where((disciplina) =>
                disciplina.idtTurmaId == turmaId && disciplina.idt_id == idtId)
            .toList();

        final idsVistos = <String>{};
        final disciplinasUnicas = <Disciplina>[];

        for (final disciplina in disciplinasFiltradas) {
          if (!idsVistos.contains(disciplina.id)) {
            idsVistos.add(disciplina.id);
            disciplinasUnicas.add(disciplina);
          }
        }

        return disciplinasUnicas;
      } catch (e) {
        print('Erro ao buscar disciplinas: $e');
        return [];
      }
    } else {
      print('Box não inicializado');
      return [];
    }
  }

  Future<String> getDisciplinaId({
    required int id,
  }) async {
    if (box.isOpen) {
      try {
        var disciplina = box.values.toList();

        return disciplina[0].descricao.toString();
      } catch (e) {
        print(e);
        return 'Erro ao buscar disciplina';
      }
    } else {
      print('Box não inicializado');
      return 'Box não inicializado';
    }
  }

  Future<String> getDisciplinaDescricao({required String? disciplinaId}) async {
    if (disciplinaId == null || disciplinaId.isEmpty) {
      return "SEM DISCIPLINA";
    }

    if (!box.isOpen) {
      print('Box não inicializado');
      return 'Box não inicializado';
    }

    try {
      var disciplina = box.values.firstWhere(
        (d) => d.id.toString() == disciplinaId,
        orElse: () => Disciplina.vazia(),
      );

      return disciplina.descricao.toString() ?? 'Disciplina não encontrada';
    } catch (e) {
      print('Erro ao buscar disciplina: $e');
      return 'Erro ao buscar disciplina';
    }
  }
}
