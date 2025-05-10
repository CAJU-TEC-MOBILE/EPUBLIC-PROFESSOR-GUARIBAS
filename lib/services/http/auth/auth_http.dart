import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'package:professor_acesso_notifiq/services/controller/professor_controller.dart';

import '../../../componentes/dialogs/custom_snackbar.dart';
import '../../../help/console_log.dart';
import '../../../models/instrutor_model.dart';
import '../../adapters/gestoes_service_adpater.dart';
import '../../connectivity/internet_connectivity_service.dart';
import '../../controller/Instrutor_controller.dart';
import '../../controller/disciplina_controller.dart';
import '../../directories/directories_controller.dart';
import '../configuracao/configuracao_htttp.dart';
import '../gestoes/gestoes_listar_com_outros_dados_http.dart';

class AuthHttp {
  static const String _loginEndpoint = '/login-notifiq';

  final Box authBox = Hive.box('auth');

  Future<Map<dynamic, dynamic>?> _getAuthData() async {
    return authBox.get('auth');
  }

  static Future<dynamic> logar(
    BuildContext context,
    String email,
    String password,
  ) async {
    bool isConnected = await InternetConnectivityService.isConnected();
    debugPrint("isConnected: $isConnected");
    if (!isConnected) {
      Future.microtask(() {
        CustomSnackBar.showErrorSnackBar(
          context,
          'Erro ao estabelecer a conexão. Verifique sua conexão com a internet.',
        );
      });
      return;
    }
    // ignore: unused_local_variable
    GestoesService gestoesService = GestoesService();
    DisciplinaController disciplinaController = DisciplinaController();
    final url = '${ApiBaseURLService.baseUrl}$_loginEndpoint';
    debugPrint("url: $url");
    final response = await http.post(
      Uri.parse(url),
      body: {
        'email': email,
        'password': password,
        'device_name': 'mobile',
      },
    );

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final InstrutorController instrutorController = InstrutorController();
        final professorController = ProfessorController();

        await professorController.init();
        await instrutorController.init();
        await disciplinaController.init();

        await professorController.clear();
        await instrutorController.clear();
        await disciplinaController.clear();

        await Future.delayed(const Duration(seconds: 3));

        final Map<String, dynamic> data = json.decode(response.body);

        debugPrint("token: ${data['user']['token_atual'].toString()}");

        final professorData = data['user']['professor'];

        final instrutor = Instrutor(
          id: professorData['id'].toString(),
          nome: professorData['nome'].toString(),
          anoId: data['user']['ano_id'].toString(),
          token: data['user']['token_atual'].toString(),
        );

        await setTipoDeAula(token: data['user']['token_atual'].toString());

        await instrutorController.addInstrutor(instrutor);

        GestoesListarComOutrosDadosHttp gestoesListarComOutrosDadosHttp =
            GestoesListarComOutrosDadosHttp();
        await gestoesListarComOutrosDadosHttp.todasAsGestoes();
        await gestoesService.atualizarGestoesDispositivo();
        return response;
      }
      return response;
    } catch (error) {
      return {'error': 'Erro de conexão.', 'response': 'response.body'};
    }
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

      // Fazer a requisição HTTP GET
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

  static Future<void> setTipoDeAula({required String token}) async {
    try {
      final configuracaoHttp = ConfiguracaoHttp();
      await configuracaoHttp.getTiposAulas(token: token);
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'error-tipo-aula',
        mensagem: e.toString(),
        tipo: 'erro',
      );
    }
  }
}
