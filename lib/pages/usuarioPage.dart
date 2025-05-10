import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/componentes/global/user_info_componente.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';

import '../componentes/drawer/custom_drawer.dart';
import '../componentes/global/perfil/custom_card_perfil.dart';

class UsuarioPage extends StatefulWidget {
  final bool? iconBlock;
  const UsuarioPage({super.key, this.iconBlock});

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  Map<dynamic, dynamic> authData = {};
  late Box _authBox;

  @override
  void initState() {
    super.initState();
    _initializeAuthBox();
    getInfoUsuario();
  }

  void _initializeAuthBox() {
    _authBox = Hive.box('auth');
  }

  Future<void> getInfoUsuario() async {
    try {
      final data = await _authBox.get('auth');
      authData = data ?? {};
      setState(() {});
    } catch (e) {
      throw Exception('Error retrieving user info: $e');
    }
  }

  Future<void> removerDadosAuth() async {
    try {
      await _authBox.clear();
      setState(() {
        authData.clear();
      });
    } catch (e) {
      throw Exception('Error removing auth data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        backgroundColor: AppTema.primaryDarkBlue,
        centerTitle: true,
        title: const Text('Perfil'),
        foregroundColor: Colors.white,
        actions: const [
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                const UserInfoComponente(),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.22,
                  child: const CustomCardPerfil(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
