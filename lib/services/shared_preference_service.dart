import '../helpers/console_log.dart';
import '../enums/status_console.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static final SharedPreferenceService _instance =
      SharedPreferenceService._internal();

  factory SharedPreferenceService() => _instance;

  SharedPreferenceService._internal();

  late SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<String?> getToken() async {
    try {
      return _preferences.getString('access_token');
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'shared-preference-service-get-token',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return null;
    }
  }

  Future<void> salvarDadosUsuario({
    required String accessToken,
    required bool successStatus,
  }) async {
    try {
      await _preferences.setString('access_token', accessToken);
      await _preferences.setBool('success_status', successStatus);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'shared-preference-service-salvar-dados-usuario',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
  }

  Future<void> setOnboardingStatus(bool status) async {
    try {
      await _preferences.setBool('onboarding_status', status);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'shared-preference-service-set-onboarding-status',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
  }

  bool getSuccessStatus() => _preferences.getBool('success_status') ?? false;

  String? getAccessToken() => _preferences.getString('access_token');

  bool getOnboardingStatus() =>
      _preferences.getBool('onboarding_status') ?? false;

  int getNotificationCount() => _preferences.getInt('notification_count') ?? 0;

  List<String> getNotificationList() =>
      _preferences.getStringList('notification_list') ?? [];

  void visualizar() {
    print("==========================");
    print("access_token: ${getAccessToken()}");
    print("success_status: ${getSuccessStatus()}");
    print("onboarding_status: ${getOnboardingStatus()}");
    print("notification_count: ${getNotificationCount()}");
    print("notification_list: ${getNotificationList()}");
    print("==========================");
  }

  Future<void> limparDados() async {
    try {
      await _preferences.clear();
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'shared-preference-service-limpar-dados',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
  }

  Future<void> logoff() async {
    try {
      await _preferences.setString('access_token', '');
      await _preferences.setBool('success_status', false);
      await _preferences.setBool('onboarding_status', true);
      await _preferences.setInt('notification_count', 0);
      await _preferences.setStringList('notification_list', []);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'shared-preference-service-logoff',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
  }

  Future<String> nextRoute() async {
    try {
      if (existeAuthLogado()) return '/home';
      return '/login';
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'shared-preference-service-next-route',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return '/login';
    }
  }

  bool existeAuthLogado() {
    final token = getAccessToken();
    return getSuccessStatus() && token != null && token.isNotEmpty;
  }
}
