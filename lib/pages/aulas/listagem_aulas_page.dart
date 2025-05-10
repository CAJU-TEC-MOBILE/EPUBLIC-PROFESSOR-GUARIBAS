import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/componentes/aulas/situacao_aula_componente.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/constants/emojis.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/converter_data_america_para_brasil.dart';
import 'package:professor_acesso_notifiq/functions/retornar_horario_selecionado.dart';
import 'package:professor_acesso_notifiq/models/aula_model.dart';
import 'package:professor_acesso_notifiq/pages/aulas/aula_atualizar_page.dart';
import 'package:professor_acesso_notifiq/pages/frequencias/frequencia_offline_page.dart';
import 'package:professor_acesso_notifiq/pages/frequencias/frequencia_online_page.dart';
import 'package:professor_acesso_notifiq/services/adapters/aulas_offlines_listar_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/aulas_offline_online_service_adapter.dart';
import 'dart:async';
import 'package:professor_acesso_notifiq/services/http/aulas/aulas_offline_sincronizar_service.dart';
import '../../componentes/dialogs/custom_sync_dialog.dart';
import '../../models/disciplina_aula_model.dart';
import '../../models/disciplina_model.dart';
import '../../models/horario_model.dart';
import '../../services/controller/aula_controller.dart';
import '../../services/controller/disciplina_aula_controller.dart';
import '../../services/controller/disciplina_controller.dart';
import '../../services/controller/horario_configuracao_controller.dart';
import '../../services/controller/horario_controller.dart';
import '../../models/gestao_ativa_model.dart';
import '../../services/adapters/gestao_ativa_service_adapter.dart';

class ListagemAulasPage extends StatefulWidget {
  final String? instrutorDisciplinaTurmaId;
  const ListagemAulasPage({super.key, this.instrutorDisciplinaTurmaId});

  @override
  State<ListagemAulasPage> createState() => _ListagemAulasPageState();
}

class _ListagemAulasPageState extends State<ListagemAulasPage> {
  GestaoAtiva? gestaoAtivaModel;
  // ignore: non_constant_identifier_names
  List<Aula> aulas_offlines = AulasOfflinesListarServiceAdapter().executar();
  final horarioConfiguracaoController = HorarioConfiguracaoController();
  // ignore: prefer_final_fields
  Box _gestaoAtivaBox = Hive.box('gestao_ativa');
  // ignore: non_constant_identifier_names
  Map<dynamic, dynamic>? gestao_ativa_data;
  List<Disciplina> disciplinas = [];
  List<DisciplinaAula> disciplinasAula = [];
  List<Map<String, dynamic>> disciplinaHorarios = [];
  List<Aula> aulas = [];
  List<dynamic> horarios = [];
  bool isLoading = true;
  final int itemsPerPage = 5;
  int currentPage = 0;

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

  @override
  void initState() {
    super.initState();
    gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
    iniciando();
  }

