//import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'dart:io';
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';

Future<dynamic> checkInternetConnection() async {
  try {
    final result = await InternetAddress.lookup(ApiBaseURLService.baseParaDNS);
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('Conexão e servidor ativos');
      return true;
    }
  } on SocketException catch (e) {
    print('ERROR: $e');
    print('Conexão e/ou servidor não ativo(s)');
    return false;
  }
}
