import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/auth_model.dart';

class UsuariosServiceAdapter {
  Future<void> salvar(List<dynamic> usuarios) async {
    Box usuariosBox = Hive.box('usuarios');

    usuariosBox.put('usuarios', usuarios);

    List<dynamic> usuariosSalvos = usuariosBox.get('usuarios');
    print(
        '------------SALVANDO USUÁRIOS PARA AUTORIZAÇÃO DE PEDIDOS----------------');
    print('TOTAL DE USUÁRIOS: ${usuariosSalvos.length}');
    listar();
  }

  List<Auth> listar() {
    Box usuariosBox = Hive.box('usuarios');
    List<dynamic> usuariosSalvos = usuariosBox.get('usuarios');

    List<Auth> usuariosListModel =
        usuariosSalvos.map((pedido) => Auth.fromJson(pedido)).toList();
    return usuariosListModel;
  }

  String? getNomePeloId({required String id}) {
    try {
      Box usuariosBox = Hive.box('usuarios');
      List<dynamic> usuariosSalvos = usuariosBox.get('usuarios');
      List<Auth> usuariosListModel =
          usuariosSalvos.map((usuario) => Auth.fromJson(usuario)).toList();
      String? nome;
      for (var item in usuariosListModel) {
        if (item.id.toString() == id.toString()) {
          nome = item.name.toString().toUpperCase();
        }
      }

      return nome;
    } catch (e) {
      print('Erro ao buscar usuário pelo ID: $e');
      return null;
    }
  }
}
