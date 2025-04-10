import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/models/models_online/falta_model_online.dart';
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'dart:async';
import 'package:path/path.dart' as path;
import '../../../componentes/dialogs/custom_snackbar.dart';
import '../../directories/directories_controller.dart';

class FaltasDaAulaOnlineEnviarHttp {
  Box authBox = Hive.box('auth');

  Future<Map<dynamic, dynamic>?> _getAuthData() async {
    return authBox.get('auth');
  }

  Future<void> executar(
      {required List<FaltaModelOnline> faltasOnlines,
      required aulaID,
      List<dynamic>? listaFaltasSemJustificavasDaMatricula}) async {
    Map<dynamic, dynamic>? authData = await _getAuthData();
    String prefixUrl = 'notifiq-professor/aulas/salvar-falta-online';
    var url = Uri.parse('${ApiBaseURLService.baseUrl}/$prefixUrl').toString();

    List<Map<String, dynamic>> faltasDaAulaJson =
        faltasOnlines.map((falta) => falta.toMap()).toList();
    //print('faltasDaAulaJson: $faltasDaAulaJson');

    /*faltasDaAulaJson.forEach((element) {
      print(element['matricula_id']);
    });*/

    String listaFaltasSemJustificavasDaMatriculaStr =
        jsonEncode(listaFaltasSemJustificavasDaMatricula ?? []);

    //print('faltasDaAulaJson: $faltasDaAulaJson');
    //print({'faltas_da_aula': jsonEncode(faltasDaAulaJson), 'aulaID': aulaID, 'listFaltasSemJustificavasDaMatricula': listaFaltasSemJustificavasDaMatriculaStr});

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${authData!['token_atual']}',
      },
      body: {
        'faltas_da_aula': jsonEncode(faltasDaAulaJson),
        'aulaID': aulaID,
        'listaFaltasSemJustificavasDaMatricula':
            listaFaltasSemJustificavasDaMatriculaStr
      },
    );

    try {
      if (response.statusCode == 200) {
        print('response: ${response.body}');
      } else {
        print(response.statusCode);
        print(response.body);
      }
    } catch (error) {
      print(' !! SINCRONIZAÇÃO  ERROR!!');
      print(error);
    }
  }

  Future<void> executarApi(
      {required List<dynamic>? dataFrequencias, required String aulaID}) async {
    Map<dynamic, dynamic>? authData = await _getAuthData();
    String prefixUrl = 'notifiq-professor/aulas/salvar-falta-online';
    var url = Uri.parse('${ApiBaseURLService.baseUrl}/$prefixUrl').toString();

    // Ajustar os dados de frequências para garantir que 'justificativa_id' esteja presente
    List<Map<String, dynamic>> adjustedDataFrequencias = dataFrequencias
            ?.map((item) {
          var mapItem =
              Map<String, dynamic>.from(item); // Garantir que item seja um Map
          if (!mapItem.containsKey('justificativa_id') ||
              mapItem['justificativa_id'] == 'null' ||
              mapItem['justificativa_id'] == '') {
            mapItem['justificativa_id'] = null;
          }
          return mapItem;
        }).toList() ??
        [];
    //print(adjustedDataFrequencias);
    String dataAula = jsonEncode(adjustedDataFrequencias);
    print(dataAula);
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${authData!['token_atual']}',
      },
      body: {'faltas_da_aula': dataAula, 'aulaID': aulaID},
    );

    try {
      if (response.statusCode == 200) {
        print('response: ${response.body}');
      } else {
        print(response.statusCode);
        print(response.body);
      }
    } catch (error) {
      print(' !! SINCRONIZAÇÃO  ERROR!!');
      print(error);
    }
  }

  Future<bool> setFrequencia({
    required String? matriculaId,
    required String aulaId,
    required int presente,
  }) async {
    try {
      Map<dynamic, dynamic>? authData = await _getAuthData();
      if (authData == null) {
        print('Erro: Dados de autenticação não disponíveis.');
        return false;
      }

      String url =
          '${ApiBaseURLService.baseUrl}/aulas/$aulaId/registrar-presenca';

      String matriculaIdStr = matriculaId ?? '';
      if (matriculaIdStr.isEmpty) {
        print('Erro: ID da matrícula inválido.');
        return false;
      }
      //print('url: $url');
      //print('aula_id: $aulaId');
      //print('matriculaIdStr: $matriculaIdStr');
      //print('presente: $presente');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${authData['token_atual']}',
        },
        body: {
          'matricula_id': matriculaIdStr,
          'presente': jsonEncode(presente),
        },
      );

      if (response.statusCode == 200) {
        //print('Sincronização bem-sucedida: ${response.body}');
        return true;
      } else {
        print('Erro de sincronização: ${response.statusCode}');
        print('Resposta do servidor: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Erro durante a sincronização: $error');
      return false;
    }
  }

  Future<bool> setJustificarFalta({
    required BuildContext context,
    required String aulaId,
    required String matriculaId,
    required String justificativaId,
    required List<File> files,
    required String observacao,
  }) async {
    try {
      final directoriesController = DirectoriesController();
      final authData = await _getAuthData();

      if (authData == null || authData['token_atual'] == null) {
        print('❌ Erro: Token de autenticação não encontrado.');
        CustomSnackBar.showErrorSnackBar(
            context, 'Autenticação inválida. Faça login novamente.');
        return false;
      }

      if (aulaId.isEmpty || matriculaId.isEmpty || justificativaId.isEmpty) {
        print('❌ Erro: Parâmetros obrigatórios ausentes.');
        CustomSnackBar.showErrorSnackBar(
            context, 'Erro ao justificar falta: dados incompletos.');
        return false;
      }

      final String url =
          '${ApiBaseURLService.baseUrl}/aulas/justificar-falta-app';
      final Map<String, String> headers = {
        'Authorization': 'Bearer ${authData['token_atual']}',
        'Content-Type': 'application/json',
      };
      print("url: $url");
      print("token_atual: ${authData['token_atual'].toString()}");

      List<Map<String, String>> base64Files = [];

      if (files.isNotEmpty) {
        for (var file in files) {
          if (!await file.exists()) {
            print('⚠️ Arquivo não encontrado: ${file.path}');
            continue;
          }

          try {
            List<int> fileBytes = await file.readAsBytes();
            String base64String = base64Encode(fileBytes);
            String fileName = path.basename(file.path);

            base64Files.add({'filename': fileName, 'filedata': base64String});
            debugPrint('-> ${base64Files.first.toString()}');
          } catch (e) {
            print('❌ Erro ao converter arquivo ${file.path} para Base64: $e');
            CustomSnackBar.showErrorSnackBar(
                context, 'Erro ao processar um dos anexos.');
          }
        }

        print('✅ Total de arquivos convertidos: ${base64Files.length}');
      } else {
        print('ℹ️ Nenhum arquivo anexado.');
      }

      // Montagem do corpo da requisição
      final Map<String, dynamic> requestBody = {
        'aula_id': aulaId,
        'matricula_id': matriculaId,
        'justificativa_id': justificativaId,
        'observacao': observacao,
        'documento_base64':
            base64Files.isNotEmpty ? base64Files.first['filedata'] : null,
      };
      print("requestBody : $requestBody");
      print('📤 Enviando justificativa...');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      await directoriesController.excluirTudoAnexos();

      final responseBody = jsonDecode(response.body);
      print(responseBody.toString());

      if (response.statusCode == 200) {
        print('✅ Justificativa enviada com sucesso.');
        return true;
      } else {
        final errorMessage = responseBody['message'] ?? 'Erro desconhecido';
        print(
            '❌ Erro ao enviar justificativa: ${response.statusCode} - $errorMessage');

        if (errorMessage == 'Falta não encontrada.') {
          return false;
        }

        CustomSnackBar.showErrorSnackBar(context, errorMessage);
        return false;
      }
    } catch (error, stackTrace) {
      print('❌ Erro inesperado durante a requisição: $error');
      print('📜 StackTrace: $stackTrace');

      CustomSnackBar.showErrorSnackBar(
          context, 'Erro ao justificar falta. Tente novamente.');
      return false;
    }
  }
}
