import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/constants/autorizacoes/autorizacoes_status_const.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/verificar_conexao_com_internet.dart';
import 'package:professor_acesso_notifiq/models/auth_model.dart';
import 'package:professor_acesso_notifiq/pages/login_page.dart';
import 'package:professor_acesso_notifiq/services/adapters/auth_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/autorizacoes_service.dart';
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'package:professor_acesso_notifiq/services/widgets/snackbar_service_widget.dart';

import '../../../componentes/global/preloader.dart';

class ApiSalvarAutorizacoesService {
  static const String _prefixUrl =
      'notifiq-professor/autorizacoes/criar-autorizacao';

  Future<void> executar(
    BuildContext context, {
    required String pedidoID,
    required String instrutorDisciplinaTurmaID,
    required String etapaID,
    required String userSolicitanteID,
    required String userAprovadorID,
    required String observacao,
  }) async {
    final Map<String, dynamic> data = {
      'pedido_id': pedidoID,
      'instrutorDisciplinaTurma_id': instrutorDisciplinaTurmaID,
      'etapa_id': etapaID,
      'user_solicitante': userSolicitanteID,
      'user_aprovador': userAprovadorID,
      'status': AutorizacoesStatusConst.pendente,
      'observacoes': observacao
    };

    final String url = '${ApiBaseURLService.baseUrl}/$_prefixUrl';
    final Auth authModel = AuthServiceAdapter().exibirAuth();

    try {
      final bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        _mostrarSnackBarErro(context, 'Sem conexão com a internet');
        return;
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${authModel.tokenAtual}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      await _tratarResposta(context, response);
    } catch (error) {
      _mostrarSnackBarErro(context, 'Ocorreu um erro inesperado');
      debugPrint('Erro ao salvar autorizações: $error');
    }
  }

  Future<void> _tratarResposta(BuildContext context, http.Response response) async {
    switch (response.statusCode) {
      case 200 || 201:
        await _sincronizarAutorizacoes(context, response);
        break;
      case 401:
        _mostrarSnackBarErro(context, 'Conexão expirada');
        _redirecionarParaLogin(context);
        break;
      default:
        _mostrarSnackBarErro(context, 'Erro ao enviar pedido: ${response.statusCode}');
        debugPrint('Erro na resposta da API: ${response.body}');
    }
  }

  Future<void> _sincronizarAutorizacoes(BuildContext context, http.Response response) async {
    try {
      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      final List<dynamic> autorizacoesAtualizadas = responseJson['autorizacoes_atualizadas'];

      await AutorizacoesServiceAdapter().salvar(autorizacoesAtualizadas);

      SnackBarServiceWidget.mostrarSnackBar(
        context,
        mensagem: 'Pedido enviado com sucesso',
        backgroundColor: AppTema.success,
        icon: Icons.check,
        iconColor: Colors.white,
      );

      debugPrint('Sincronização bem-sucedida: ${response.body}');
    } catch (error) {
      _mostrarSnackBarErro(context, 'Erro ao processar resposta da API');
      debugPrint('Erro ao sincronizar autorizações: $error');
    }
  }

  void _mostrarSnackBarErro(BuildContext context, String mensagem) {
    SnackBarServiceWidget.mostrarSnackBar(
      context,
      mensagem: mensagem,
      backgroundColor: Colors.red,
      icon: Icons.error_outline,
      iconColor: Colors.white,
    );
  }

  void _redirecionarParaLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
