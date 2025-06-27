import 'dart:convert';

import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/help/console_log.dart';
import 'package:professor_acesso_notifiq/models/aula_totalizador_model.dart';
import 'package:professor_acesso_notifiq/models/professor_model.dart';
import 'package:professor_acesso_notifiq/pages/professor/listagem_gestoes_professor.dart';

import '../componentes/card/custom_sugestao_card.dart';
import '../componentes/dialogs/custom_snackbar.dart';
import '../componentes/dialogs/custom_sync_dialog.dart';
import '../componentes/drawer/custom_drawer.dart';
import '../componentes/global/preloader.dart';
import '../models/ano_model.dart';
import '../models/auth_model.dart';
import '../models/gestao_ativa_model.dart';
import '../services/adapters/auth_service_adapter.dart';
import '../services/adapters/gestao_ativa_service_adapter.dart';
import '../services/adapters/gestoes_service_adpater.dart';
import '../services/connectivity/internet_connectivity_service.dart';
import '../services/controller/ano_controller.dart';
import '../services/controller/ano_selecionado_controller.dart';
import '../services/controller/aula_totalizador_controller.dart';
import '../services/controller/auth_controller.dart';
import '../services/http/aulas/aula_totalizador_http.dart';
import '../services/http/gestoes/gestoes_disciplinas_http.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loadingCard = false;
  AnoController anoController = AnoController();
  final authController = AuthController();
  Map<dynamic, dynamic> gestao_ativa_data = {};

  AuthModel? authModel;
  Professor professor = Professor.vazio();
  GestaoAtiva? gestaoAtivaModel;
  AulaTotalizador? totalizadorAula;

  Future<void> getInformacoes() async {
    try {
      await authController.init();
      professor = await authController.authProfessorFirst();

      if (professor.id == '') {
        return;
      }

      await getDados();
      gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
      await getHomeAula(professor: professor);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'get-informacoes',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  Future<void> realizarSincronizacaoGeral() async {
    try {
      await authController.init();
      professor = await authController.authProfessorFirst();

      if (professor.id == '') {
        return;
      }

      await getDados();
      gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
      await getHomeAulaGeral(professor: professor);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'realizar0-sincronizacao-geral',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getInformacoes();
  }

  Future<void> getHomeAulaGeral({required Professor? professor}) async {
    AulaTotalizadorHttp aulaTotalizadorHttp = AulaTotalizadorHttp();
    AulaTotalizadorController aulaTotalizadorController =
        AulaTotalizadorController();

    if (professor == null) {
      ConsoleLog.mensagem(
        titulo: 'Erro',
        mensagem: 'O objeto professor é nulo. Operação abortada.',
        tipo: 'erro',
      );
      return;
    }

    String professorId = professor.id.toString();
    if (professorId.isEmpty) {
      ConsoleLog.mensagem(
        titulo: 'Erro',
        mensagem: 'O ID do professor está vazio. Operação abortada.',
        tipo: 'erro',
      );
      return;
    }

    try {
      final response =
          await aulaTotalizadorHttp.getAulasTotalizadas(id: professorId);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (!data.containsKey('id_professor') ||
            !data.containsKey('ano_atual') ||
            !data.containsKey('total_aula')) {
          ConsoleLog.mensagem(
            titulo: 'Erro',
            mensagem: 'Dados obrigatórios ausentes na resposta.',
            tipo: 'erro',
          );

          return;
        }

        await aulaTotalizadorController.init();

        await aulaTotalizadorController.clearAll();

        final AulaTotalizador dado = AulaTotalizador(
          id: 0,
          idProfessor: data['id_professor'] ?? -1,
          anoAtual: data['ano_atual'] ?? DateTime.now().year,
          totalAula: data['total_aula'] ?? 0,
          qntAguardandoConfirmacao: data['qnt_aguardando_confirmacao'] ?? 0,
          qntConfirmada: data['qnt_confirmada'] ?? 0,
          qntConflito: data['qnt_conflito'] ?? 0,
          qntFalta: data['qnt_falta'] ?? 0,
          qntInvalida: data['qnt_invalida'] ?? 0,
        );

        await aulaTotalizadorController.init();

        await aulaTotalizadorController.addAula(dado);

        await getDados();

        await anoController.init();

        final ano = await anoController.getAnoDescricao(
          descricao: dado.anoAtual.toString(),
        );

        await setSelectedAno(ano: ano, context: context);

        ConsoleLog.mensagem(
          titulo: 'Sucesso',
          mensagem: 'Dados processados com sucesso.',
          tipo: 'sucesso',
        );

        return;
      } else {
        ConsoleLog.mensagem(
          titulo: 'Erro',
          mensagem: 'Erro: Resposta com status ${response.statusCode}.',
          tipo: 'erro',
        );
      }
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'Erro',
        mensagem: 'método getHomeAula: $e',
        tipo: 'erro',
      );
    }
  }

  Future<void> getHomeAula({required Professor? professor}) async {
    AulaTotalizadorHttp aulaTotalizadorHttp = AulaTotalizadorHttp();
    AulaTotalizadorController aulaTotalizadorController =
        AulaTotalizadorController();

    if (professor == null) {
      ConsoleLog.mensagem(
        titulo: 'Erro',
        mensagem: 'O objeto professor é nulo. Operação abortada.',
        tipo: 'erro',
      );
      return;
    }

    String professorId = professor.id.toString();
    if (professorId.isEmpty) {
      ConsoleLog.mensagem(
        titulo: 'Erro',
        mensagem: 'O ID do professor está vazio. Operação abortada.',
        tipo: 'erro',
      );
      return;
    }

    try {
      final response =
          await aulaTotalizadorHttp.getAulasTotalizadas(id: professorId);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (!data.containsKey('id_professor') ||
            !data.containsKey('ano_atual') ||
            !data.containsKey('total_aula')) {
          ConsoleLog.mensagem(
            titulo: 'Erro',
            mensagem: 'Dados obrigatórios ausentes na resposta.',
            tipo: 'erro',
          );

          return;
        }

        await aulaTotalizadorController.init();

        await aulaTotalizadorController.clearAll();

        final AulaTotalizador dado = AulaTotalizador(
          id: 0,
          idProfessor: data['id_professor'] ?? -1,
          anoAtual: data['ano_atual'] ?? DateTime.now().year,
          totalAula: data['total_aula'] ?? 0,
          qntAguardandoConfirmacao: data['qnt_aguardando_confirmacao'] ?? 0,
          qntConfirmada: data['qnt_confirmada'] ?? 0,
          qntConflito: data['qnt_conflito'] ?? 0,
          qntFalta: data['qnt_falta'] ?? 0,
          qntInvalida: data['qnt_invalida'] ?? 0,
        );

        await aulaTotalizadorController.init();

        await aulaTotalizadorController.addAula(dado);

        await getDados();

        ConsoleLog.mensagem(
          titulo: 'Sucesso',
          mensagem: 'Dados processados com sucesso.',
          tipo: 'sucesso',
        );

        return;
      } else {
        ConsoleLog.mensagem(
          titulo: 'Erro',
          mensagem: 'Erro: Resposta com status ${response.statusCode}.',
          tipo: 'erro',
        );
      }
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'Erro',
        mensagem: 'método getHomeAula: $e',
        tipo: 'erro',
      );
    }
  }

  Future<void> getDados() async {
    AulaTotalizadorController aulaTotalizadorController =
        AulaTotalizadorController();
    await aulaTotalizadorController.init();

    totalizadorAula = await aulaTotalizadorController.getAulaTotalizador();
    if (totalizadorAula == null) {
      await aulaTotalizadorController.clearAll();

      final AulaTotalizador dado = AulaTotalizador(
        id: 0,
        idProfessor: -1,
        anoAtual: DateTime.now().year,
        totalAula: 0,
        qntAguardandoConfirmacao: 0,
        qntConfirmada: 0,
        qntConflito: 0,
        qntFalta: 0,
        qntInvalida: 0,
      );

      await aulaTotalizadorController.addAula(dado);
    }

    setState(() {
      totalizadorAula = totalizadorAula;
    });
  }

  Future<void> setSelectedAno(
      {required Ano ano, required BuildContext context}) async {
    debugPrint("==============================================");

    final anoSelecionadoController = AnoSelecionadoController();
    bool isConnectedNotifier = await InternetConnectivityService.isConnected();

    if (!isConnectedNotifier) {
      hideLoading(context);
      CustomSnackBar.showErrorSnackBar(
        context,
        'Você está offline no momento. Verifique sua conexão com a internet.',
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
      return;
    }

    final authController = AuthController();

    await anoSelecionadoController.init();

    await authController.init();

    int anoId = int.parse(ano.id.toString());

    await anoSelecionadoController.setAnoSelecionado(ano);

    ano = await anoSelecionadoController.getAnoSelecionado();

    await authController.updateAnoId(anoId: anoId);

    await recarregarPageParaObterNovasGestoes();

    await getFranquiaAtualHttp();

    await Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );

    hideLoading(context);
  }

  Future<void> getFranquiaAtualHttp() async {
    GestaoDisciplinaHttp gestaoDisciplinaHttp = GestaoDisciplinaHttp();
    await gestaoDisciplinaHttp.getGestaoDisciplinas();
  }

  Future<void> recarregarPageParaObterNovasGestoes() async {
    await GestoesService().atualizarGestoes(context);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      child: Scaffold(
        backgroundColor: AppTema.backgroundColorApp,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
          title: const Text(
            'Home',
            style: TextStyle(color: AppTema.primaryDarkBlue),
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
                    return CustomSyncDialog(
                      message: "'Deseja sincronizar dados?",
                      onCancel: () => Navigator.of(context).pop(false),
                      onConfirm: () async {
                        showLoading(context);
                        await realizarSincronizacaoGeral();
                        hideLoading(context);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        drawer: const CustomDrawer(),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Card(
                //   color: AppTema.primaryWhite,
                //   elevation: 1.0,
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: CustomBuscarTextFormField(
                //       controller: TextEditingController(),
                //       borderColor: AppTema.primaryAmarelo,
                //       labelColor: AppTema.primaryDarkBlue,
                //       cursorColor: AppTema.primaryDarkBlue,
                //       labelText: 'Pesquisar',
                //       hintText: 'Digite sua pesquisa',
                //       onSearch: () {
                //         print('Buscar acionado');
                //       },
                //     ),
                //   ),
                // ),
                const CustomSugestaoCard(
                  titulo: 'Ajude-nos a melhorar\ncom suas sugestões!',
                  imagem: 'assets/image_professor.png',
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Card(
                    color: AppTema.primaryWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 1.0,
                    child: Row(
                      children: [
                        totalizadorAula != null
                            ? Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Aulas',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: AppTema.primaryDarkBlue,
                                            ),
                                          ),
                                          Text(
                                            totalizadorAula!.anoAtual
                                                .toString(),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: AppTema.primaryDarkBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Aula confirmada:"),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                  totalizadorAula!.qntConfirmada
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  "Aguardando confirmação",
                                                ),
                                                const SizedBox(
                                                  width: 8.0,
                                                ),
                                                Text(
                                                  totalizadorAula!
                                                      .qntAguardandoConfirmacao
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                    "Aula rejeitada por falta"),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                  totalizadorAula!.qntFalta
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Aula inválida"),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                  totalizadorAula!.qntInvalida
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Aula em conflito"),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                  totalizadorAula!.qntConflito
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: MediaQuery.of(context).size.width - 24.0,
                                height: 200.0,
                                child: loadingCard
                                    ? const Center(
                                        child: Text(''),
                                      )
                                    : const CardLoading(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            8.0,
                                          ),
                                        ),
                                        height: 100,
                                      ),
                              )
                      ],
                    ),
                  ),
                ),
                /*Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Card(
                    color: AppTema.primaryWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 1.0,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Planos',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: AppTema.primaryDarkBlue,
                                      ),
                                    ),
                                    Text(
                                      '2024',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: AppTema.primaryDarkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        List.generate(planos.length, (index) {
                                      String descricao =
                                          planos[index]['descricao'] ?? '';
                                      String value =
                                          planos[index]['value'] ?? '';

                                      return Row(
                                        children: [
                                          Text(
                                            '$descricao $value',
                                            style:
                                                const TextStyle(fontSize: 14.0),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTema.primaryAmarelo,
          elevation: 1.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ListagemGestoesProfessor(),
              ),
            );
          },
          tooltip: 'Add',
          child: const Icon(
            Icons.assignment_add,
            color: AppTema.primaryDarkBlue,
          ), // Icon for the button
        ),
        // bottomNavigationBar: BottomNavigationBar(
        //   backgroundColor: AppTema.primaryAmarelo,
        //   elevation: 0.0,
        //   useLegacyColorScheme: true,
        //   selectedItemColor: Colors.white,
        //   unselectedItemColor: AppTema.texto,
        //   currentIndex: _currentIndex,
        //   onTap: (index) {
        //     setState(() {
        //       _currentIndex = index;
        //       //print(_currentIndex.toString());
        //     });
        //   },
        //   items: [
        //     // BottomNavigationBarItem(
        //     //   icon: Icon(
        //     //     Icons.person,
        //     //     color: _currentIndex == 0 ? Colors.white : AppTema.texto,
        //     //   ),
        //     //   label: 'Usuário',
        //     // ),
        //     BottomNavigationBarItem(
        //       icon: Icon(
        //         Icons.home,
        //         color: _currentIndex == 0 ? Colors.white : AppTema.texto,
        //       ),
        //       label: 'Home',
        //     ),
        //     // BottomNavigationBarItem(
        //     //   icon: Icon(
        //     //     Icons.list_sharp,
        //     //     color: _currentIndex == 1 ? Colors.white : AppTema.texto,
        //     //   ),
        //     //   label: 'Gestões',
        //     // ),
        //   ],
        // ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
