import 'package:hive_flutter/hive_flutter.dart';
import '../../models/serie_model.dart';

class SerieController {
  late Box<Serie> _serieBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(SerieAdapter().typeId)) {
      Hive.registerAdapter(SerieAdapter());
    }

    _serieBox = await Hive.openBox<Serie>('series');
  }

  Future<bool> addSerie(Serie serie) async {
    try {
      if (_serieBox.isOpen) {
        await _serieBox.add(serie);
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

  List<Serie> getAll() {
    return _serieBox.values.toList();
  }

  Future<void> clear() async {
    if (_serieBox.isOpen) {
      await _serieBox.clear();
      print('Todos os dados de series foram apagados.');
    } else {
      print('Erro ao apagar dados: A caixa está fechada');
    }
  }

  Future<void> close() async {
    print('Closing instrutor box...');
    if (_serieBox.isOpen) {
      await _serieBox.close();
      print('Serie box closed.');
    }
  }

  Future<List<Serie>> getAllSeriesPeloTurmaId({required String turmaId}) async {
    return _serieBox.values.where((serie) => serie.turmaId == turmaId).toList();
  }

  Future<List<Serie>> getAllSeriesPeloTurmaIdIsInfantil({required String turmaId, required bool? isInfantil}) async {
    return _serieBox.values.where((serie) => serie.turmaId == turmaId && serie.is_infantil == isInfantil).toList();
  }
}