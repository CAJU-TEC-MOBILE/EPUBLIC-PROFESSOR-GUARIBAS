import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/componentes/global/botao_principal_grande.dart';
import 'package:professor_acesso_notifiq/componentes/global/user_info_componente.dart';
import 'package:professor_acesso_notifiq/componentes/graficos/doughnut_grafico_disciplinas_por_gestao_componente.dart';
import 'package:professor_acesso_notifiq/componentes/graficos/stacked_bar_grafico_disciplinas_por_gestao_componente.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/models/disciplina_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/pages/aulas/sem_relacao_dia_horario_para_criar_aula.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../componentes/dialogs/custom_dialogs.dart';
import '../componentes/drawer/custom_drawer.dart';
import '../models/gestao_disciplina_model.dart';
import '../services/controller/disciplina_controller.dart';
import '../services/controller/gestao_disciplina_controller.dart';
import '../services/http/gestoes/gestoes_disciplinas_http.dart';

class PrincipalPage extends StatefulWidget {
  final String? gestaoId;
  const PrincipalPage({super.key, this.gestaoId});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  final GestaoAtiva? gestaoAtivaModel =
      GestaoAtivaServiceAdapter().exibirGestaoAtiva();
  List<Disciplina> disciplinas = [];
  double heightCardAtual = 300.0;
  double heightCardTotal = 00.0;
  String descricaoString = '';
  @override
  void initState() {
    super.initState();
    getFranquiasTotal();
    getFranquiaAtual();
    getDisciplinasPolivalente();
  }

  Future<void> getDisciplinasPolivalente() async {
    if (gestaoAtivaModel!.is_polivalencia != 1) {
      setState(() => disciplinas = []);
      return;
    }

    final DisciplinaController disciplinaController = DisciplinaController();
    await disciplinaController.init();

    String turmaId = gestaoAtivaModel!.idt_turma_id.toString();
    String idtId = gestaoAtivaModel!.idt_id.toString();

    disciplinas = await disciplinaController.getAllDisciplinasPeloTurmaId(
      turmaId: turmaId,
      idtId: idtId,
    );

    descricaoString =
        disciplinas.map((disciplina) => disciplina.descricao).join(', ');

    setState(() => descricaoString);
  }

