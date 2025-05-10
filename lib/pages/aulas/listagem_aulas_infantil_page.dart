import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/componentes/aulas/situacao_aula_componente.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/constants/emojis.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/converter_data_america_para_brasil.dart';
import 'package:professor_acesso_notifiq/functions/retornar_horario_selecionado.dart';
import 'package:professor_acesso_notifiq/models/aula_model.dart';
import 'package:professor_acesso_notifiq/pages/aulas/aula__infantil_atualizar_page.dart';
import 'package:professor_acesso_notifiq/pages/frequencias/frequencia_offline_page.dart';
import 'package:professor_acesso_notifiq/pages/frequencias/frequencia_online_page.dart';
import 'package:professor_acesso_notifiq/services/adapters/aulas_offlines_listar_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/aulas_offline_online_service_adapter.dart';
import 'dart:async';

import 'package:professor_acesso_notifiq/services/http/aulas/aulas_offline_sincronizar_service.dart';

import '../../componentes/dialogs/custom_dialogs.dart';
import '../../componentes/dialogs/custom_sync_dialog.dart';
import '../../services/controller/aula_controller.dart';

class ListagemAulasInfantilPage extends StatefulWidget {
  const ListagemAulasInfantilPage({super.key});

  @override
  State<ListagemAulasInfantilPage> createState() =>
      _ListagemAulasInfantilPageState();
}

class _ListagemAulasInfantilPageState extends State<ListagemAulasInfantilPage> {
  List<Aula> aulas_offlines = AulasOfflinesListarServiceAdapter().executar();
  final Box _gestaoAtivaBox = Hive.box('gestao_ativa');
  Map<dynamic, dynamic>? gestao_ativa_data;

  // Dados da paginação ->> INÍCIO <<-
  final int itemsPerPage = 5; // Número de itens por página
  int currentPage = 0; // Página atual

  int getTotalPages() {
    return (aulas_offlines.length / itemsPerPage).ceil();
  }

  List<Aula> getPaginatedItems() {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return aulas_offlines.sublist(startIndex,
        endIndex < aulas_offlines.length ? endIndex : aulas_offlines.length);
  }

  void nextPage() {
    setState(() {
      if (currentPage < getTotalPages() - 1) {
        currentPage++;
      }
    });
  }

  void previousPage() {
    setState(() {
      if (currentPage > 0) {
        currentPage--;
      }
    });
  }
  // Dados da paginação ->> FIM <<-

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    //CustomDialogs.showLoadingDialog(context, show: true, message: 'Aguarde...');
    gestao_ativa_data = await _gestaoAtivaBox.get('gestao_ativa');

