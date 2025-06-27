import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import '../componentes/drawer/custom_drawer.dart';
import '../componentes/global/preloader.dart';
import '../constants/app_tema.dart';
import '../models/auth_model.dart';
import '../models/pedido_model.dart';
import '../services/adapters/auth_service_adapter.dart';
import '../services/controller/pedido_controller.dart';
import '../services/http/autorizacoes/autorizacoes_listar_http.dart';

class PedidoPage extends StatefulWidget {
  const PedidoPage({super.key});

  @override
  _PedidoPageState createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  final pedidoController = PedidoController();
  List<Pedido> pedidos = [];
  bool status = false;
  AuthModel authModel = AuthServiceAdapter().exibirAuth();
  final autorizacoesListarHttp = AutorizacoesListarHttp();
  @override
  void initState() {
    super.initState();
    _autorizacoes();
  }

  Future<void> _pedidos() async {
    try {
      setState(() => pedidos.clear());
      setState(() => status = true);
      await Future.delayed(const Duration(seconds: 3));
      await pedidoController.init();
      pedidos = pedidoController.getPeloUserId(userId: authModel.id);
      setState(() => status = false);
      setState(() {});
    } catch (e) {
      setState(() => status = false);
      debugPrint('error-pedido: $e');
    }
  }

  Future<void> _autorizacoes() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showLoading(context);
      });

      final response = await autorizacoesListarHttp.executar();
      if (response.statusCode != 200) {
        return;
      }

      final data = json.decode(response.body);
      for (var item in data['autorizacoes_atualizadas']) {
        pedidoController.updateSituacaoPeloId(
          id: item['id'].toString(),
          situacao: item['status'].toString(),
        );
      }

      await _pedidos();

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          hideLoading(context);
        });
      }
    } catch (e) {
      await _pedidos();
      print('error-autorizacao-lista: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
        title: const Text(
          'Pedidos',
          style: TextStyle(
            color: AppTema.primaryDarkBlue,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.sync,
              color: Colors.black,
              size: 25,
            ),
            onPressed: () async => await _autorizacoes(),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: status == true
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTema.primaryAmarelo,
              ),
            )
          : pedidos.isEmpty
              ? const Center(
                  child: Text('No momento, não há pedidos para exibir.'),
                )
              : ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: pedido.corSituacao,
                              width: 15.0,
                            ),
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16.0),
                            bottomRight: Radius.circular(13.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  pedido.id.isNotEmpty
                                      ? Row(
                                          children: [
                                            const Text(
                                              '#',
                                              style: TextStyle(
                                                fontSize: 10.0,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 2.0,
                                            ),
                                            Text(
                                              pedido.id,
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  const Spacer(),
                                  pedido.data.isNotEmpty
                                      ? Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_month_outlined,
                                              size: 10.0,
                                            ),
                                            const SizedBox(
                                              width: 2.0,
                                            ),
                                            Text(
                                              pedido.dataBr,
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Descrição:'),
                                  const SizedBox(
                                    width: 4.0,
                                  ),
                                  FutureBuilder<String>(
                                    future: pedido.descricaoTipo,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text('Carregando...');
                                      } else if (snapshot.hasError) {
                                        return const Text('Erro ao carregar');
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Text(
                                            'Descrição não encontrada');
                                      }
                                      return Text(snapshot.data!);
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Solicitante:'),
                                  const SizedBox(
                                    width: 4.0,
                                  ),
                                  FutureBuilder<String>(
                                    future: pedido.solicitante,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text('Carregando...');
                                      } else if (snapshot.hasError) {
                                        return const Text('Erro ao carregar');
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Text('---');
                                      }
                                      return Text(snapshot.data!);
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Avaliador:'),
                                  const SizedBox(
                                    width: 4.0,
                                  ),
                                  FutureBuilder<String>(
                                    future: pedido.avaliador,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text('Carregando...');
                                      } else if (snapshot.hasError) {
                                        return const Text('Erro ao carregar');
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Text('---');
                                      }
                                      return Text(snapshot.data!);
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Etapa:'),
                                  const SizedBox(
                                    width: 4.0,
                                  ),
                                  FutureBuilder<String?>(
                                    future: pedido.etapa,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text('Carregando...');
                                      } else if (snapshot.hasError) {
                                        return const Text('Erro ao carregar');
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Text('---');
                                      }
                                      return Text(snapshot.data.toString());
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Situação:'),
                                  const SizedBox(
                                    width: 4.0,
                                  ),
                                  Text(pedido.situacao.toString())
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
