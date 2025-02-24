import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/auth_model.dart';

class UsuariosServiceAdapter {
  Future<void> salvar(List<dynamic> usuarios) async {
    Box _usuariosBox = Hive.box('usuarios');

    _usuariosBox.put('usuarios', usuarios);

    List<dynamic> usuariosSalvos = _usuariosBox.get('usuarios');
    print(
        '------------SALVANDO USUÁRIOS PARA AUTORIZAÇÃO DE PEDIDOS----------------');
    print('TOTAL DE USUÁRIOS: ${usuariosSalvos.length}');
    listar();
  }

  List<Auth> listar() {
    Box _usuariosBox = Hive.box('usuarios');
    List<dynamic> usuariosSalvos = _usuariosBox.get('usuarios');

    List<Auth> usuariosListModel =
        usuariosSalvos.map((pedido) => Auth.fromJson(pedido)).toList();
    return usuariosListModel;
  }
}
