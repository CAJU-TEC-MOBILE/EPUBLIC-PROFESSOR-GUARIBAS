import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:professor_acesso_notifiq/configs/hive_config.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'help/console_log.dart';
import 'pages/atualizacoes/atualizacoes_list_page.dart';
import 'pages/aulas/aula__infantil_atualizar_page.dart';
import 'pages/aulas/aula_atualizar_page.dart';
import 'pages/aulas/criar_aula_infantil.dart';
import 'pages/aulas/criar_aula_page.dart';
import 'pages/aulas/listagem_aulas_infantil_page.dart';
import 'pages/aulas/listagem_aulas_page.dart';
import 'pages/aulas/listagem_fundamental_page.dart';
import 'pages/aulas/listagem_infantil_page.dart';
import 'pages/auth/load_auth.dart';
import 'pages/graficos_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/notificacao/notificacao_page.dart';
import 'pages/principal_page.dart';
import 'pages/professor/listagem_gestoes_professor.dart';
import 'pages/sobre/sobre_o_app_page.dart';
import 'pages/usuarioPage.dart';
import 'services/directories/directories_controller.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'services/permission/permission_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final DirectoriesController directories = DirectoriesController();

  final PermissionManager permissionManager = PermissionManager();

  await Future.wait([
    dotenv.load(),
    HiveConfig.start(),
    directories.getStorageDirectories(),
    directories.createImageDirectory(),
    directories.getDiretorioImages(),
    _checkAndRequestPermissions(permissionManager),
    _checkInternetConnection(),
    initializeDateFormatting('pt_BR', null),
    permissionManager.checkAdIdPermission()
  ]);
  // await SentryFlutter.init(
  //   (options) {
  //     // options.dsn =
  //     //     'https://21f7c06fe6a279ce2af049e261830ed2@o4507487119343616.ingest.us.sentry.io/4507645929783296';
  //     options.dsn = '';
  //     options.tracesSampleRate = 1.0;
  //     options.profilesSampleRate = 1.0;
  //   },
  //   appRunner: () {
  //     runApp(const InitialLoadingScreen());
  //   },
  // );
  runApp(const MyApp());
}

Future<void> _checkAndRequestPermissions(
    PermissionManager permissionManager) async {
  final PermissionStatus status = await Permission.phone.status;
  if (!status.isGranted) {
    await permissionManager.requestPermissions();
  }
}

Future<void> _checkInternetConnection() async {
  try {
    final bool isConnected =
        await InternetConnectionChecker.instance.hasConnection;

    final String mensagem = isConnected
        ? 'Dispositivo está conectado à internet'
        : 'Dispositivo não está conectado à internet';
    final String tipoMensagem = isConnected ? 'sucesso' : 'erro';

    ConsoleLog.mensagem(
      titulo: 'Status de Conexão',
      mensagem: mensagem,
      tipo: tipoMensagem,
    );
  } catch (e) {
    ConsoleLog.mensagem(
      titulo: 'Erro',
      mensagem: 'Falha ao verificar conexão: $e',
      tipo: 'erro',
    );
  }
}

class InitialLoadingScreen extends StatelessWidget {
  const InitialLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTema.primaryAmarelo,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppTema.primaryAmarelo,
      ),
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon_notifiq_sem_fundo.png',
                  width: 200,
                  height: 200,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: const CircularProgressIndicator(
                    color: AppTema.primaryAmarelo,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String nameApp = dotenv.env['NAME_APP'] ?? 'Default Application';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: nameApp,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: AppTema.primaryAmarelo,
        ),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
        Locale('ka', 'GE'),
        Locale('ru', 'RU'),
      ],
      initialRoute: '/loadAuth',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/perfil': (context) => const UsuarioPage(),
        '/loadAuth': (context) => const LoadAuth(),
        '/todasAsGestoesDoProfessor': (context) =>
            const ListagemGestoesProfessor(),
        '/criarAula': (context) => const CriarAulaPage(),
        '/criarAulaInfantil': (context) => const CriarAulaInfantilPage(),
        '/listagemAulas': (context) => const ListagemAulasPage(),
        '/listagemAulasInfantil': (context) =>
            const ListagemAulasInfantilPage(),
        '/atualizacoesList': (context) => const AtualizacoesListPage(),
        '/sobreApp': (context) => const SobreAppPage(),
        '/graficos': (context) => const GraficosPage(),
        '/atualizarAula': (context) => const AulaAtualizarPage(),
        '/atualizarAulaInfantil': (context) =>
            const AulaInfantilAtualizarPage(),
        '/index-notificacao': (context) => const NotificacaoPage(),
        '/principal': (context) => const PrincipalPage(),
        '/index-infantil': (context) => const ListagemInfantilPage(),
        '/index-fundamental': (context) => const ListagemFundamentalPage(),
      },
    );
  }
}
