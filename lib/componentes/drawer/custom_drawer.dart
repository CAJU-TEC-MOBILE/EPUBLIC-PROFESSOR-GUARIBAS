import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/pages/home_page.dart';
import '../../constants/app_tema.dart';
import '../../help/console_log.dart';
import '../../models/auth_model.dart';
import '../../models/gestao_ativa_model.dart';
import '../../models/professor_model.dart';
import '../../pages/pedido_page.dart';
import '../../pages/sobre/sobre_o_app_page.dart';
import '../../pages/usuarioPage.dart';
import '../../services/adapters/auth_service_adapter.dart';
import '../../services/controller/professor_controller.dart';
import '../../services/shared_preference_service.dart';
import '../../wigets/dialog/custom_status_dialog.dart';
import '../dropdown/custom_anos_dropdown.dart';
import 'custom_user_info_drawer.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final preference = SharedPreferenceService();
  AuthModel? authModel;
  GestaoAtiva? gestaoAtivaModel;
  double fontText = 16.0;
  bool isLoading = true;
  double heightCard = 200.0;
  double edgeInsetCard = 24.0;
  Professor? professor;
  File? _image;
  bool isLoadingImage = false;
  Map<dynamic, dynamic> authData = {};
  late Box _authBox;
  @override
  void initState() {
    super.initState();
    _initializeAuthBox();
    getInfoUsuario();
    carregarDados();
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

  Future<void> carregarDados() async {
    try {
      ProfessorController professorController = ProfessorController();
      AuthServiceAdapter authService = AuthServiceAdapter();
      await professorController.init();
      Professor? professorData = await professorController.getProfessor();
      if (professorData != null) {
        setState(() {
          professor = professorData;
        });
      } else {
        ConsoleLog.mensagem(
          titulo: 'Aviso',
          mensagem: 'Nenhum dado disponível para o professor.',
          tipo: 'aviso',
        );
      }
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'Erro ao carregar dados do professor',
        mensagem: e.toString(),
        tipo: 'erro',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.80,
      height: MediaQuery.of(context).size.height,
      child: Drawer(
        child: Column(
          children: [
            Container(
              color: AppTema.primaryAmarelo,
              child: Padding(
                padding: const EdgeInsets.only(top: 34.0, bottom: 8.0),
                child: Column(
                  children: [
                    const CustomUserInfoDrawer(),
                    const SizedBox(height: 4.0),
                    professor != null
                        ? Text(
                            professor!.nome.toString(),
                            style: const TextStyle(
                              color: AppTema.primaryDarkBlue,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(height: 4.0),
                    const CustomAnosDropdown(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsuarioPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(MdiIcons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(MdiIcons.listBox),
              title: const Text('Pedidos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PedidoPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sobre'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SobreAppPage(),
                  ),
                );
              },
            ),
            const Divider(
              color: Colors.grey,
            ),
            ListTile(
              leading: const Icon(MdiIcons.logoutVariant),
              title: const Text('Sair'),
              onTap: () {
                CustomStatusDialog.informacao(
                  context,
                  mensagem: 'Tem certeza que deseja sair?',
                  onConfirm: () async {
                    await preference.init();
                    await removerDadosAuth();
                    await preference.limparDados();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
