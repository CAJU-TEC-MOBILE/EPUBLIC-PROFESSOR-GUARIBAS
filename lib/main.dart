import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'data/database/database_hive.dart';
import 'providers/auth_provider.dart';
import 'providers/autorizacao_provider.dart';
import 'routes/routes.dart';
import 'services/directories/directories_controller.dart';
import 'services/shared_preference_service.dart';
import 'utils/app_theme.dart';
import 'wigets/custom_flutter_error_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferenceService = SharedPreferenceService();

  final directories = DirectoriesController();

  await preferenceService.init();

  String route = await preferenceService.nextRoute();

  final initTasks = [
    HiveConfig.start(),
    directories.getStorageDirectories(),
    directories.createImageDirectory(),
    directories.getDiretorioImages(),
    initializeDateFormatting('pt_BR')
  ];

  await Future.wait(initTasks);

  runApp(MyApp(nextRoute: route));
}

class MyApp extends StatelessWidget {
  String nextRoute;
  MyApp({super.key, required this.nextRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AutorizacaoProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            key: navigatorKey,
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            title: dotenv.env['NAME_APP'] ?? 'Default App Name',
            color: Colors.white,
            builder: (BuildContext context, Widget? child) {
              ErrorWidget.builder = (errorDetails) {
                return CustomFlutterErrorWidget(errorDetails: errorDetails);
              };
              return SafeArea(
                top: false,
                child: child ?? const SizedBox.shrink(),
              );
            },
            initialRoute: nextRoute,
            routes: Routes.routes,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [
              Locale('pt', 'BR'),
              Locale('en', 'US'),
              Locale('ka', 'GE'),
              Locale('ru', 'RU'),
            ],
          );
        },
      ),
    );
  }
}
