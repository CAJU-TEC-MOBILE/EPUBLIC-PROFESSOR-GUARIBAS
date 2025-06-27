import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'data/database/database_hive.dart';
import 'providers/auth_provider.dart';
import 'routes/routes.dart';
import 'services/shared_preference_service.dart';
import 'utils/app_theme.dart';
import 'wigets/custom_flutter_error_widget.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferenceService = SharedPreferenceService();

  await preferenceService.init();

  String route = await preferenceService.nextRoute();

  await HiveConfig.start();

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
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            key: navigatorKey,
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            title: dotenv.env['NAME_APP'] ?? 'Default App Name',
            color: Colors.white,
            builder: (context, child) {
              ErrorWidget.builder = (errorDetails) {
                return CustomFlutterErrorWidget(errorDetails: errorDetails);
              };
              return child!;
            },
            initialRoute: nextRoute,
            routes: Routes.routes,
          );
        },
      ),
    );
  }
}
