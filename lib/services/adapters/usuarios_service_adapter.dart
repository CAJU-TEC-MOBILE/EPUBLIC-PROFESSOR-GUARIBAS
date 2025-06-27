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

  List<AuthModel> listar() {
    Box usuariosBox = Hive.box('usuarios');
    List<dynamic> usuariosSalvos = usuariosBox.get('usuarios');

    List<AuthModel> usuariosListModel =
        usuariosSalvos.map((pedido) => AuthModel.fromJson(pedido)).toList();
    return usuariosListModel;
  }

  String? getNomePeloId({required String id}) {
    try {
      Box usuariosBox = Hive.box('usuarios');
      List<dynamic> usuariosSalvos = usuariosBox.get('usuarios');
      List<AuthModel> usuariosListModel =
          usuariosSalvos.map((usuario) => AuthModel.fromJson(usuario)).toList();
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
