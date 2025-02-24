import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
import '../../componentes/appbar/custom_appbar.dart';
import '../../componentes/card/custom_fundamental_card.dart';
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
import '../aula_page_controller.dart';

class ListagemFundamentalPage extends StatefulWidget {
  final String? instrutorDisciplinaTurmaId;
  const ListagemFundamentalPage({super.key, this.instrutorDisciplinaTurmaId});

  @override
  State<ListagemFundamentalPage> createState() => _ListagemAulasPageState();
}

class _ListagemAulasPageState extends State<ListagemFundamentalPage> {
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
  List<Aula> paginatedItems = [];
  int totalPages = 0;

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
    await getAulas();
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
      List<Aula> data = await aulaController.getAllAulas();
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

  Future<void> getAulas() async {
    setState(() {
      paginatedItems = getPaginatedItems();
      paginatedItems.sort((a, b) {
        if ((a.id ?? '').isEmpty && (b.id ?? '').isNotEmpty) {
          return -1;
        } else if ((a.id ?? '').isNotEmpty && (b.id ?? '').isEmpty) {
          return 1;
        }

        if (a.dataDaAula != null && b.dataDaAula != null) {
          return a.dataDaAula.compareTo(b.dataDaAula);
        } else if (a.dataDaAula != null) {
          return -1;
        } else if (b.dataDaAula != null) {
          return 1;
        }
        return 0;
      });

      totalPages = getTotalPages();
    });
  }

  Future<void> pageAula(item) async {
    final aulaPageController = AulaPageController();
    await aulaPageController.setAula(
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    getAulas();
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/todasAsGestoesDoProfessor');
        return false; // Impede a navegação para a tela anterior
      },
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.primaryDelta! > 0) {
            Navigator.pushNamed(context, '/todasAsGestoesDoProfessor');
          }
        },
        child: Scaffold(
          backgroundColor: AppTema.backgroundColorApp,
          appBar: CustomAppBar(
            onPressedSynchronizer: () async => await iniciando(),
          ),
          // AppBar(
          //   title: const Text(
          //     'Aulas',
          //     style: TextStyle(color: AppTema.primaryDarkBlue),
          //   ),
          //   iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
          //   centerTitle: true,
          // ),
          body: isLoading != true
              ? FutureBuilder<List<Aula>>(
                  future: Future.value(aulas_offlines),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Text('carregando...'));
                    } else if (snapshot.hasError) {
                      return const Text('Erro ao carregar os dados');
                    } else if (snapshot.data!.isNotEmpty &&
                        snapshot.data != null) {
                      return Column(
                        children: [
                          Expanded(
                            child: RefreshIndicator(
                              backgroundColor: AppTema.primaryWhite,
                              color: AppTema.primaryDarkBlue,
                              onRefresh: () async => await iniciando(),
                              child: ListView.builder(
                                itemCount: paginatedItems.length,
                                itemBuilder: (context, index) {
                                  return paginatedItems[index]
                                              .e_aula_infantil !=
                                          1
                                      ? CustomFundamentalCard(
                                          paginatedItems: paginatedItems[index],
                                          onSync: () async {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomSyncDialog(
                                                    onCancel: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    onConfirm: () async {
                                                      await AulasOfflineSincronizarService()
                                                          .executar(
                                                        context,
                                                        paginatedItems[index],
                                                        paginatedItems[index]
                                                            .experiencias,
                                                        paginatedItems[index]
                                                                .series ??
                                                            [],
                                                      );
                                                      await carregarDados();
                                                    });
                                              },
                                            );
                                          },
                                          onFrequencia: () async {
                                            if (paginatedItems[index]
                                                .id
                                                .toString()
                                                .isEmpty) {
                                              //print('aula_id: ${paginatedItems[index].criadaPeloCelular.toString()}');
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FrequenciaOfflinePage(
                                                    aula_id:
                                                        paginatedItems[index]
                                                            .criadaPeloCelular
                                                            .toString(),
                                                    aula: paginatedItems[index],
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FrequenciaOnlinePage(
                                                  aula_id: paginatedItems[index]
                                                      .id
                                                      .toString(),
                                                  selecionandoId:
                                                      paginatedItems[index]
                                                          .id
                                                          .toString(),
                                                  dataDaAula: paginatedItems[
                                                                  index]
                                                              .dataDaAula !=
                                                          null
                                                      ? conveterDataAmericaParaBrasil(
                                                          paginatedItems[index]
                                                              .dataDaAula,
                                                        )
                                                      : 'sem data',
                                                  aula: paginatedItems[index],
                                                ),
                                              ),
                                            );
                                          },
                                          onEdit: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AulaAtualizarPage(
                                                  aulaLocalId:
                                                      paginatedItems[index]
                                                          .criadaPeloCelular
                                                          .toString(),
                                                ),
                                              ),
                                            );
                                          },
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        backgroundColor:
                                            AppTema.primaryDarkBlue,
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        backgroundColor:
                                            AppTema.primaryDarkBlue,
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        backgroundColor:
                                            AppTema.primaryDarkBlue,
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        backgroundColor:
                                            AppTema.primaryDarkBlue,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_circle_right,
                                        color: Colors.white,
                                      ),
                                    )
                            ],
                          ),
                          // Text('Tela atual: ${currentPage + 1}'),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Sem aulas no momento.',
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: AppTema.primaryAmarelo,
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async => await pageAula(context),
            backgroundColor: AppTema.primaryDarkBlue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.post_add),
          ),
        ),
      ),
    );
  }
}