  Future<void> criacaoAula() async {
    final route = gestaoAtivaModel!.relacoesDiasHorarios.isNotEmpty
        ? gestaoAtivaModel!.is_infantil == true
            ? '/criarAulaInfantil'
            : '/criarAula'
        : '/semRelacaoDiaHorarioParaCriar';

    final arguments = gestaoAtivaModel!.relacoesDiasHorarios.isNotEmpty
        ? {'instrutorDisciplinaTurmaId': widget.gestaoId.toString()}
        : null;

    if (route == '/semRelacaoDiaHorarioParaCriar') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SemRelacaoDiaHorarioParaCriar(),
        ),
      );
    } else {
      Navigator.pushNamed(
        context,
        route,
        arguments: arguments,
      );
    }
  }

  Future<void> start() async {
    try {
      CustomDialogs.showLoadingDialog(context,
          show: true, message: 'Aguardando...');
      GestaoDisciplinaHttp gestaoDisciplinaHttp = GestaoDisciplinaHttp();
      await gestaoDisciplinaHttp.getGestaoDisciplinas();
      await getFranquiaAtual();
      CustomDialogs.showLoadingDialog(context, show: false);
    } catch (e) {
      CustomDialogs.showLoadingDialog(context, show: false);
    }
  }

  Future<void> getFranquiaAtual() async {
    GestaoDisciplinaController gestaoDisciplinaController =
        GestaoDisciplinaController();
    await gestaoDisciplinaController.init();
    //await Future.delayed(const Duration(seconds: 3));

    setState(() {});

    List<dynamic>? lista = await gestaoDisciplinaController.getFranquiaPeloId(
      id: gestaoAtivaModel!.configuracao_id.toString(),
    );

    if (lista == null) {
      return;
    }

    int i = 0;
    double newHeight = heightCardAtual;
    for (var item in lista) {
      if (item is GestaoDisciplina && item.disciplinas != null) {
        for (var disciplina in item.disciplinas) {
          newHeight += 20.0;
        }
      }
    }

    setState(() {
      heightCardAtual = newHeight;
    });
  }

  Future<void> getFranquiasTotal() async {
    try {
      GestaoDisciplinaController gestaoDisciplinaController =
          GestaoDisciplinaController();
      await gestaoDisciplinaController.init();
      //await Future.delayed(const Duration(seconds: 3));

      List<dynamic> lista = await gestaoDisciplinaController.getFranquias();

      int i = 0;

      if (lista == null) {
        return;
      }

      if (lista != null && lista.isNotEmpty) {
        for (var item in lista) {
          if (item is Map<String, dynamic>) {
            heightCardTotal += 80.0;
          }
        }
      }

      setState(() => heightCardTotal);
    } catch (e) {
      print('error-todas-as-franquias: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //print(widget.gestaoId);
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
        centerTitle: true,
        title: const Text(
          'Controle de Aula',
          style: TextStyle(color: AppTema.primaryDarkBlue),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, '/todasAsGestoesDoProfessor');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  color: AppTema.primaryWhite,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Franquia:',
                                style: TextStyle(
                                    color: AppTema.primaryDarkBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Expanded(
                                child: Text(
                                  gestaoAtivaModel!.configuracao_descricao
                                      .toString(),
                                  style: const TextStyle(
                                    color: AppTema.primaryDarkBlue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Turma:',
                                style: TextStyle(
                                    color: AppTema.primaryDarkBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                gestaoAtivaModel!.turma_descricao.toString(),
                                style: const TextStyle(
                                  color: AppTema.primaryDarkBlue,
                                ),
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Disciplina:',
                                style: TextStyle(
                                    color: AppTema.primaryDarkBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              gestaoAtivaModel!.is_polivalencia != 1
                                  ? Text(
                                      gestaoAtivaModel!.disciplina_descricao
                                          .toString(),
                                      style: const TextStyle(
                                        color: AppTema.primaryDarkBlue,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    )
                                  : Expanded(
                                      child: Text(
                                        descricaoString.toString(),
                                        style: const TextStyle(
                                          color: AppTema.primaryDarkBlue,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 12,
                                        softWrap: false,
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Container(
            //   padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
            //   child: Row(
            //     // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       gestaoAtivaModel!.relacoesDiasHorarios.isNotEmpty
            //           ? BotaoPrincipalGrande(
            //               texto: 'Criar Aula',
            //               icon: Icons.add,
            //               cor: AppTema.primaryAmarelo,
            //               onPressed: () => Navigator.pushNamed(
            //                 context,
            //                 gestaoAtivaModel!.is_infantil == true
            //                     ? '/criarAulaInfantil'
            //                     : '/criarAula',
            //                 arguments: {
            //                   'instrutorDisciplinaTurmaId':
            //                       widget.gestaoId.toString()
            //                 },
            //               ),
            //             )
            //           : BotaoPrincipalGrande(
            //               texto: 'Criar Aula',
            //               icon: Icons.add,
            //               cor: AppTema.primaryAmarelo,
            //               onPressed: () => Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                     builder: (context) =>
            //                         SemRelacaoDiaHorarioParaCriar()),
            //               ),
            //             ),
            //       BotaoPrincipalGrande(
            //         texto: 'Ver Aulas',
            //         icon: Icons.list,
            //         cor: AppTema.primaryAmarelo,
            //         onPressed: () => Navigator.pushNamed(
            //             context,
            //             gestaoAtivaModel!.is_infantil == true
            //                 ? '/listagemAulasInfantil'
            //                 : '/listagemAulas',
            //             arguments: {
            //               'instrutorDisciplinaTurmaId':
            //                   widget.gestaoId.toString()
            //             }),
            //       ),
            //       // BotaoPrincipalGrande(
            //       //   texto: 'Gráficos',
            //       //   icon: Icons.bar_chart,
            //       //   cor: AppTema.primaryAmarelo,
            //       //   onPressed: () =>
            //       //       {Navigator.pushNamed(context, '/graficos')},
            //       // ),
            //     ],
            //   ),
            // ),
            Container(
              color: AppTema.backgroundColorApp,
              child: Column(
                children: [
                  // Text('heightCardAtual: $heightCardAtual'),
                  Container(
                    padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                    height: heightCardAtual,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: AppTema.primaryWhite,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 128, 118, 88),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Disciplinas por gestão',
                                    style: TextStyle(
                                      color: AppTema.primaryDarkBlue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Franquia atual',
                                    style: TextStyle(
                                      color: AppTema.primaryDarkBlue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                            child:
                                DoughnutGraficoDisciplinasPorGestaoComponente(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Text('heightCardTotal: $heightCardTotal'),
                  Container(
                    padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                    height: MediaQuery.of(context).size.height,
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: AppTema.primaryWhite,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: AppTema.primaryDarkBlue,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Disciplinas por gestão',
                                      style: TextStyle(
                                          color: AppTema.primaryDarkBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Todas as franquias',
                                      style: TextStyle(
                                          color: AppTema.primaryDarkBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Expanded(
                              child: StackedBarGraficoDisciplinasPorGestao(
                                todasAsFranquias: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            /* Container(
              padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
              height: 400,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: const Color.fromARGB(255, 228, 225, 225),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 128, 118, 88),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Disciplinas por gestão',
                              style: TextStyle(
                                  color: AppTema.primaryAmarelo,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Franquia atual',
                              style: TextStyle(
                                  color: AppTema.primaryAmarelo,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: DoughnutGraficoDisciplinasPorGestaoComponente(
                        todasAsFranquias: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),*/
            /*Container(
              padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
              height: 500,
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: const Color.fromARGB(255, 228, 225, 225),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 217, 168, 6),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Disciplinas por gestão',
                                style: TextStyle(
                                    color: AppTema.primaryAmarelo,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Todas as franquias',
                                style: TextStyle(
                                    color: AppTema.primaryAmarelo,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: StackedBarGraficoDisciplinasPorGestao(
                          todasAsFranquias: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )*/
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.post_add,
        activeIcon: Icons.close,
        backgroundColor: AppTema.primaryDarkBlue,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            elevation: 1.0,
            label: 'Ver Aulas'.toUpperCase(),
            onTap: () => Navigator.pushNamed(
                context,
                gestaoAtivaModel!.is_infantil == true
                    ? '/index-infantil'
                    : '/index-fundamental',
                arguments: {
                  'instrutorDisciplinaTurmaId': widget.gestaoId.toString()
                }),
          ),
          SpeedDialChild(
            elevation: 1.0,
            backgroundColor: AppTema.primaryAmarelo,
            label: 'Criar Aula'.toUpperCase(),
            onTap: () async => await criacaoAula(),
          ),
        ],
      ),
    );
  }
}