  Future<void> iniciando() async {
    setState(() {
      isLoading = true;
    });
    //await carregarDadosExtras();
    await horarioConfiguracaoController.init();
    await carregarDados();
    await fetchDisciplinas();
    await fetchDisciplinasAula();
    await fetchDisciplinaHorarios();
    await fetchHorarios();
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isLoading = false;
      disciplinasAula;
      disciplinas;
      disciplinaHorarios;
      horarios;
    });
  }

  Future<void> carregarDadosExtras() async {
    try {
      AulaController aulaController = AulaController();
      await aulaController.init();
      List<Aula> data = aulaController.getAllAulas();
      for (final item in data) {
        if (item.instrutorDisciplinaTurma_id == '386') {
          aulas_offlines.add(item);
        }
      }
      setState(() {
        aulas_offlines;
      });
    } catch (e) {
      Exception('Erro ao carregar os dados: $e');
    }
  }

  Future<void> carregarDados() async {
    try {
      gestao_ativa_data = await _gestaoAtivaBox.get('gestao_ativa');
      List<Aula> dados =
          await AulasOfflineOnlineServiceAdapter().todasAsAulas(context);

      if (dados.isEmpty) {
        debugPrint('Nenhum dado disponível no momento');
        if (mounted) {
          setState(() {
            aulas_offlines = [];
          });
        }
        return;
      }

      for (final item in dados) {
        item.disciplinas ??= [];
        item.horarios_extras_formatted ??= [];
      }

      if (mounted) {
        setState(() {
          aulas_offlines = dados;
        });
      }
    } catch (e) {
      Exception('Erro ao carregar os dados: $e');
    }
  }

  Future<void> fetchDisciplinas() async {
    try {
      DisciplinaController disciplinaController = DisciplinaController();
      await disciplinaController.init();

      List<Disciplina> fetchedDisciplinas =
          disciplinaController.getAllDisciplinas();

      disciplinas = fetchedDisciplinas;
    } catch (e) {
      // print('Erro ao buscar horários: $e');
      return;
    }
  }

  Future<List<DisciplinaAula>> fetchDisciplinasAula() async {
    try {
      DisciplinaAulaController disciplinaAulaController =
          DisciplinaAulaController();

      await disciplinaAulaController.init();

      disciplinasAula = disciplinaAulaController.getAllAulas();

      return disciplinasAula;
    } catch (e) {
      print('Erro ao buscar horários: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchDisciplinaHorarios() async {
    try {
      DisciplinaAulaController disciplinaAulaController =
          DisciplinaAulaController();
      await disciplinaAulaController.init();
      List<Map<String, dynamic>> fetchedHorarios =
          await disciplinaAulaController.getHorariosExtrasAll();

      setState(() {
        disciplinaHorarios = fetchedHorarios;
      });

      return disciplinaHorarios;
    } catch (e) {
      print('Erro ao buscar horários: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchHorarios() async {
    try {
      HorarioController horarioController = HorarioController();
      await horarioController.init();

      horarios = await horarioController.getAllHorario();

      return horarios;
    } catch (e) {
      print('Erro ao buscar horários: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginatedItems = getPaginatedItems();
    final totalPages = getTotalPages();
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        title: const Text('Aulas'),
        iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
        centerTitle: true,
      ),
      body: isLoading != true
          ? FutureBuilder<List<Aula>>(
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
                        child: RefreshIndicator(
                          color: const Color.fromARGB(255, 229, 157, 3),
                          onRefresh: () async => await iniciando(),
                          child: ListView.builder(
                            itemCount: paginatedItems.length,
                            itemBuilder: (context, index) {
                              //print('criadaPeloCelular: ${paginatedItems[index].criadaPeloCelular.toString()}');
                              //getHorarios(paginatedItems[index].criadaPeloCelular.toString());

                              return paginatedItems[index].e_aula_infantil != 1
                                  ? Card(
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
                                                    Text(
                                                      paginatedItems[index]
                                                                  .dataDaAula !=
                                                              ''
                                                          ? conveterDataAmericaParaBrasil(
                                                              paginatedItems[
                                                                      index]
                                                                  .dataDaAula)
                                                          : '- - -',
                                                      style: const TextStyle(
                                                          fontSize: 16,
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
                                                                color: AppTema
                                                                    .success,
                                                              ),
                                                            ],
                                                          ),
                                                  ]),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              //Text('is_polivalencia: ${paginatedItems[index].is_polivalencia.toString()}'),
                                              paginatedItems[index]
                                                          .is_polivalencia !=
                                                      1
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 4.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          FutureBuilder<String>(
                                                            future: retornarHorarioSelecionado(
                                                                horarioID: paginatedItems[
                                                                        index]
                                                                    .horarioID
                                                                    .toString()),
                                                            builder: (BuildContext
                                                                    context,
                                                                AsyncSnapshot<
                                                                        String>
                                                                    snapshot) {
                                                              const textStyle = TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500);

                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return const Text(
                                                                  '',
                                                                  style:
                                                                      textStyle,
                                                                );
                                                              } else if (snapshot
                                                                      .hasData &&
                                                                  snapshot.data!
                                                                      .isNotEmpty) {
                                                                return Text(
                                                                  snapshot
                                                                      .data!,
                                                                  style: textStyle.copyWith(
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          10,
                                                                          10,
                                                                          10)),
                                                                );
                                                              } else {
                                                                return const Text(
                                                                  'Sem horário',
                                                                  style:
                                                                      textStyle,
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 190,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child:
                                                          SituacaoAulaComponente(
                                                        situacaoAula:
                                                            paginatedItems[
                                                                    index]
                                                                .situacao
                                                                .toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  /*FutureBuilder<String>(
                                        future: retornarHorarioSelecionado(
                                            horarioID: paginatedItems[index]
                                                .horarioID
                                                .toString()),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text(
                                              'Sem horário',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            ); // Exibir um indicador de carregamento enquanto o resultado não estiver disponível
                                          }
                                          if (snapshot.hasData) {
                                            return Expanded(
                                              child: Text(
                                                snapshot.data!,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color.fromARGB(
                                                        255, 10, 10, 10),
                                                    fontWeight: FontWeight.w500),
                                              ),
                                            ); // Exibir o resultado retornado pela função
                                          }
                                          return const Text(
                                            'Sem horário',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ); // Exibir uma mensagem de fallback caso ocorra algum erro
                                        },
                                      ),*/
                                                ],
                                              )
                                            ],
                                          ),
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  top: BorderSide(
                                                    color: Color.fromARGB(
                                                        255, 161, 158, 158),
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ),
                                              padding: const EdgeInsets.only(
                                                  left: 15, top: 10, bottom: 5),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Align(
                                                  //     alignment: Alignment.centerLeft,
                                                  //     child: Container(
                                                  //       margin:
                                                  //           const EdgeInsets.only(bottom: 5),
                                                  //       child: const Text(
                                                  //         'Horários definidos: ',
                                                  //         style: TextStyle(
                                                  //             fontSize: 14,
                                                  //             fontWeight: FontWeight.bold),
                                                  //       ),
                                                  //     ),
                                                  //   ),

                                                  const SizedBox(height: 5),
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
                                                              paginatedItems[
                                                                      index]
                                                                  .tipoDeAula
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                          )
                                                        ],
                                                      )),
                                                  const SizedBox(height: 10),
                                                  //Text('paginatedItems: ${paginatedItems[index].disciplinas.toString()}'),
                                                  paginatedItems[index]
                                                              .is_polivalencia ==
                                                          1
                                                      ? Column(
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  'Disciplinas:',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children:
                                                                      disciplinasAula
                                                                          .map(
                                                                              (disciplina) {
                                                                    if (paginatedItems[index].criadaPeloCelular ==
                                                                            disciplina
                                                                                .criadaPeloCelular &&
                                                                        paginatedItems[index].id ==
                                                                            '') {
                                                                      return Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(disciplina
                                                                              .descricao),
                                                                          //Text('id: ${disciplina.id}'),
                                                                          /// Text('disciplinaHorarios: $disciplinaHorarios'),
                                                                          Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children:
                                                                                disciplinaHorarios.map((horario) {
                                                                              if (horario['id'] == disciplina.id && horario['criadaPeloCelular'] == disciplina.criadaPeloCelular) {
                                                                                return Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: horario['horarios'].map<Widget>((horarioIds) {
                                                                                      return Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: horarios.map((horarioConfig) {
                                                                                          if (horarioConfig['id'] == horarioIds) {
                                                                                            return Text(horarioConfig['descricao'].toString());
                                                                                          }
                                                                                          return const SizedBox();
                                                                                        }).toList(),
                                                                                      );
                                                                                    }).toList(),
                                                                                  ),
                                                                                );
                                                                              }
                                                                              return const SizedBox();
                                                                            }).toList(),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    }
                                                                    return const SizedBox();
                                                                  }).toList(),
                                                                ),
                                                                //Text('disciplinas: $disciplinas'),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    ...paginatedItems[
                                                                            index]
                                                                        .disciplinas!
                                                                        .toSet()
                                                                        .map(
                                                                            (disciplinaId) {
                                                                      // Get the corresponding disciplina object based on the disciplinaId
                                                                      final disciplina =
                                                                          disciplinas
                                                                              .firstWhere(
                                                                        (d) =>
                                                                            d.id.toString() ==
                                                                            disciplinaId.toString(),
                                                                        orElse: () =>
                                                                            disciplinas.first, // Provide a default value or handle differently
                                                                      );
                                                                      return Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(disciplina
                                                                              .descricao
                                                                              .toString()),
                                                                          Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children:
                                                                                paginatedItems[index].horarios_extras_formatted!.map((horario) {
                                                                              if (horario['id'] == disciplina.id) {
                                                                                return Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Column(
                                                                                        children: horario['horarios'].map<Widget>((horarioIds) {
                                                                                          return FutureBuilder<String>(
                                                                                            future: horarioConfiguracaoController.getDescricaoPeloId(horarioId: horarioIds.toString()),
                                                                                            builder: (context, snapshot) {
                                                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                                return const CircularProgressIndicator();
                                                                                              } else if (snapshot.hasError) {
                                                                                                return Text('Error: ${snapshot.error}');
                                                                                              } else if (snapshot.hasData) {
                                                                                                // Perform the comparison here
                                                                                                if (horario['id'].toString() == disciplina.id.toString()) {
                                                                                                  // If IDs match, you can display a specific message or widget
                                                                                                  return Column(
                                                                                                    children: [
                                                                                                      Text(snapshot.data!.toString()), // Example of matched case
                                                                                                    ],
                                                                                                  );
                                                                                                } else {
                                                                                                  // Display the regular description
                                                                                                  return Column(
                                                                                                    children: [
                                                                                                      Text('Description: ${snapshot.data!}'),
                                                                                                    ],
                                                                                                  );
                                                                                                }
                                                                                              } else {
                                                                                                return const Text('Sem horário');
                                                                                              }
                                                                                            },
                                                                                          );
                                                                                        }).toList(),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              }
                                                                              return Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                                child: Column(
                                                                                  children: [
                                                                                    Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: horario['horarios'].map<Widget>((horarioIds) {
                                                                                        return FutureBuilder<String>(
                                                                                          future: horarioConfiguracaoController.getDescricaoPeloId(horarioId: horarioIds.toString()),
                                                                                          builder: (context, snapshot) {
                                                                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                              return const CircularProgressIndicator();
                                                                                            } else if (snapshot.hasError) {
                                                                                              return Text('Error: ${snapshot.error}');
                                                                                            } else if (snapshot.hasData) {
                                                                                              if (horario['id'].toString() == disciplina.id.toString()) {
                                                                                                return Column(
                                                                                                  children: [
                                                                                                    Text(snapshot.data!.toString()), // Example of matched case
                                                                                                  ],
                                                                                                );
                                                                                              } else {
                                                                                                return const SizedBox();
                                                                                              }
                                                                                            } else {
                                                                                              return const Text('Sem horário');
                                                                                            }
                                                                                          },
                                                                                        );
                                                                                      }).toList(),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }).toList(),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    }),
                                                                  ],
                                                                ),
                                                                /*Text('--------------------------'),
                                              Column(
                                                children: paginatedItems[index].disciplinas!.map((disciplinaIds) {
                                                  return Column(
                                                    children: disciplinas.map((disciplina) {
                                                      return Row(
                                                        children: [
                                                          //Text(disciplinaIds.toString()),
                                                          //Text(disciplina.toString()),
                                                          if (disciplinaIds.toString() == disciplina.id) 
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(disciplina.descricao),
                                                                //Text(paginatedItems[index].horarios_extras_formatted.toString()),
                                                                Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children:  paginatedItems[index].horarios_extras_formatted!.map((horario) {
                                                                    if (horario['id'] == disciplina.id) {
                                                                      return Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                        child: Column(
                                                                          children: horario['horarios'].map<Widget>((horarioIds) {
                                                                            return Column(
                                                                              children: horarios.map((horarioConfig){
                                                                                if(horarioConfig['id'] == horarioIds){
                                                                                  return Text(horarioConfig['descricao'].toString());
                                                                                }
                                                                                return const SizedBox();
                                                                              }).toList());
                                                                          }).toList(),
                                                                        ),
                                                                      );
                                                                    }
                                                                    return const SizedBox();
                                                                  }).toList(),
                                                                ),
                                                              ],
                                                            )
                                                          else 
                                                            const SizedBox.shrink(), // Use SizedBox.shrink() to avoid unnecessary space
                                                        ],
                                                      );
                                                    }).toList(),
                                                  );
                                                }).toList(),
                                              ),*/
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                      : const SizedBox(),
                                                  Row(
                                                    children: [
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
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
                                                                              (BuildContext context) {
                                                                            return CustomSyncDialog(
                                                                                onCancel: () => Navigator.of(context).pop(false),
                                                                                onConfirm: () async {
                                                                                  await AulasOfflineSincronizarService().executar(
                                                                                    context,
                                                                                    paginatedItems[index],
                                                                                    paginatedItems[index].experiencias,
                                                                                    paginatedItems[index].series ?? [],
                                                                                  );

                                                                                  await carregarDados();
                                                                                });
                                                                          },
                                                                        );
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                        backgroundColor:
                                                                            Colors.grey[400],
                                                                      ),
                                                                      child:
                                                                          const Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Icon(
                                                                              Icons.sync,
                                                                              color: Colors.white,
                                                                              size: 18),
                                                                          SizedBox(
                                                                              width: 10),
                                                                          Text(
                                                                            'Sincronizar'
                                                                            ' ',
                                                                            style:
                                                                                TextStyle(fontSize: 14, color: Colors.white),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : const SizedBox() /*ElevatedButton(
                                                        onPressed: () {},
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                  5),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Icon(Icons.check,
                                                                color: Colors.white,
                                                                size: 20),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              'Sincronizada',
                                                              style: TextStyle(
                                                                  color:
                                                                      Colors.white),
                                                            ),
                                                          ],
                                                        ),
                                                      ),*/
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
                                                                          aula_id: paginatedItems[index]
                                                                              .criadaPeloCelular
                                                                              .toString(),
                                                                        ),
                                                                      ),
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
                                                                          BorderRadius.circular(
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
                                                                  child:
                                                                      const Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .thumb_up,
                                                                          color: Colors
                                                                              .white,
                                                                          size:
                                                                              18),
                                                                      SizedBox(
                                                                          width:
                                                                              10),
                                                                      Text(
                                                                        'Frequência',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                FrequenciaOnlinePage(
                                                                          aula_id: paginatedItems[index]
                                                                              .id
                                                                              .toString(),
                                                                          selecionandoId: paginatedItems[index]
                                                                              .id
                                                                              .toString(),
                                                                          dataDaAula: paginatedItems[index].dataDaAula != null
                                                                              ? conveterDataAmericaParaBrasil(paginatedItems[index].dataDaAula)
                                                                              : 'sem data',
                                                                        ),
                                                                      ),
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
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    backgroundColor:
                                                                        AppTema
                                                                            .success,
                                                                  ),
                                                                  child:
                                                                      const Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .thumb_up,
                                                                          color: Colors
                                                                              .white,
                                                                          size:
                                                                              18),
                                                                      SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        'Frequência',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
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
                                                                      left:
                                                                          8.0),
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  // print(paginatedItems[
                                                                  //         index]
                                                                  //     .id
                                                                  //     .toString());
                                                                  // print(paginatedItems[
                                                                  //         index]
                                                                  //     .criadaPeloCelular
                                                                  //     .toString());
                                                                  await Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              AulaAtualizarPage(aulaLocalId: paginatedItems[index].criadaPeloCelular.toString())));
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
                                                                      AppTema
                                                                          .primaryDarkBlue,
                                                                ),
                                                                child:
                                                                    const Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            18),
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
                      Text('Tela atual: ${currentPage + 1}'),
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
              },
            )
          : const Center(
              child: CircularProgressIndicator(
              color: AppTema.primaryAmarelo,
            )),
    );
  }
}
