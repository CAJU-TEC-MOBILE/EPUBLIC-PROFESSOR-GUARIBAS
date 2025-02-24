import 'package:hive_flutter/hive_flutter.dart';

class GestaoCotnroller {
  late Box box;

  Future<void> init() async {
    await Hive.initFlutter();

    box = await Hive.openBox('gestoes');
  }

  Future<dynamic> getFirstOrEmpty() async {
    List<dynamic> result = box.values.toList();
    return result.isEmpty ? [] : result[0];
  }

  Future<dynamic> getFirstOrEmptyAno({required String anoDescricao}) async {
    List<dynamic> result = box.values.toList();
    result = result
        .where((item) =>
            item['ano_descricao'].toString() == anoDescricao.toString())
        .toList();
    return result.isEmpty ? [] : result[0];
  }

  Future<void> clear() async {
    await box.clear();
  }
}
