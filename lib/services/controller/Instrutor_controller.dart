import 'package:hive_flutter/hive_flutter.dart';
import '../../models/instrutor_model.dart';

class InstrutorController {
  late Box<Instrutor> _instrutorBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(InstrutorAdapter().typeId)) {
      Hive.registerAdapter(InstrutorAdapter());
    }

    _instrutorBox = await Hive.openBox<Instrutor>('instrutores');
  }

  Future<bool> addInstrutor(Instrutor instrutor) async {
    try {
      if (_instrutorBox.isOpen) {
        await _instrutorBox.add(instrutor);
        return true;
      } else {
        print('Erro ao adicionar instrutor: A caixa está fechada');
        return false;
      }
    } catch (e) {
      print('Erro ao adicionar instrutor: $e'); // Log do erro
      return false;
    }
  }

  List<Instrutor> getAllInstrutores() {
    return _instrutorBox.values.toList();
  }

  Future<Instrutor> getFirst()async{
    return _instrutorBox.values.first;
  }

  Future<void> clear() async {
    if (_instrutorBox.isOpen) {
      await _instrutorBox.clear();
      print('Todos os dados de instrutores foram apagados.');
    } else {
      print('Erro ao apagar dados: A caixa está fechada');
    }
  }

  Future<void> close() async {
    print('Closing instrutor box...');
    if (_instrutorBox.isOpen) {
      await _instrutorBox.close();
      print('Instrutor box closed.');
    }
  }
}
