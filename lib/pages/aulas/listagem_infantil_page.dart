import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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

import '../../componentes/appbar/custom_appbar.dart';
import '../../componentes/card/custom_infantil_card.dart';
import '../../componentes/dialogs/custom_dialogs.dart';
import '../../componentes/dialogs/custom_sync_dialog.dart';
import '../../services/controller/aula_controller.dart';
import '../aula_page_controller.dart';

class ListagemInfantilPage extends StatefulWidget {
  const ListagemInfantilPage({super.key});

  @override
  State<ListagemInfantilPage> createState() => _ListagemInfantilPageState();
}

class _ListagemInfantilPageState extends State<ListagemInfantilPage> {
  List<Aula> aulas_offlines = AulasOfflinesListarServiceAdapter().executar();
  final Box _gestaoAtivaBox = Hive.box('gestao_ativa');
  Map<dynamic, dynamic>? gestao_ativa_data;

  final int itemsPerPage = 5;
  int currentPage = 0;
  List<Aula> paginatedItems = [];
  int totalPages = 0;
  bool isLoading = false;
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
    carregarDados();
    getAulas();
  }

  Future<void> carregarDados() async {
    try {
      setState(() => isLoading = true);
      gestao_ativa_data = await _gestaoAtivaBox.get('gestao_ativa');

      List<Aula> dados =
          await AulasOfflineOnlineServiceAdapter().todasAsAulas(context);
      setState(() {
        aulas_offlines = dados;
      });
      setState(() => isLoading = false);
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
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
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTema.backgroundColorApp,
        appBar: CustomAppBar(
          onPressedSynchronizer: () async => await carregarDados(),
        ),
        body: Column(
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
                            return aula.e_aula_infantil == 1
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: CustomInfantilCard(
                                      paginatedItems: aula,
                                      onSync: () async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CustomSyncDialog(
                                              onCancel: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              onConfirm: () async {
                                                AulaController aulaController =
                                                    AulaController();

                                                List<String> experiencia = [];

                                                await aulaController.init();

                                                List<Aula> aulas =
                                                    await aulaController
                                                        .getAulaCriadaPeloCelular(
                                                  criadaPeloCelular:
                                                      aula.criadaPeloCelular,
                                                );

                                                for (final item in aulas) {
                                                  experiencia =
                                                      item.experiencias;
                                                }

                                                await AulasOfflineSincronizarService()
                                                    .executar(
                                                  context,
                                                  aula,
                                                  experiencia,
                                                  aula.series ?? [],
                                                );

                                                await carregarDados();
                                              },
                                            );
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
                                                aula_id: aula.criadaPeloCelular
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
                                              dataDaAula: aula.dataDaAula !=
                                                      null
                                                  ? conveterDataAmericaParaBrasil(
                                                      aula.dataDaAula)
                                                  : 'sem data',
                                              aula: aula,
                                            ),
                                          ),
                                        );
                                      },
                                      onEdit: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AulaInfantilAtualizarPage(
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
                                      child:
                                          // Text('Anterior (Página ${currentPage})'),
                                          const Icon(
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
                                          child:
                                              // Text('Próxima (${currentPage + 2})'),
                                              const Icon(
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
