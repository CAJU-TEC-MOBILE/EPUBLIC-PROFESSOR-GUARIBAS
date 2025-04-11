import 'dart:io';

import 'package:flutter/material.dart';

import '../../help/console_log.dart';
import '../../models/disciplina_aula_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DisciplinaAulaController {
  late Box<DisciplinaAula> _disciplinaAulaBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(DisciplinaAulaAdapter().typeId)) {
      Hive.registerAdapter(DisciplinaAulaAdapter());
    }
    _disciplinaAulaBox = await Hive.openBox<DisciplinaAula>('disciplina_aula');
  }

  Future<void> addDisciplinaAula(DisciplinaAula disciplinaAula) async {
    await _disciplinaAulaBox.add(disciplinaAula);
  }

  List<DisciplinaAula> getAllAulas() {
    return _disciplinaAulaBox.values.toList();
  }

  Future<int> clear() async {
    return await _disciplinaAulaBox.clear();
  }

  Future<List<Map<String, dynamic>>> getHorariosExtras(
      {required String criadaPeloCelular}) async {
    List<Map<String, dynamic>> data = [];

    List<DisciplinaAula> disciplinas = _disciplinaAulaBox.values
        .where((item) => item.criadaPeloCelular == criadaPeloCelular)
        .toList();

    for (var disciplina in disciplinas) {
      if (disciplina.data.isNotEmpty) {
        List<int> horarios = [];
        for (var item in disciplina.data) {
          if (item['horarios'] != null) {
            horarios.addAll(List<int>.from(item['horarios']));
          }
        }

        var entry = {
          'id': int.parse(disciplina.id),
          'array': horarios,
        };

        data.add(entry);
      }
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> getHorariosExtrasAll() async {
    List<Map<String, dynamic>> data = [];

    List<DisciplinaAula> disciplinas = _disciplinaAulaBox.values.toList();

    for (var disciplina in disciplinas) {
      if (disciplina.data.isNotEmpty) {
        List<int> horarios = [];
        for (var item in disciplina.data) {
          if (item['horarios'] != null) {
            horarios.addAll(List<int>.from(item['horarios']));
          }
        }

        var entry = {
          'id': disciplina.id,
          'criadaPeloCelular': disciplina.criadaPeloCelular,
          'horarios': horarios,
        };

        data.add(entry);
      }
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> getDisciplinaHorarios(
      {required String criadaPeloCelular}) async {
    List<DisciplinaAula> disciplinas = _disciplinaAulaBox.values
        .where((item) => item.criadaPeloCelular == criadaPeloCelular)
        .toList();

    List<Map<String, dynamic>> data = [];
    debugPrint('data: $data');
    // Verifica se há disciplinas
    if (disciplinas.isEmpty) {
      debugPrint(
          'Nenhuma disciplina encontrada para o celular: $criadaPeloCelular');
      return data;
    }

    for (var disciplina in disciplinas) {
      if (disciplina.data.isNotEmpty) {
        for (var item in disciplina.data) {
          var horarios = item['horarios'];
          if (horarios is List<dynamic>) {
            for (var horario in horarios) {
              if (horario is Map<String, dynamic>) {
                data.add(horario);
              }
            }
          }
        }
      }
    }

    return data; // Retorna a lista de horários
  }

  Future<List<String>> getConteudoPolivalencia(
      {required String criadaPeloCelular}) async {
    List<String> data = [];

    List<DisciplinaAula> disciplinas = _disciplinaAulaBox.values
        .where((item) => item.criadaPeloCelular == criadaPeloCelular)
        .toList();

    for (var disciplina in disciplinas) {
      if (disciplina.data.isNotEmpty) {
        for (var item in disciplina.data) {
          data.add(item['conteudo'] ?? '');
        }
      }
    }

    return data;
  }

  Future<List<String>> getDisciplinas(
      {required String criadaPeloCelular}) async {
    List<String> data = [];
    List<DisciplinaAula> disciplinas = _disciplinaAulaBox.values
        .where((item) => item.criadaPeloCelular == criadaPeloCelular)
        .toList();

    for (var disciplina in disciplinas) {
      data.add(disciplina.id.toString());
    }
    return data;
  }

  Future<List<DisciplinaAula>> getDisciplinaAulaCriadaPeloCelular({
    required String? criadaPeloCelular,
  }) async {
    try {
      if (criadaPeloCelular == null) {
        print('sem criadaPeloCelular');
        return [];
      }

      final data = _disciplinaAulaBox.values
          .where((item) => item.criadaPeloCelular == criadaPeloCelular)
          .cast<DisciplinaAula>()
          .toList();

      return data;
    } catch (e) {
      print('Erro ao buscar aulas: $e');
      return [];
    }
  }

  Future<void> removerAulasPeloCriadaPeloCelular(
      {required String? criadaPeloCelular}) async {
    try {
      if (criadaPeloCelular == null) {
        ConsoleLog.mensagem(
            tipo: 'erro',
            mensagem: 'Chave "criadaPeloCelular" não fornecida',
            titulo: 'removerAulasPeloCriadaPeloCelular');
        return;
      }

      final aulasParaRemover = _disciplinaAulaBox.values.toList();

      if (aulasParaRemover.isEmpty) {
        ConsoleLog.mensagem(
            tipo: 'erro',
            mensagem:
                'Nenhuma aula encontrada para a chave "criadaPeloCelular" fornecida.',
            titulo: 'removerAulasPeloCriadaPeloCelular');
        return;
      }

      List<int> indicesParaRemover = []; // Lista para armazenar os índices

      for (int index = 0; index < aulasParaRemover.length; index++) {
        var aula = aulasParaRemover[index];
        if (aula.criadaPeloCelular == criadaPeloCelular) {
          ConsoleLog.mensagem(
              tipo: 'informacao',
              mensagem:
                  'ID: ${aula.id}, Criada pelo Celular: ${aula.criadaPeloCelular}, Outras informações: ${aula.toString()}',
              titulo: 'removerAulasPeloCriadaPeloCelular');
          indicesParaRemover.add(index); // Adiciona o índice à lista
        }
      }

      // Remove as aulas pelos índices armazenados, começando do final
      for (int i = indicesParaRemover.length - 1; i >= 0; i--) {
        await _disciplinaAulaBox.deleteAt(indicesParaRemover[i]);
      }

      ConsoleLog.mensagem(
          tipo: 'sucesso',
          mensagem: 'Aulas removidas com sucesso',
          titulo: 'removerAulasPeloCriadaPeloCelular');
    } catch (e) {
      ConsoleLog.mensagem(
          tipo: 'erro',
          mensagem: 'Erro ao excluir: $e',
          titulo: 'removerAulasPeloCriadaPeloCelular');
      throw Exception('Error: Ao delete disciplinas aula de uma aula e');
    }
  }
}
