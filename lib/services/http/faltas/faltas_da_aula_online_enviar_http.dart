import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/models/models_online/falta_model_online.dart';
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'dart:async';

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
    required String aulaId,
    required String matriculaId,
    required String justificativaId,
    required List<File> files,
    required String observacao,
  }) async {
    try {
      final directoriesController = DirectoriesController();
      Map<dynamic, dynamic>? authData = await _getAuthData();

      if (authData == null || authData['token_atual'] == null) {
        print('Erro: Dados de autenticação não disponíveis.');
        return false;
      }

      String url = '${ApiBaseURLService.baseUrl}/aulas/justificar-falta-app';

      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer ${authData['token_atual']}'
        ..fields['aula_id'] = aulaId
        ..fields['matricula_id'] = matriculaId
        ..fields['justificativa_id'] = justificativaId
        ..fields['observacao'] = observacao;

      if (files.isNotEmpty) {
        var fileStream = await http.MultipartFile.fromPath(
          'file',
          files[0].path,
          filename: files[0].path.split('/').last,
        );
        request.files.add(fileStream);
      } else {
        print('Nenhum arquivo selecionado para envio.');
      }

      var response = await request.send();

      await directoriesController.excluirTudoAnexos();

      if (response.statusCode == 200) {
        print('Sincronização bem-sucedida.');
        return true;
      } else {
        print('Erro de sincronização: ${response.statusCode}');
        String responseBody = await response.stream.bytesToString();
        print('Resposta do servidor: $responseBody');
        return false;
      }
    } catch (error, stackTrace) {
      print('Erro durante a sincronização: $error');
      print('Detalhes: $stackTrace');
      return false;
    }
  }
}
