import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/models/autorizacao_model.dart';
import 'package:professor_acesso_notifiq/models/etapa_model.dart';
import 'package:professor_acesso_notifiq/pages/autorizacoes/criar_autorizacao_page.dart';

import '../../models/auth_model.dart';
import '../../services/adapters/auth_service_adapter.dart';
import '../../services/controller/pedido_controller.dart';

class AvisoDeRegraAutorizacoesComponente extends StatefulWidget {
  final Etapa? etapa_selecionada_objeto;
  final Autorizacao? autorizacaoSelecionada;
  final String? statusDaAutorizacao;
  final bool dataLogicaExpiracao;
  final bool dataEtapaValida;
  final String etapaId;
  final String instrutorDisciplinaTurmaID;
  final bool statusPeriudo;

  const AvisoDeRegraAutorizacoesComponente({
    super.key,
    required this.etapa_selecionada_objeto,
    required this.autorizacaoSelecionada,
    required this.statusDaAutorizacao,
    required this.dataLogicaExpiracao,
    required this.dataEtapaValida,
    required this.etapaId,
    required this.instrutorDisciplinaTurmaID,
    required this.statusPeriudo,
  });

  @override
  State<AvisoDeRegraAutorizacoesComponente> createState() =>
      _AvisoDeRegraAutorizacoesComponenteState();
}

class _AvisoDeRegraAutorizacoesComponenteState
    extends State<AvisoDeRegraAutorizacoesComponente> {
  final pedidoController = PedidoController();
  bool statusLiberacao = false;
  int status = 0;
  Auth authModel = AuthServiceAdapter().exibirAuth();

  Future<void> _statusPedido() async {
    await pedidoController.init();
    //await Future.delayed(const Duration(seconds: 1));
    widget.etapa_selecionada_objeto!.circuito_nota_id;
    status = await pedidoController.getAvalidarPeriodo(
      instrutorDisciplinaTurmaID: widget.instrutorDisciplinaTurmaID,
      etapaId: widget.etapaId,
      userId: authModel.id,
      circuitoId: widget.etapa_selecionada_objeto!.circuito_nota_id,
      dataFimEtapa: widget.etapa_selecionada_objeto!.periodo_final,
    );
    if (status == 1 && widget.statusPeriudo != true) {
      status = 2;
    }

    setState(() {
      status;
    });
  }

  @override
  void initState() {
    super.initState();
    _statusPedido();
  }

  @override
  Widget build(BuildContext context) {
    _statusPedido();
    return Column(
      children: [
        status == 1
            ? const SizedBox(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(
                  bottom: 8.0,
                ),
                child: Container(
                  child: Center(
                      child: status == 2
                          ? Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: AppTema.error,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Column(
                                    children: [
                                      Text(
                                        'Aviso',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Etapa bloqueada. Para lançar uma aula você deve solicitar uma autorização.',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 1.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        backgroundColor:
                                            AppTema.primaryDarkBlue,
                                      ),
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CriarAutorizacaoPage(
                                              etapa: widget
                                                  .etapa_selecionada_objeto,
                                              circuitoId: widget
                                                  .etapa_selecionada_objeto!
                                                  .circuito_nota_id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Solicitar autorização',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : const SizedBox()
                      // : Card(
                      //     elevation: 0.0,
                      //     color: AppTema.backgroundColorApp,
                      //     child: Column(
                      //       children: [
                      //         SizedBox(
                      //           width: MediaQuery.of(context).size.width,
                      //           child: Container(
                      //             padding: const EdgeInsets.all(8.0),
                      //             child: Column(
                      //               children: [
                      //                 const Text(
                      //                   'Já existe uma solicitação de autorização para esta etapa, aguardando confirmação.',
                      //                   style: TextStyle(color: Colors.black),
                      //                 ),
                      //                 const SizedBox(
                      //                   height: 8.0,
                      //                 ),
                      //                 SizedBox(
                      //                   width:
                      //                       MediaQuery.of(context).size.width,
                      //                   child: ElevatedButton(
                      //                     style: ElevatedButton.styleFrom(
                      //                       elevation: 1.0,
                      //                       shape: RoundedRectangleBorder(
                      //                         borderRadius:
                      //                             BorderRadius.circular(8.0),
                      //                       ),
                      //                       backgroundColor: AppTema.error,
                      //                     ),
                      //                     onPressed: () {
                      //                       Navigator.pushReplacement(
                      //                         context,
                      //                         MaterialPageRoute(
                      //                           builder: (context) =>
                      //                               const PedidoPage(),
                      //                         ),
                      //                       );
                      //                     },
                      //                     child: const Padding(
                      //                       padding: EdgeInsets.all(8.0),
                      //                       child: Text(
                      //                         'Pedidos',
                      //                         style: TextStyle(
                      //                             color: Colors.white),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //                 const SizedBox(
                      //                   height: 8.0,
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      ),
                ),
              ),
      ],
    );
  }
}
