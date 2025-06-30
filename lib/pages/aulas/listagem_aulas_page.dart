import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/converter_data_america_para_brasil.dart';
import 'package:professor_acesso_notifiq/help/console_log.dart';
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
import '../../services/controller/aula_controller.dart';
import '../../services/controller/disciplina_aula_controller.dart';
import '../../services/controller/disciplina_controller.dart';
import '../../services/controller/horario_configuracao_controller.dart';
import '../../services/controller/horario_controller.dart';
import '../../models/gestao_ativa_model.dart';
import '../../services/adapters/gestao_ativa_service_adapter.dart';
import '../aula_page_controller.dart';

class ListagemAulasPage extends StatefulWidget {
  final String? instrutorDisciplinaTurmaId;
  const ListagemAulasPage({super.key, this.instrutorDisciplinaTurmaId});
  @override
  State<ListagemAulasPage> createState() => _ListagemAulasPageState();
}

class _ListagemAulasPageState extends State<ListagemAulasPage> {
  GestaoAtiva? gestaoAtivaModel;

  List<Aula> aulas_offlines = AulasOfflinesListarServiceAdapter().executar();
  final horarioConfiguracaoController = HorarioConfiguracaoController();

  Box _gestaoAtivaBox = Hive.box('gestao_ativa');

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

    aulas_offlines.sort((a, b) {
      final aId = int.tryParse('${a.id}') ?? -1;
      final bId = int.tryParse('${b.id}') ?? -1;

      if (aId < 0 && bId >= 0) return -1;
      if (aId >= 0 && bId < 0) return 1;

      return bId.compareTo(aId);
    });
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
    try {
      setState(() {
        isLoading = true;
      });

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
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'error-iniciando',
        mensagem: e.toString(),
        tipo: 'erro',
      );
    }
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
    try {
      setState(() {
        paginatedItems = getPaginatedItems();
        totalPages = getTotalPages();
      });
      ordenaPeloStatus();
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'error-get-aulas',
        mensagem: e.toString(),
        tipo: 'erro',
      );
    }
  }

  Future<void> pageAula(item) async {
    final aulaPageController = AulaPageController();
    await aulaPageController.setAula(
      context: context,
    );
  }

  Future<void> ordenaPeloStatus() async {
    paginatedItems.sort((a, b) {
      final aId = int.tryParse('${a.id}') ?? -1;
      final bId = int.tryParse('${b.id}') ?? -1;

      if (aId < 0 && bId >= 0) return -1;
      if (aId >= 0 && bId < 0) return 1;

      return bId.compareTo(aId);
    });
  }

  @override
  Widget build(BuildContext context) {
    getAulas();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/todasAsGestoesDoProfessor');
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTema.backgroundColorApp,
        appBar: CustomAppBar(
          onPressedSynchronizer: () async => await iniciando(),
        ),
        body: isLoading != true
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: paginatedItems.isNotEmpty
                        ? Scrollbar(
                            thumbVisibility: true,
                            trackVisibility: true,
                            thickness: 8,
                            child: SingleChildScrollView(
                              child: Column(
                                children: paginatedItems.map((aula) {
                                  return aula.e_aula_infantil != 1
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: CustomFundamentalCard(
                                            paginatedItems: aula,
                                            onSync: () async {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return CustomSyncDialog(
                                                      onCancel: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      onConfirm: () async {
                                                        await AulasOfflineSincronizarService()
                                                            .executar(
                                                          context,
                                                          aula,
                                                          aula.experiencias,
                                                          aula.series ?? [],
                                                        );
                                                        await carregarDados();
                                                      });
                                                },
                                              );
                                            },
                                            onFrequencia: () async {
                                              if (aula.id.toString().isEmpty) {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FrequenciaOfflinePage(
                                                      aula_id: aula
                                                          .criadaPeloCelular
                                                          .toString(),
                                                      aula: aula,
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
                                                    aula_id: aula.id.toString(),
                                                    selecionandoId:
                                                        aula.id.toString(),
                                                    dataDaAula: aula
                                                                .dataDaAula !=
                                                            null
                                                        ? conveterDataAmericaParaBrasil(
                                                            aula.dataDaAula,
                                                          )
                                                        : 'sem data',
                                                    aula: aula,
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
                                                    aulaLocalId: aula
                                                        .criadaPeloCelular
                                                        .toString(),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : const SizedBox();
                                }).toList(),
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              'Sem aulas no momento',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: AppTema.primaryAmarelo,
                ),
              ),
        floatingActionButton: isLoading != true
            ? Padding(
                padding: EdgeInsets.only(
                  bottom: totalPages > 1 ? 0.0 : 8.0,
                  right: totalPages > 1 ? 0.0 : 8.0,
                ),
                child: FloatingActionButton(
                  onPressed: () async => await pageAula(context),
                  backgroundColor: AppTema.primaryDarkBlue,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.post_add),
                ),
              )
            : const SizedBox(),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniEndDocked,
        bottomNavigationBar: isLoading != true && totalPages != 0
            ? SizedBox(
                height: totalPages > 1 ? 68.0 : 24.0,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${currentPage + 1} / ${totalPages.toString()}'),
                      ],
                    ),
                    totalPages > 1
                        ? Row(
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
                                      child: const Icon(
                                        Icons.arrow_circle_left,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const SizedBox(),
                              currentPage > 0 && (currentPage + 1) < totalPages
                                  ? const SizedBox(width: 16)
                                  : const SizedBox(),
                              (currentPage + 1) < totalPages
                                  ? Column(
                                      children: [
                                        ElevatedButton(
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
                                          child: const Icon(
                                            Icons.arrow_circle_right,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    )
                                  : const SizedBox()
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}
