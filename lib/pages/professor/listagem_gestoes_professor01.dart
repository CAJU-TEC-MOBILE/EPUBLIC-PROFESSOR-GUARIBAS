import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/constants/emojis.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestoes_service_adpater.dart';
import 'package:professor_acesso_notifiq/services/adapters/matriculas_da_turma_ativa_service_adapter.dart';

import '../../componentes/drawer/custom_drawer.dart';
import '../../constants/app_tema.dart';
import '../../models/disciplina_model.dart';
import '../../models/gestao_ativa_model.dart';
import '../../services/adapters/gestao_ativa_service_adapter.dart';
import '../../services/controller/disciplina_controller.dart';

class ListagemGestoesProfessor extends StatefulWidget {
  const ListagemGestoesProfessor({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ListagemGestoesProfessorState createState() =>
      _ListagemGestoesProfessorState();
}

class _ListagemGestoesProfessorState extends State<ListagemGestoesProfessor> {
  final Box _gestoesBox = Hive.box('gestoes');
  final Box _gestaoAtivaBox = Hive.box('gestao_ativa');
  // ignore: unused_field
  // ignore: non_constant_identifier_names
  List<dynamic>? gestoes_data;
  List<bool> isExpandedList = [];
  // ignore: prefer_final_fields
  Box _authBox = Hive.box('auth');
  @override
  void initState() {
    super.initState();
    gestoes_data = _gestoesBox.get('gestoes');
    isExpandedList = List.filled(gestoes_data?.length ?? 0, false);
  }

  void removerDadosAuth() {
    _authBox.clear();
  }

  void toggleExpanded(int index) {
    setState(() {
      isExpandedList[index] = !isExpandedList[index];
    });
  }

  Future<void> recarregarPageParaObterNovasGestoes() async {
    await GestoesService().atualizarGestoesDoDispositivo(context);
    setState(() {
      gestoes_data = _gestoesBox.get('gestoes');
      isExpandedList = List.filled(gestoes_data?.length ?? 0, false);
    });
    await GestaoAtivaServiceAdapter().exibirGestaoAtiva();
  }

  Future<List<Disciplina>> carregarDisciplinas(
      String turmaId, String idtId) async {
    final DisciplinaController disciplinaController = DisciplinaController();
    await disciplinaController.init();
    final List<Disciplina> dados = disciplinaController.getAllDisciplinas();
    //print(dados.toString());
    return await disciplinaController.getAllDisciplinasPeloTurmaId(
      turmaId: turmaId,
      idtId: idtId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              await recarregarPageParaObterNovasGestoes();
            },
          ),
          // PopupMenuButton<String>(
          //   color: Colors.white,
          //   iconColor: Colors.black,
          //   onSelected: (String value) {
          //     setState(() {});
          //   },
          //   itemBuilder: (BuildContext context) => [
          //     PopupMenuItem(
          //       value: '1',
          //       child: const Text('Perfil'),
          //       onTap: () => Navigator.pushNamed(context, '/perfil'),
          //     ),
          //     PopupMenuItem(
          //       value: '2',
          //       child: const Text('Sair'),
          //       onTap: () async {
          //         Navigator.pushReplacementNamed(context, '/login');
          //         removerDadosAuth();
          //       },
          //     ),
          //   ],
          // )
        ],
        title: const Text('Gestões'),
      ),
      // drawer: const CustomDrawer(),
      body: Container(
        color: AppTema.backgroundColorApp,
        child: FutureBuilder<List<dynamic>>(
          future: Future.value(gestoes_data),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Text('Carregando...'),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Erro ao carregar os dados ${Emojis.sadEmoji}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await recarregarPageParaObterNovasGestoes();
                      },
                      child: const Icon(Icons.sync),
                    ),
                  ],
                ),
              );
            } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: () async =>
                    await recarregarPageParaObterNovasGestoes(),
                color: AppTema.primaryDarkBlue,
                child: ListView.builder(
                  itemCount: gestoes_data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: AppTema.primaryWhite,
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                color: AppTema.primaryDarkBlue,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0),
                                )),
                            child: ListTile(
                              onTap: () => toggleExpanded(index),
                              title: Text(
                                gestoes_data?[index][0]
                                        ['configuracao_descricao'] ??
                                    '- - -',
                                style: const TextStyle(color: Colors.white),
                              ),
                              // leading: IconButton(
                              //   icon: Icon(
                              //     Icons.sync,
                              //     color: Colors.white,
                              //     size: 25,
                              //   ),
                              //   onPressed: () async {
                              //     await recarregarPageParaObterNovasGestoes();
                              //   },
                              // ),
                              trailing: IconButton(
                                color: Colors.white,
                                icon: Icon(
                                  isExpandedList[index]
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onPressed: () => toggleExpanded(index),
                              ),
                            ),
                          ),
                          if (isExpandedList[index])
                            RefreshIndicator(
                              onRefresh: () =>
                                  recarregarPageParaObterNovasGestoes(),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: gestoes_data?[index].length,
                                itemBuilder:
                                    (BuildContext context, int innerIndex) {
                                  final item = gestoes_data?[index][innerIndex];
                                  //print('item: ${item['is_polivalencia'].toString()} - ${item['disciplina_descricao'].toString()}');
                                  /*if(item['disciplina_descricao'] != 'null' ){
                                      return const SizedBox();
                                    }*/
                                  // print(
                                  //     'idt_id: ${item['idt_id']} is_polivalencia: ${item['is_polivalencia']} TurmaId: ${item['idt_turma_id']}');
                                  return InkWell(
                                    onTap: () async {
                                      await _gestaoAtivaBox.put(
                                          'gestao_ativa', item);
                                      GestaoAtivaServiceAdapter
                                              .instrutorDisciplinaTurma_id =
                                          item['idt_id'].toString();
                                      await MatriculasDaTurmaAtivaServiceAdapter()
                                          .salvar();
                                      await Navigator.pushReplacementNamed(
                                          context, '/principal');
                                    },
                                    child: Card(
                                      color: AppTema.primaryWhite,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  '#',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10.0,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Wrap(
                                                    children: [
                                                      Text(
                                                        item['idt_id']
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 10.0,
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
                                                const Text(
                                                  'Turma:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                                const SizedBox(width: 4.0),
                                                Expanded(
                                                  child: Wrap(
                                                    children: [
                                                      Text(
                                                        item?['turma_descricao'] ??
                                                            '- - -',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 16.0,
                                                          color: Colors.black38,
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
                                                      const Text(
                                                        'Disciplina:',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.0,
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
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16.0,
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
                                                : const Row(
                                                    children: [
                                                      Text(
                                                        'Disciplinas:',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            /*Row(
                                                children: [
                                                  const SizedBox(width: 4.0),
                                                  item['is_polivalencia'] == 1
                                                      ? Expanded(
                                                          child: Wrap(
                                                            children: [
                                                              Chip(
                                                                label:
                                                                    const Text(
                                                                  'Polivalencia',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        8.0,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                ),
                                                                backgroundColor:
                                                                    AppTema
                                                                        .primaryAmarelo,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  side:
                                                                      const BorderSide(
                                                                    color: AppTema
                                                                        .primaryAmarelo,
                                                                    width:
                                                                        1.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : const SizedBox()
                                                ],
                                              ),*/
                                            item['is_polivalencia'] == 1
                                                ? Row(
                                                    children: [
                                                      FutureBuilder<
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
                                                            return Container(
                                                              child: Wrap(
                                                                direction: Axis
                                                                    .vertical,
                                                                children: snapshot
                                                                    .data!
                                                                    .map(
                                                                        (disciplina) {
                                                                  return Chip(
                                                                    color: const WidgetStatePropertyAll(
                                                                        AppTema
                                                                            .primaryWhite),
                                                                    label: Text(
                                                                      disciplina
                                                                              .descricao ??
                                                                          '---',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        fontSize:
                                                                            12.0,
                                                                        color: Colors
                                                                            .black38,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          1,
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Sem gestões vinculadas ${Emojis.sadEmoji}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await recarregarPageParaObterNovasGestoes();
                      },
                      child: const SizedBox(
                        width: 95,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Recarregar'),
                            SizedBox(
                              width: 3,
                            ),
                            Icon(
                              Icons.sync,
                              size: 16,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
