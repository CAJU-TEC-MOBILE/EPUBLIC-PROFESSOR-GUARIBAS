import 'package:hive_flutter/hive_flutter.dart';
import '../../models/aula_model.dart';

class AulaController {
  late Box<Aula> _aulaBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(AulaAdapter().typeId)) {
      Hive.registerAdapter(AulaAdapter());
    }

    _aulaBox = await Hive.openBox<Aula>('aulas_offlines');
  }

  Future<List<Aula>> getAulaCriadaPeloCelular(
      {required String? criadaPeloCelular}) async {
    try {
      final aulas = _aulaBox.values
          .where((aula) => aula.criadaPeloCelular == criadaPeloCelular)
          .toList();
      return aulas;
    } catch (e) {
      throw Exception("Error getting Aula created via mobile: $e");
    }
  }

  Future<Aula?> getAulaPeloCriadaPeloCelular(
      {required String criadaPeloCelular}) async {
    try {
      return _aulaBox.values.cast<Aula?>().firstWhere(
            (aula) =>
                aula?.criadaPeloCelular.toString() ==
                criadaPeloCelular.toString(),
            orElse: () => null,
          );
    } catch (e) {
      print("Error getting Aula created via mobile: $e");
      return null;
    }
  }

  Future<void> addAula(Aula aula) async {
    await _aulaBox.add(aula);
    print('Aula criada com sucesso: ${aula.toString()}');
  }

  Future<List<Aula>> getAulaInstrutorDisciplinaTurmaId(
      {String? instrutorDisciplinaTurma_id}) async {
    List<Aula> aulasFiltradas = _aulaBox.values
        .where((aula) =>
            aula.instrutorDisciplinaTurma_id == instrutorDisciplinaTurma_id)
        .toList();

    return aulasFiltradas;
  }

  Future<void> clear(Aula aula) async {
    _aulaBox = await Hive.openBox<Aula>('aulas_offlines');
    await _aulaBox.clear();
  }

  Future<void> clearAll() async {
    _aulaBox = await Hive.openBox<Aula>('aulas_offlines');
    await _aulaBox.clear();
  }

  Future<void> updateAula(int index, Aula updatedAula) async {
    try {
      await _aulaBox.putAt(index, updatedAula);
    } catch (e) {
      Exception("Error updating Aula: $e");
    }
  }

  List<Aula> getAllAulas() {
    return _aulaBox.values.toList();
  }

  Future<void> close() async {
    await _aulaBox.close();
  }

  Future<bool> updateAulaCriadaPeloCelular({
    required String? criadaPeloCelular,
    required Aula aulaAtualizada,
  }) async {
    try {
      print('---BUSCANDO E ATUALIZANDO AULA LOCAL---');

      if (criadaPeloCelular == null) {
        print('Sem criadaPeloCelular');
        return false;
      }

      // Localiza as aulas com o `criadaPeloCelular` fornecido
      final aulas = _aulaBox.values
          .where((aula) => aula.criadaPeloCelular == criadaPeloCelular)
          .toList();

      if (aulas.isNotEmpty) {
        for (var aula in aulas) {
          aula.id = '';
          aula.instrutor_id = aulaAtualizada.instrutor_id;
          aula.disciplina_id = aulaAtualizada.disciplina_id;
          aula.turma_id = aulaAtualizada.turma_id;
          aula.tipoDeAula = aulaAtualizada.tipoDeAula;
          aula.dataDaAula = aulaAtualizada.dataDaAula;
          aula.horarioID = aulaAtualizada.horarioID;
          aula.horarios_infantis = aulaAtualizada.horarios_infantis;
          aula.conteudo = aulaAtualizada.conteudo;
          aula.metodologia = aulaAtualizada.metodologia;
          aula.saberes_conhecimentos = aulaAtualizada.saberes_conhecimentos;
          aula.dia_da_semana = aulaAtualizada.dia_da_semana;
          aula.situacao = aulaAtualizada.situacao;
          aula.etapa_id = aulaAtualizada.etapa_id;
          aula.instrutorDisciplinaTurma_id =
              aulaAtualizada.instrutorDisciplinaTurma_id;
          aula.eixos = aulaAtualizada.eixos;
          aula.estrategias = aulaAtualizada.estrategias;
          aula.recursos = aulaAtualizada.recursos;
          aula.atividade_casa = aulaAtualizada.atividade_casa;
          aula.atividade_classe = aulaAtualizada.atividade_classe;
          aula.observacoes = aulaAtualizada.observacoes;
          aula.experiencias = aulaAtualizada.experiencias;
          aula.campos_de_experiencias = aulaAtualizada.campos_de_experiencias;
          aula.series = aulaAtualizada.series;

          // Obtém a chave real do item para atualizar
          final key =
              await _aulaBox.keyAt(_aulaBox.values.toList().indexOf(aula));

          // Atualiza o item existente
          await _aulaBox.put(key, aula);
        }
        print('---AULA ATUALIZADA COM SUCESSO---');

        // Verifica a aula atualizada
        final updatedAula = _aulaBox.values
            .where((aula) => aula.criadaPeloCelular == criadaPeloCelular)
            .first;
        print('---DADOS ATUALIZADOS DA AULA---');
        print('Instrutor ID: ${updatedAula.instrutor_id}');
        print('Disciplina ID: ${updatedAula.disciplina_id}');
        print('Turma ID: ${updatedAula.turma_id}');
        print('Tipo de Aula: ${updatedAula.tipoDeAula}');
        print('Data da Aula: ${updatedAula.dataDaAula}');

        return true;
      } else {
        print('Nenhuma aula encontrada para atualizar.');
        return false;
      }
    } catch (e) {
      print("Erro ao atualizar a Aula criada via celular: $e");
      return false;
    }
  }

  Future<List<int>> getAulaSeries({required String? criadaPeloCelular}) async {
    List<int> dados = [];

    print('criadaPeloCelular === $criadaPeloCelular');

    if (criadaPeloCelular == null) {
      return dados;
    }

    List<Aula> aulas = _aulaBox.values
        .where((aula) =>
            aula.criadaPeloCelular?.toString() == criadaPeloCelular.toString())
        .toList();

    for (Aula aula in aulas) {
      if (aula.series != null) {
        for (var serie in aula.series!) {
          if (serie.serieId != null && int.tryParse(serie.serieId!) != null) {
            dados.add(int.parse(serie.serieId!));
          } else {
            print('Invalid serieId: ${serie.serieId}');
          }
        }
      }
    }

    return dados;
  }

  Future<bool> registrarFrequencia({required String criadaPeloCelular}) async {
    List<Aula> aulas = _aulaBox.values
        .where(
          (aula) =>
              aula.criadaPeloCelular.toString() == criadaPeloCelular.toString(),
        )
        .toList();
    if (aulas.isEmpty) {
      return false;
    }
    for (var aula in aulas) {
      aula.status_frequencia = true;
      final key = await _aulaBox.keyAt(_aulaBox.values.toList().indexOf(aula));
      await _aulaBox.put(key, aula);
    }
    return true;
  }

  Future<Aula?> aula({required String criadaPeloCelular}) async {
    List<Aula> aulas = _aulaBox.values
        .where(
          (aula) =>
              aula.criadaPeloCelular.toString() == criadaPeloCelular.toString(),
        )
        .toList();

    return aulas.first;
  }
}
