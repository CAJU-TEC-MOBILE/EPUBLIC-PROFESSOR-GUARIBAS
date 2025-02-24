import 'package:hive_flutter/hive_flutter.dart';
import '../../help/console_log.dart';
import '../../models/serie_aula_model.dart';

class SerieAulaController {
  late Box<SerieAula> _serieAulaBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(SerieAulaAdapter().typeId)) {
      Hive.registerAdapter(SerieAulaAdapter());
    }

    _serieAulaBox = await Hive.openBox<SerieAula>('series_aulas');
  }

  Future<bool> addSerie(SerieAula serie) async {
    try {
      if (_serieAulaBox.isOpen) {
        await _serieAulaBox.add(serie);
        ConsoleLog.mensagem(
          titulo: 'Sucesso!',
          mensagem: 'A série foi salva com sucesso na aula. Ótimo trabalho!',
          tipo: 'sucesso',
        );

        return true;
      } else {
        print('Erro ao adicionar instrutor: A caixa está fechada');
        return false;
      }
    } catch (e) {
      print('Erro ao adicionar instrutor: $e');
      return false;
    }
  }

  List<SerieAula> getAll() {
    return _serieAulaBox.values.toList();
  }

  Future<void> clear() async {
    if (_serieAulaBox.isOpen) {
      await _serieAulaBox.clear();
      print('Todos os dados de series foram apagados.');
    } else {
      print('Erro ao apagar dados: A caixa está fechada');
    }
  }

  Future<void> close() async {
    print('Closing instrutor box...');
    if (_serieAulaBox.isOpen) {
      await _serieAulaBox.close();
      print('Serie box closed.');
    }
  }

  Future<List<SerieAula>> getAllSeriesPeloAulaId(
      {required String? criadaPeloCelularId,
      required String? disciplinaId}) async {
    return _serieAulaBox.values
        .where((serie) =>
            serie.aulaId == criadaPeloCelularId &&
            serie.disciplinaId == disciplinaId)
        .toList();
  }

  Future<void> deleteSeriePeloId({required String? criadaPeloCelularId}) async {
    List<SerieAula> series = _serieAulaBox.values.toList();

    if (series.isEmpty) {
      ConsoleLog.mensagem(
        titulo: 'getSeriePeloId',
        mensagem: 'Series não encontrada para exclusão',
        tipo: 'erro',
      );
      return;
    }

    bool found = false;

    for (int i = 0; i < series.length; i++) {
      SerieAula item = series[i];

      if (item.aulaId.toString() == criadaPeloCelularId.toString()) {
        await _serieAulaBox.deleteAt(i);
        ConsoleLog.mensagem(
          titulo: 'getSeriePeloId',
          mensagem: 'Série removida com sucesso: ${item.aulaId}',
          tipo: 'sucesso',
        );
        found = true;
      }
    }

    if (!found) {
      ConsoleLog.mensagem(
        titulo: 'getSeriePeloId',
        mensagem: 'Série não encontrada com aulaId: $criadaPeloCelularId',
        tipo: 'erro',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getSeriesExtras({required String? criadaPeloCelular}) async {
    List<Map<String, dynamic>> data = [];

    List<SerieAula> series = _serieAulaBox.values
        .where((item) => item.aulaId.toString() == criadaPeloCelular.toString())
        .toList();

    Map<String, List<int>> groupedData = {}; // Chave como String

    for (var item in series) {
      if (!groupedData.containsKey(item.disciplinaId)) {
        groupedData[item.disciplinaId] = [];
      }

      if (item.serieId != null) {
        groupedData[item.disciplinaId]!.add(int.parse(item.serieId!));
      }
    }

    groupedData.forEach((disciplinaId, serieIds) {
      var entry = {
        'id': disciplinaId,
        'array': serieIds,
      };
      data.add(entry);
    });

    return data;
  }

}