import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/verificar_conexao_com_internet.dart';
import 'package:professor_acesso_notifiq/services/adapters/autorizacoes_service.dart';
import 'package:professor_acesso_notifiq/services/adapters/justificativas_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/matriculas_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/pedidos_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/sistema_bncc_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/usuarios_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/http/auth/auth_http.dart';
import 'package:professor_acesso_notifiq/services/widgets/snackbar_service_widget.dart';

import '../componentes/dialogs/custom_snackbar.dart';
import '../services/adapters/gestoes_service_adpater.dart';
import '../services/configuracao/configuracao_app.dart';
import '../services/controller/ano_selecionado_controller.dart';
import '../services/controller/horario_configuracao_controller.dart';
import '../services/controller/professor_controller.dart';
import '../services/http/gestoes/gestoes_disciplinas_http.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool enabledTextFormField = true;
  String appVerso = '';

  final _authBox = Hive.box('auth');
  final _gestoesBox = Hive.box('gestoes');
  final _horariosBox = Hive.box('horarios');

  Future<void> _salvarAuthBox(Map<String, dynamic> auth) async {
    _authBox.put('auth', auth);
  }

  Future<void> _salvarGestoesBox(List<dynamic> gestoes) async {
    _gestoesBox.put('gestoes', gestoes);
  }

  Future<void> _salvarHorariosBox(List<dynamic> horarios) async {
    _horariosBox.put('horarios', horarios);
  }

  void configuracaoEnv() async {
    appVerso = dotenv.env['VERSAO'] ?? 'Default Verso';
    setState(() {
      appVerso;
    });
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      enabledTextFormField = false;
    });

    await Future.delayed(const Duration(seconds: 3));

    String email = _emailController.text;
    String password = _passwordController.text;

    dynamic isConnected = await checkInternetConnection();
    if (isConnected) {
      try {
        GestoesService gestoesService = GestoesService();
        GestaoDisciplinaHttp gestaoDisciplinaHttp = GestaoDisciplinaHttp();
        ConfiguracaoApp configuracaoApp = ConfiguracaoApp();
        AnoSelecionadoController anoSelecionadoController =
            AnoSelecionadoController();
        ProfessorController professorController = ProfessorController();

        var response = await AuthHttp.logar(email, password);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseJson =
              await jsonDecode(response.body);
          await professorController.init();
          await professorController.create(responseJson['user']['professor']);
          await _salvarAuthBox(responseJson['user'] ?? {});
          await _salvarGestoesBox(responseJson['gestoes'] ?? []);
          await _salvarHorariosBox(responseJson['horarios'] ?? []);
          await MatriculasServiceAdapter()
              .salvar(responseJson['matriculas'] ?? []);
          await JustificativasServiceAdapter()
              .salvar(responseJson['justificativas'] ?? []);
          await PedidosServiceAdapter()
              .salvar(responseJson['pedidos_para_autorizacao'] ?? []);
          await UsuariosServiceAdapter()
              .salvar(responseJson['users_para_autorizacao'] ?? []);
          await AutorizacoesServiceAdapter().salvar(
              responseJson['autorizacoes_socilitadas_pelo_usuario'] ?? []);
          await SistemaBnccServiceAdapter()
              .salvar(responseJson['sistema_bncc'] ?? []);
          await gestaoDisciplinaHttp.getGestaoDisciplinas();
          await gestoesService.atualizarGestoesDoDispositivo(context);
          await configuracaoApp.anos();
          await AuthHttp.setBaixarImage(
            professorId:
                responseJson['user']['professor']['id']?.toString() ?? '',
            imagemPerfil: responseJson['user']['professor']['imagem_perfil']
                    ?.toString() ??
                '',
            cpf: responseJson['user']['professor']['cpf']?.toString() ?? '',
            userId: responseJson['user']['id']?.toString() ?? '',
          );

          // await anoSelecionadoController.setAnoPorAuth(anoId: responseJson['user']['ano_id'].toString());

          // CustomSnackBar.showSuccessSnackBar(
          //   context,
          //   'Usuário logado com sucesso!',
          // );
          // ignore: use_build_context_synchronously
          // SnackBarServiceWidget.mostrarSnackBar(context,
          //     mensagem: 'Usuário logado com sucesso!',
          //     backgroundColor: AppTema.success,
          //     icon: Icons.check_circle,
          //     iconColor: Colors.white);

          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, '/home');
        } else if (response.statusCode == 401) {
          enabledTextFormField = true;
          // ignore: use_build_context_synchronously
          // SnackBarServiceWidget.mostrarSnackBar(context,
          //     mensagem: 'CPF ou/e senha incorreto(s)',
          //     backgroundColor: const Color.fromARGB(255, 219, 178, 67),
          //     icon: Icons.error_outline,
          //     iconColor: Colors.white);
          CustomSnackBar.showInfoSnackBar(
            context,
            'CPF ou/e senha incorreto(s).',
          );
          setState(() {});
        } else {
          enabledTextFormField = true;
          setState(() {});
          //print('2');
          //print(response.body);
          // ignore: use_build_context_synchronously
          // SnackBarServiceWidget.mostrarSnackBar(context,
          //     mensagem: 'Erro de conexão',
          //     backgroundColor: Colors.red,
          //     icon: Icons.error_outline,
          //     iconColor: Colors.white);
          CustomSnackBar.showErrorSnackBar(
            context,
            'Erro de conexão.',
          );
        }
      } catch (e) {
        enabledTextFormField = true;
        //print('error-login: $e');
        setState(() {});
        //print(e);
        // ignore: use_build_context_synchronously
        // SnackBarServiceWidget.mostrarSnackBar(context,
        //     mensagem: 'Erro de conexão',
        //     backgroundColor: Colors.red,
        //     icon: Icons.error_outline,
        //     iconColor: Colors.white);
        CustomSnackBar.showErrorSnackBar(
          context,
          'Erro de conexão.',
        );
      }
    } else {
      enabledTextFormField = true;
      setState(() {});
      //print('else conected');
      // ignore: use_build_context_synchronously
      // SnackBarServiceWidget.mostrarSnackBar(context,
      //     mensagem: 'Erro de conexão',
      //     backgroundColor: Colors.red,
      //     icon: Icons.error_outline,
      //     iconColor: Colors.white);
      CustomSnackBar.showErrorSnackBar(
        context,
        'Erro de conexão.',
      );
    }
    setState(() {
      _isLoading = false;
      enabledTextFormField = true;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   configuracaoEnv();
  // }

  @override
  Widget build(BuildContext context) {
    configuracaoEnv();
    //_emailController.text = '08171188370';
    //_passwordController.text = '02091999';

    // _emailController.text = '60011558369';
    // _passwordController.text = '13051972';

    _emailController.text = '91710855304';
    _passwordController.text = '25021966';

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Conteúdo do formulário
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 180),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/icon_notifiq_sem_fundo.png',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 45),
                      Card(
                        color: AppTema.primaryWhite.withOpacity(0.3),
                        elevation: 0.0,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.number,
                                enabled: enabledTextFormField,
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'CPF',
                                  prefixIcon: const Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  labelStyle: const TextStyle(
                                    color: AppTema.primaryDarkBlue,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                      color: AppTema.primaryAmarelo,
                                      width: 2.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor, insira um CPF, por favor';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                enabled: enabledTextFormField,
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  labelStyle: const TextStyle(
                                    color: AppTema.primaryDarkBlue,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                      color: AppTema.primaryAmarelo,
                                      width: 2.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor, insira uma senha, por favor';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _isLoading ? null : await _login();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTema.primaryAmarelo,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0, vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20.0,
                                          height: 20.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                            strokeWidth: 2.0,
                                          ),
                                        )
                                      : const Text(
                                          'Entrar',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 70.0),
                        child: Center(
                          child: Text(appVerso),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
