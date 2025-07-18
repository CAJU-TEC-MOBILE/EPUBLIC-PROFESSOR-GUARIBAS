import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../constants/app_tema.dart';
import '../providers/auth_provider.dart';
import '../utils/validador.dart';
import '../wigets/custom_passwordfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String appVerso = '';
  String numeroBuild = '';
  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    numeroBuild = info.buildNumber;
    setState(() {
      numeroBuild;
      packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    configuracaoEnv();
    _initPackageInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false);
      }
    });
    _usernameController.text = '12121212121';
    _passwordController.text = '07121999';
  }

  Future<void> configuracaoEnv() async {
    appVerso = dotenv.env['VERSAO'] ?? 'Default Verso';
    setState(() => appVerso);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context, listen: true);
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
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          width: 250,
                        ),
                        Card(
                          color: AppTema.primaryWhite.withValues(alpha: 0.3),
                          elevation: 0.0,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 14.0, right: 14.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 16.0),
                                TextFormField(
                                  key: const Key('cpf_field'),
                                  keyboardType: TextInputType.number,
                                  enabled: provider.enabledTextFormField,
                                  controller: _usernameController,
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
                                CustomPasswordField(
                                  key: const Key('senha_field'),
                                  controller: _passwordController,
                                  enabled: provider.enabledTextFormField,
                                  labelText: 'Senha',
                                  prefixIcon: Icons.lock_outline,
                                  fillColor: Colors.grey.shade50,
                                  validator: (value) =>
                                      Validador.validarPassword(value),
                                ),
                                const SizedBox(height: 16.0),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    key: const Key('btn_login'),
                                    onPressed: () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        await provider.login(
                                          context: context,
                                          email: _usernameController.text,
                                          password: _passwordController.text,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTema.primaryAmarelo,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0,
                                        vertical: 12.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: provider.isLoading
                                        ? const SizedBox(
                                            width: 20.0,
                                            height: 20.0,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Versão:",
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black38,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4.0,
                                      ),
                                      Text(
                                        "$numeroBuild ($appVerso)",
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black38,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
