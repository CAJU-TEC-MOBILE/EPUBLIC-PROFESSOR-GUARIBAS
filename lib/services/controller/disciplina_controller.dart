import 'package:hive_flutter/hive_flutter.dart';
import '../../models/disciplina_model.dart';

class DisciplinaController {
  late Box<Disciplina> _disciplinaBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(DisciplinaAdapter().typeId)) {
      Hive.registerAdapter(DisciplinaAdapter());
    }

    _disciplinaBox = await Hive.openBox<Disciplina>('disciplinas');
  }

  Future<void> addDisciplinaLista(List<dynamic> disciplinas) async {
    for (var item in disciplinas) {
      Disciplina disciplina = Disciplina.fromJson(item);
      await _disciplinaBox.add(disciplina);
    }
  }

  List<Disciplina> getAllDisciplinas() {
    return _disciplinaBox.values.toList();
  }

  Future<void> close() async {
    await _disciplinaBox.close();
  }

  Future<void> clear() async {
    await _disciplinaBox.clear();
  }

  Future<bool> addDisciplina(Disciplina disciplina) async {
    try {
      if (_disciplinaBox.isOpen) {
        await _disciplinaBox.add(disciplina);
        print('Disciplina salva com sucesso.');
        return true;
      } else {
        print('Erro ao adicionar disciplina: A caixa está fechada');
        return false;
      }
    } catch (e) {
      print('Erro ao adicionar disciplina: $e');
      return false;
    }
  }

  Future<List<Disciplina>> getAllDisciplinasPeloTurmaId({
    required String turmaId,
    required String idtId,
  }) async {
    // Garantir que o Hive foi inicializado
    if (_disciplinaBox.isOpen) {
      try {
        return _disciplinaBox.values
            .where((disciplina) =>
                disciplina.idtTurmaId == turmaId && disciplina.idt_id == idtId)
            .toList();
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
    if (_disciplinaBox.isOpen) {
      try {
        var disciplina = _disciplinaBox.values.toList();
       
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
}
