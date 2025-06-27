import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import '../../../help/console_log.dart';
import '../../../models/instrutor_model.dart';
import '../../controller/Instrutor_controller.dart';
import '../../directories/directories_controller.dart';
import '../configuracao/configuracao_http.dart';

class AuthHttp {
  static const String _loginEndpoint = '/login-notifiq';

  final Box authBox = Hive.box('auth');

  Future<Map<dynamic, dynamic>?> _getAuthData() async {
    return authBox.get('auth');
  }

  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    final url = '${ApiBaseURLService.baseUrl}$_loginEndpoint';

    final response = await http.post(
      Uri.parse(url),
      body: {
        'email': email,
        'password': password,
        'device_name': 'mobile',
      },
    );

    return response;
  }

  Future<http.Response> uploudImage(File file) async {
    try {
      final instrutorController = InstrutorController();
      await instrutorController.init();

      Map<dynamic, dynamic>? authData = await _getAuthData();
      Instrutor instrutor = await instrutorController.getFirst();
      final instrutorId = instrutor.id.toString();
      final instrutorToken = instrutor.token.toString();

      if (!file.existsSync()) {
        return http.Response(
          'File does not exist',
          400,
        );
      }

      final url = Uri.parse(
          '${ApiBaseURLService.baseUrl}/notifiq-professor/autorizacoes/professor-imagem-perfil');

      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $instrutorToken'
        ..fields['professor_id'] = instrutorId
        ..files.add(await http.MultipartFile.fromPath('image', file.path));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return http.Response.fromStream(response);
      } else {
        return http.Response(
          'Failed to upload image. Status code: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (error) {
      print('Error: $error');
      return http.Response('Error: $error', 500);
    }
  }

  static Future<http.Response> setBaixarImage({
    required String? professorId,
    required String? imagemPerfil,
    String? cpf,
    String? userId,
  }) async {
    try {
      final instrutorController = InstrutorController();
      await instrutorController.init();

      Instrutor instrutor = await instrutorController.getFirst();
      final instrutorToken = instrutor.token.toString();

      final url = Uri.parse(
        '${ApiBaseURLService.baseUrl}/notifiq-professor/autorizacoes/professor-imagem-perfil/$professorId',
      );

      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $instrutorToken',
        },
      );

      if (response.statusCode == 200) {
        final directoriesController = DirectoriesController();

        await directoriesController.clearImagesDirectory();

        final diretorio = await directoriesController.getDiretorioImages();

        final filePath =
            '$diretorio/${cpf.toString()}_${userId.toString()}.jpg';
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        await directoriesController.pickAndSaveImageUserHttp(
          userId: professorId,
          file: file,
        );

        ConsoleLog.mensagem(
          titulo: 'setBaixarImage',
          mensagem: 'Arquivo baixado e salvo com sucesso em: ${file.path}',
          tipo: 'sucesso',
        );

        return response;
      } else {
        ConsoleLog.mensagem(
          titulo: 'setBaixarImage',
          mensagem:
              'Falha ao baixar a imagem. Código de status: ${response.statusCode}',
          tipo: 'erro',
        );

        return http.Response(
          'Falha ao baixar a imagem. Código de status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'setBaixarImage',
        mensagem: 'Erro: $error',
        tipo: 'erro',
      );

      return http.Response('Erro: $error', 500);
    }
  }

  static Future<void> tipoDeAula() async {
    try {
      final configuracaoHttp = ConfiguracaoHttp();
      await configuracaoHttp.getTiposAulas();
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'error-tipo-aula',
        mensagem: e.toString(),
        tipo: 'erro',
      );
    }
  }
}
