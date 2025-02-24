import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import '../../models/notificacao_model.dart';
import 'notificacao_page_controller.dart';

class NotificacaoPage extends StatefulWidget {
  const NotificacaoPage({super.key});

  @override
  State<NotificacaoPage> createState() => _NotificacaoPageState();
}

class _NotificacaoPageState extends State<NotificacaoPage> {
  late final NotificacaoPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificacaoPageController();
    _controller.fetchNotificacoes(context);
  }

  @override
  void dispose() {
    _controller.notificacoes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar( 
        title: const Text('Notificações', style: TextStyle(color: AppTema.primaryDarkBlue),),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
      ),
      body: ValueListenableBuilder<List<Notificacao>>(
        valueListenable: _controller.notificacoes,
        builder: (context, notificacoes, child) {
          return notificacoes.isNotEmpty
              ? ListView.builder(
                  itemCount: notificacoes.length,
                  itemBuilder: (context, index) {
                    final notificacao = notificacoes[index];
                    return Card(
                      color: AppTema.primaryWhite,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.notifications,
                            color: AppTema.primaryAmarelo),
                        title: Text(notificacao.titulo, style: const TextStyle(color: AppTema.primaryDarkBlue),),
                        // subtitle: Text(notificacao.corpo),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    'Nenhuma notificação disponível',
                    style: TextStyle(fontSize: 18, color: AppTema.primaryDarkBlue),
                  ),
                );
        },
      ),
    );
  }
}