    List<Aula> dados =
        await AulasOfflineOnlineServiceAdapter().todasAsAulas(context);
    setState(() {
      aulas_offlines = dados;
    });
    //CustomDialogs.showLoadingDialog(context, show: false);
  }

  @override
  Widget build(BuildContext context) {
    final paginatedItems = getPaginatedItems();
    final totalPages = getTotalPages();

    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        title: const Text('Aulas do Infantil'),
        iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppTema.primaryDarkBlue,
        onRefresh: carregarDados,
        child: FutureBuilder<List<Aula>>(
            future: Future.value(aulas_offlines),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('carregando...'));
              } else if (snapshot.hasError) {
                return const Text('Erro ao carregar os dados');
              } else if (snapshot.data!.isNotEmpty && snapshot.data != null) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: paginatedItems.length,
                        itemBuilder: (context, index) {
                          return paginatedItems[index].e_aula_infantil == 1
                              ? Card(
                                  color: AppTema.primaryWhite,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: paginatedItems[index]
                                                .id
                                                .toString()
                                                .isEmpty
                                            ? const BorderSide(
                                                color: Color.fromARGB(
                                                    255, 161, 158, 158),
                                                width: 15.0,
                                              )
                                            : const BorderSide(
                                                color: AppTema.success,
                                                width: 15.0,
                                              ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(16.0),
                                        bottomRight: Radius.circular(13.0),
                                      ),
                                    ),
                                    // padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: ExpansionTile(
                                      backgroundColor: const Color.fromARGB(
                                          115, 218, 188, 105),
                                      textColor: AppTema.primaryDarkBlue,
                                      title: Column(
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                //Text(paginatedItems[index].instrutorDisciplinaTurma_id.toString()),
                                                Text(
                                                  paginatedItems[index]
                                                              .dataDaAula !=
                                                          ''
                                                      ? conveterDataAmericaParaBrasil(
                                                          paginatedItems[index]
                                                              .dataDaAula)
                                                      : '- - -',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                paginatedItems[index]
                                                            .id
                                                            .toString() ==
                                                        ''
                                                    ? Row(
                                                        children: [
                                                          const Text(''),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Icon(
                                                            Icons.circle,
                                                            size: 15,
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                        ],
                                                      )
                                                    : Row(
                                                        children: [
                                                          Text(paginatedItems[
                                                                  index]
                                                              .id
                                                              .toString()),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          const Icon(
                                                            Icons.circle,
                                                            size: 15,
                                                            color:
                                                                AppTema.success,
                                                          ),
                                                        ],
                                                      ),
                                              ]),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                FutureBuilder<String>(
                                                  future: retornarHorarioSelecionado(
                                                      horarioID: paginatedItems[
                                                              index]
                                                          .horarioID
                                                          .toString()), // Corrigido aqui
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<String>
                                                              snapshot) {
                                                    const textStyle = TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500);

                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Text(
                                                        '',
                                                        style: textStyle,
                                                      );
                                                    } else if (snapshot
                                                            .hasData &&
                                                        snapshot
                                                            .data!.isNotEmpty) {
                                                      return Text(
                                                        snapshot.data!,
                                                        style: textStyle.copyWith(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                10, 10, 10)),
                                                      );
                                                    } else {
                                                      return const Text(
                                                        'Sem horário',
                                                        style: textStyle,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 190,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: SituacaoAulaComponente(
                                                    situacaoAula:
                                                        paginatedItems[index]
                                                            .situacao
                                                            .toString(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: Color.fromARGB(255, 161,
                                                    158, 158), // Cor da borda
                                                width: 1.0, // Largura da borda
                                              ),
                                            ),
                                          ),
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 10, bottom: 5),
                                          child: Column(
                                            children: [
                                              /*Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(bottom: 5),
                                            child: const Text(
                                              'Horários definidos: ',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: paginatedItems[index].horarios_infantis.length,
                                          itemBuilder: (BuildContext context, int indexHorarios) {
                                            List<int> horariosInfantis = paginatedItems[index].horarios_infantis;
                                            return FutureBuilder<String>(
                                              future: retornarHorarioSelecionado(horarioID: horariosInfantis[indexHorarios].toString()),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<String> snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Text(
                                                    'Sem horário',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  );
                                                }
                                                if (snapshot.hasData) {
                                                  return Text(
                                                    snapshot.data!,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                      // fontWeight:
                                                      //     FontWeight.w500,
                                                    ),
                                                  );
                                                }
                                                return const Text(
                                                  'Sem horário',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),*/
                                              const SizedBox(height: 10),
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Column(
                                                    children: [
                                                      const Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Tipo de aula:',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          paginatedItems[index]
                                                              .tipoDeAula
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: SizedBox(
                                                      width: paginatedItems[
                                                                      index]
                                                                  .id
                                                                  .toString() ==
                                                              ''
                                                          ? 120
                                                          : 0,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: paginatedItems[
                                                                        index]
                                                                    .id
                                                                    .toString() ==
                                                                ''
                                                            ? ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return CustomSyncDialog(
                                                                        onCancel:
                                                                            () =>
                                                                                Navigator.of(context).pop(false),
                                                                        onConfirm:
                                                                            () async {
                                                                          AulaController
                                                                              aulaController =
                                                                              AulaController();

                                                                          List<String>
                                                                              experiencia =
                                                                              [];

                                                                          await aulaController
                                                                              .init();

                                                                          List<Aula>
                                                                              aulas =
                                                                              await aulaController.getAulaCriadaPeloCelular(
                                                                            criadaPeloCelular:
                                                                                paginatedItems[index].criadaPeloCelular,
                                                                          );

                                                                          for (final item
                                                                              in aulas) {
                                                                            experiencia =
                                                                                item.experiencias;
                                                                          }

                                                                          await AulasOfflineSincronizarService()
                                                                              .executar(
                                                                            context,
                                                                            paginatedItems[index],
                                                                            experiencia,
                                                                            paginatedItems[index].series ??
                                                                                [],
                                                                          );

                                                                          await carregarDados();
                                                                        },
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          5),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors.grey[
                                                                          400],
                                                                ),
                                                                child:
                                                                    const Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .sync,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            18),
                                                                    SizedBox(
                                                                        width:
                                                                            10),
                                                                    Text(
                                                                      'Sincronizar'
                                                                      ' ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : ElevatedButton(
                                                                onPressed:
                                                                    () {},
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          5),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                ),
                                                                child:
                                                                    const Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            18),
                                                                    SizedBox(
                                                                        width:
                                                                            4),
                                                                    Text(
                                                                      'Sincronizada',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                  paginatedItems[index]
                                                              .id
                                                              .toString() ==
                                                          ''
                                                      ? const SizedBox(
                                                          width: 10,
                                                        )
                                                      : const SizedBox(),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: SizedBox(
                                                      width: 115,
                                                      child: paginatedItems[
                                                                      index]
                                                                  .id
                                                                  .toString() ==
                                                              ''
                                                          ? ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                await Navigator
                                                                    .push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            FrequenciaOfflinePage(
                                                                      aula_id: paginatedItems[
                                                                              index]
                                                                          .criadaPeloCelular
                                                                          .toString(),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                backgroundColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        217,
                                                                        168,
                                                                        6),
                                                              ),
                                                              child: const Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .thumb_up,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 18),
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                  Text(
                                                                    'Frequência',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            FrequenciaOnlinePage(
                                                                      aula_id: paginatedItems[
                                                                              index]
                                                                          .id
                                                                          .toString(),
                                                                      selecionandoId:
                                                                          paginatedItems[index]
                                                                              .id
                                                                              .toString(),
                                                                      dataDaAula: paginatedItems[index].dataDaAula !=
                                                                              null
                                                                          ? conveterDataAmericaParaBrasil(
                                                                              paginatedItems[index].dataDaAula)
                                                                          : 'sem data',
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                backgroundColor:
                                                                    AppTema
                                                                        .success,
                                                              ),
                                                              child: const Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .thumb_up,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 18),
                                                                  SizedBox(
                                                                      width: 4),
                                                                  Text(
                                                                    'Frequência',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                  paginatedItems[index]
                                                              .id
                                                              .toString() ==
                                                          ''
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              //print(paginatedItems[index].id.toString());
                                                              //print(paginatedItems[index].criadaPeloCelular.toString());
                                                              await Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => AulaInfantilAtualizarPage(
                                                                          aulaLocalId: paginatedItems[index]
                                                                              .criadaPeloCelular
                                                                              .toString())));
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              backgroundColor:
                                                                  AppTema
                                                                      .primaryDarkBlue,
                                                            ),
                                                            child: const Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(Icons.edit,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 18),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        currentPage > 0
                            ? ElevatedButton(
                                onPressed: previousPage,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: AppTema.primaryDarkBlue,
                                ),
                                child:
                                    // Text('Anterior (Página ${currentPage})'),
                                    const Icon(
                                  Icons.arrow_circle_left,
                                  color: Colors.white,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: AppTema.primaryDarkBlue,
                                ),
                                child:
                                    // Text('Anterior (Página ${currentPage})'),
                                    const Icon(
                                  Icons.arrow_circle_left,
                                  color: Colors.white,
                                ),
                              ),
                        const SizedBox(width: 16),
                        (currentPage + 1) < totalPages
                            ? ElevatedButton(
                                onPressed: nextPage,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: AppTema.primaryDarkBlue,
                                ),
                                child:
                                    // Text('Próxima (${currentPage + 2})'),
                                    const Icon(
                                  Icons.arrow_circle_right,
                                  color: Colors.white,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: AppTema.primaryDarkBlue,
                                ),
                                child:
                                    // Text('Próxima (Página ${currentPage + 2})'),
                                    const Icon(
                                  Icons.arrow_circle_right,
                                  color: Colors.white,
                                ),
                              )
                      ],
                    ),
                    Text(
                      'Tela atual: ${currentPage + 1}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    // Text(
                    //   'Total de telas: $totalPages',
                    //   // style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                );
              } else {
                return Center(
                  child: Text(
                    'Sem aulas no momento ${Emojis.sadEmoji}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }
            }),
      ),
    );
  }
}
