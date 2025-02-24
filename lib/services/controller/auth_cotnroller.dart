import '../../models/horario_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthCotnroller {
  late Box _authBox;

  Future<void> init() async {
    await Hive.initFlutter();

    _authBox = await Hive.openBox('auth');
  }

  Future<dynamic> getAuthAll() async {
    return _authBox.values.toList();
  }
}
