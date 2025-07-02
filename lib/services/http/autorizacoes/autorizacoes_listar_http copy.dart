// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'dart:async';
// import '../../../models/auth_model.dart';
// import '../../adapters/auth_service_adapter.dart';
// import '../../api_base_url_service.dart';

// class AutorizacoesListarHttp {
//   AuthModel authModel = AuthServiceAdapter().exibirAuth();
//   Future<http.Response> executar() async {
//     String prefixUrl =
//         'notifiq-professor/autorizacoes/listar_autorizacoes_do_usuario';
//     var url = Uri.parse('${ApiBaseURLService.baseUrl}/$prefixUrl');
//     try {
//       var response = await http.get(
//         url,
//         headers: {'Authorization': 'Bearer ${authModel.tokenAtual}'},
//       );
//       return response;
//     } catch (e) {
//       return http.Response('', 500);
//     }
//   }

//   Future<http.Response> getUsuariosAutorizacao() async {
//     final String endpoint = 'get-usuarios-autorizacao';
//     final Uri url = Uri.parse('${ApiBaseURLService.baseUrl}/$endpoint');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         var jsonResponse = jsonDecode(response.body);
//         return http.Response(jsonEncode(jsonResponse), 200);
//       } else {
//         print('Erro ao acessar o recurso: ${response.statusCode}');
//         return http.Response('Erro ao acessar os dados', response.statusCode);
//       }
//     } catch (e) {
//       print('Exception occurred: $e');
//       return http.Response('Erro ao processar a solicitação', 500);
//     }
//   }
// }
