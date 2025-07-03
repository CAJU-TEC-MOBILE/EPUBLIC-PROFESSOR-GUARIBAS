import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestoes_service_adpater.dart';
import 'package:professor_acesso_notifiq/services/adapters/matriculas_da_turma_ativa_service_adapter.dart';
import '../../componentes/dialogs/custom_snackbar.dart';
import '../../componentes/dialogs/custom_sync_padrao_dialog.dart';
import '../../componentes/global/preloader.dart';
import '../../constants/app_tema.dart';
import '../../models/disciplina_model.dart';
import '../../models/gestao_model.dart';
import '../../services/adapters/gestao_ativa_service_adapter.dart';
import '../../services/controller/disciplina_controller.dart';
import '../../services/controller/gestoes_controller.dart';
import '../aula_page_controller.dart';

class ListagemGestoesProfessor extends StatefulWidget {
  const ListagemGestoesProfessor({super.key});

  @override
  _ListagemGestoesProfessorState createState() =>
      _ListagemGestoesProfessorState();
}

class _ListagemGestoesProfessorState extends State<ListagemGestoesProfessor> {
  final Box _gestoesBox = Hive.box('gestoes');
  final Box _gestaoAtivaBox = Hive.box('gestao_ativa');

  List<dynamic>? gestoes_data = [];
  List<GestaoAtiva>? gestaoAtivaData = [];
  List<Gestao>? gestoes;
  List<bool> isExpandedList = [];
  double fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    getGestao(tipo: 0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggleExpanded(int index) {
    setState(() {
      isExpandedList[index] = !isExpandedList[index];
    });
  }

  Future<void> recarregarPageParaObterNovasGestoes(
      {required BuildContext context}) async {
    try {
      showLoading(context);
      final gestaoCotnroller = GestaoCotnroller();
      await GestoesService().atualizarGestoesDoDispositivo(context);
      await gestaoCotnroller.init();
      await getGestao(tipo: 1);
      hideLoading(context);
    } catch (e) {
      hideLoading(context);
      debugPrint('Erro ao recarregar a página: $e');
    }
  }

  Future<List<Disciplina>> carregarDisciplinas(
      String turmaId, String idtId) async {
    final DisciplinaController disciplinaController = DisciplinaController();
    await disciplinaController.init();

    return await disciplinaController.getAllDisciplinasPeloTurmaId(
      turmaId: turmaId,
      idtId: idtId,
    );
  }

  Future<void> getGestao({required int tipo}) async {
    try {
      final data = await _gestoesBox.get('gestoes') ?? [];

      if (gestoes_data!.isEmpty && tipo == 1) {
        hideLoading(context);
        CustomSnackBar.showInfoSnackBar(
          context,
          'Nenhuma gestão encontrada para o instrutor.',
        );
        return;
      }

      if (mounted) {
        setState(() {
          gestoes_data = data;
          isExpandedList = List.filled(gestoes_data?.length ?? 0, false);
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> pageAula(item) async {
    final aulaPageController = AulaPageController();
    await _gestaoAtivaBox.put('gestao_ativa', item);
    GestaoAtivaServiceAdapter.instrutorDisciplinaTurma_id =
        item['idt_id'].toString();
    await MatriculasDaTurmaAtivaServiceAdapter().salvar();
    await aulaPageController.gestaoAtivaLista(
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTema.backgroundColorApp,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
          automaticallyImplyLeading: true,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.sync,
                color: Colors.black,
                size: 25,
              ),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomSyncPadraoDialog(
                      message: "Deseja atualizar todas as gestões?",
                      onCancel: () => Navigator.of(context).pop(false),
                      onConfirm: () async {
                        showLoading(context);
                        await recarregarPageParaObterNovasGestoes(
                            context: context);
                        hideLoading(context);
                        Navigator.pop(context);
                        CustomSnackBar.showSuccessSnackBar(
                          context,
                          'As gestões foram atualizadas com sucesso!',
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
          title: const Text('Gestões'),
        ),
        body: gestoes_data == null || gestoes_data!.isEmpty
            ? const Center(child: Text('Nenhuma gestão encontrada'))
            : RefreshIndicator(
                onRefresh: () async =>
                    await recarregarPageParaObterNovasGestoes(context: context),
                color: AppTema.primaryDarkBlue,
                backgroundColor: AppTema.backgroundColorApp,
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 8,
                  child: ListView.builder(
                    itemCount: gestoes_data?.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Card(
                          color: AppTema.primaryWhite,
                          elevation: 1.0,
                          child: Column(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: AppTema.primaryDarkBlue,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0),
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    gestoes_data?[index][0]
                                            ['configuracao_descricao'] ??
                                        '- - -',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: gestoes_data?[index].length,
                                itemBuilder:
                                    (BuildContext context, int innerIndex) {
                                  final item = gestoes_data?[index][innerIndex];
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: InkWell(
                                      onTap: () async {
                                        await pageAula(item);
                                      },
                                      child: Card(
                                        color: AppTema.primaryWhite,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    '#',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: fontSize,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Wrap(
                                                      children: [
                                                        Text(
                                                          item['idt_id']
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: fontSize,
                                                            color: Colors.black,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Turma:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: fontSize,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4.0),
                                                  Expanded(
                                                    child: Wrap(
                                                      children: [
                                                        Text(
                                                          item?['turma_descricao'] ??
                                                              '- - -',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: fontSize,
                                                            color:
                                                                Colors.black38,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              item['is_polivalencia'] != 1
                                                  ? Row(
                                                      children: [
                                                        Text(
                                                          'Disciplina:',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: fontSize,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4.0),
                                                        Expanded(
                                                          child: Wrap(
                                                            children: [
                                                              Text(
                                                                item?['disciplina_descricao'] ??
                                                                    '- - -',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize:
                                                                      fontSize,
                                                                  color: Colors
                                                                      .black38,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      children: [
                                                        Expanded(
                                                          child: FutureBuilder<
                                                              List<Disciplina>>(
                                                            future: carregarDisciplinas(
                                                                item['idt_turma_id']
                                                                    .toString(),
                                                                item['idt_id']
                                                                    .toString()),
                                                            builder: (BuildContext
                                                                    context,
                                                                AsyncSnapshot<
                                                                        List<
                                                                            Disciplina>>
                                                                    snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return const CircularProgressIndicator();
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return const Text(
                                                                    'Erro ao carregar disciplinas');
                                                              } else if (!snapshot
                                                                      .hasData ||
                                                                  snapshot.data!
                                                                      .isEmpty) {
                                                                return const Text(
                                                                    'Nenhuma disciplina encontrada');
                                                              } else {
                                                                return RichText(
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Disciplinas: ',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              fontSize,
                                                                          color:
                                                                              Colors.black54,
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text: snapshot
                                                                            .data!
                                                                            .map((disciplina) =>
                                                                                disciplina.descricao ??
                                                                                '---')
                                                                            .join(', '),
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          fontSize:
                                                                              fontSize,
                                                                          color:
                                                                              Colors.black38,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
