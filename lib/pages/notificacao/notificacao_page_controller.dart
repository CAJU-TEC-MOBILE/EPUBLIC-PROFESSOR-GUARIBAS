import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/notificacao_model.dart';
import '../../services/http/notificacao/notificacao_http.dart';
import 'package:http/http.dart' as http;

class NotificacaoPageController {
  final ValueNotifier<List<Notificacao>> notificacoes = ValueNotifier<List<Notificacao>>([]);

  Future<void> fetchNotificacoes(BuildContext context) async {
    try {
      NotificacaoHttp notificacaoService = NotificacaoHttp();
      http.Response response = await notificacaoService.getDestinatarioNoticacao(id: '167');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        notificacoes.value = data.map((e) => Notificacao.fromJson(e)).toList();
      } else {
        notificacoes.value = [];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar notificações. Código: ${response.statusCode}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
       notificacoes.value = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar notificações: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void removerNotificacao(int index, BuildContext context) {
    Notificacao notificacaoRemovida = notificacoes.value[index];
    notificacoes.value = List.from(notificacoes.value)..removeAt(index);

    // Exibe um SnackBar com o título ou corpo da notificação removida
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notificação removida: ${notificacaoRemovida.titulo}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
