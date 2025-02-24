import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:professor_acesso_notifiq/componentes/gestoes/dados_gestao_card_componente.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/models/justificativa_model.dart';
import 'package:professor_acesso_notifiq/models/matricula_model.dart';
import 'package:professor_acesso_notifiq/models/models_online/falta_model_online.dart';
import 'package:professor_acesso_notifiq/services/adapters/justificativas_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/matriculas_da_turma_ativa_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/http/faltas/faltas_da_aula_online_enviar_service.dart';
import 'package:professor_acesso_notifiq/services/http/faltas/faltas_da_aula_online_listar_service.dart';
import 'package:open_filex/open_filex.dart';
import '../../componentes/button/custom_anexo_download_button.dart';
import '../../componentes/dialogs/custom_justificativa_dialog.dart';
import '../../componentes/dialogs/custom_snackbar.dart';
import '../../componentes/dialogs/custom_dialogs.dart';
import '../../models/aula_model.dart';
import '../../services/connectivity/internet_connectivity_service.dart';
import '../../services/http/faltas/faltas_da_aula_online_enviar_http.dart';
import '../../services/http/relatorios/relatorio_http.dart';

class FrequenciaOnlinePage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String aula_id;
  final String? selecionandoId;
  final String? dataDaAula;
  final Aula? aula;
  // ignore: non_constant_identifier_names
  const FrequenciaOnlinePage(
      {super.key,
      required this.aula_id,
      this.selecionandoId,
      this.dataDaAula,
      this.aula});

  @override
  State<FrequenciaOnlinePage> createState() => _FrequenciaOnlinePageState();
}

class _FrequenciaOnlinePageState extends State<FrequenciaOnlinePage>
    with AutomaticKeepAliveClientMixin<FrequenciaOnlinePage> {
  FaltasDaAulaOnlineEnviarHttp apiServiceFalta = FaltasDaAulaOnlineEnviarHttp();
  // ignore: non_constant_identifier_names
  List<Matricula> matriculas_da_gestao_da_turma_ativa = [];
  List<Justificativa> justificavas = [];
  List<dynamic> justificavasDaMatricula = [];
  List<FaltaModelOnline> faltas = [];
  List<dynamic>? dataFaltas = [];
  List<dynamic>? dataFrequencias = [];

  bool frequenciesJaCriada = false;
  // ignore: non_constant_identifier_names
  late String aula_id;
  List<bool?> _isLiked = [];
  bool isBaixa = false;
  Future<void> carregarDados() async {
    matriculas_da_gestao_da_turma_ativa.clear();
    await carregarJustificativa();

    List<Matricula> response =
        await MatriculasDaTurmaAtivaServiceAdapter().listar();
    List<FaltaModelOnline> faltas = await carregarDadosCasoJaTenhaFaltaSalva();

    setState(() {
      matriculas_da_gestao_da_turma_ativa = response;
      aula_id = widget.aula_id;
      _isLiked = List.generate(response.length, (_) => true);
      justificavasDaMatricula = List.generate(response.length, (_) => null);
    });

    Map<String, FaltaModelOnline> faltasMap = {
      for (var falta in faltas) falta.matricula_id.toString(): falta
    };

    List<Map<String, dynamic>> dataFrequenciasTemp = [];

    for (var index = 0;
        index < matriculas_da_gestao_da_turma_ativa.length;
        index++) {
      var matricula = matriculas_da_gestao_da_turma_ativa[index];
      var falta = faltasMap[matricula.matricula_id.toString()];

      Map<String, dynamic> frequenciaData = {
        "id": "nova_falta",
        "aula_id": aula_id,
        "aluno_nome": matricula.aluno_nome,
        "matricula_id": matricula.matricula_id,
        "matricula_situacao": matricula.matricula_situacao,
        "codigo": matricula.codigo ?? 0,
        "justificativa_id": "null",
        "status": true,
        "existe_anexo": falta?.existe_anexo ?? false,
      };

      dataFrequenciasTemp.add(frequenciaData);

      if (falta != null) {
        addData(
          id: falta.id,
          justificativaId: falta.justificativa_id,
          justificativaDescricao: falta.justificativa_descricao!,
          matriculaId: matricula.matricula_id,
          aulaId: matricula.aluno_id,
          codigo: matricula.codigo ?? 0,
          status: falta.justificativa_id.isEmpty,
          existe_anexo: matricula.existe_anexo,
        );
        _isLiked[index] = false;

        setState(() {
          justificavas.removeWhere((justificativa) =>
              justificativa.descricao.toUpperCase() == 'OUTROS');
        });

        for (var justificativa in justificavas) {
          if (justificativa.descricao.toString() != 'OUTROS' &&
              justificativa.id.toString() ==
                  falta.justificativa_id.toString()) {
            justificavasDaMatricula[index] = int.parse(justificativa.id);
          }
        }
      }
    }

    setState(() {
      dataFrequencias = dataFrequenciasTemp;
    });

    await getDataFrequencias();
  }

  Future<List<FaltaModelOnline>> carregarDadosCasoJaTenhaFaltaSalva() async {
    List<FaltaModelOnline> response = await FaltasDaAulaOnlineListarService()
        .todasAsFaltas(context, aula_id: widget.aula_id);
    print('FaltaModelOnline: $response');
    setState(() {
      faltas = response;
      aula_id = widget.aula_id;
      _isLiked = List.generate(response.length, (_) => false);
    });

    faltas.forEach((falta) {
      if (falta.aula_id.toString() == widget.aula_id.toString()) {
        dataFaltas!.add({
          "id": falta.id,
          "justificativa_id": falta.justificativa_id.toString(),
          "matricula_id": falta.matricula_id.toString(),
          "aula_id": falta.aula_id.toString(),
          "justificativa_descricao": falta.justificativa_descricao!,
          "status": false,
          "existe_anexo": falta.existe_anexo!,
        });
        frequenciesJaCriada = true;
      }
    });
    return faltas;
  }

  Future<void> carregarJustificativa() async {
    List<Justificativa> response =
        await JustificativasServiceAdapter().listar();

    setState(() => justificavas = response);
  }

  bool verificarSwitch(Matricula matricula) {
    bool presenca = true;
    if (frequenciesJaCriada == true) {
      faltas.forEach((falta) {
        if (falta.matricula_id.toString() ==
                matricula.matricula_id.toString() &&
            falta.aula_id.toString() == aula_id.toString()) presenca = false;
      });
    }
    return presenca;
  }

  Future<void> salvarFaltas() async {
    /*print('aula_id: ${widget.aula_id}');
    print('matriculasDaTurmaAtiva: ${matriculas_da_gestao_da_turma_ativa.toString()}');
    print('faltasOnlines: $faltas');
    print('isLiked: $_isLiked');
    print('justificavasDaMatricula: $justificavasDaMatricula');*/
    await FaltasDaAulaOnlineEnviarService()
        .setExecutar(dataFrequencias: dataFrequencias, aulaId: aula_id);
    /*FaltasDaAulaOnlineEnviarService().executar(
        dataFrequencias: dataFrequencias,
        aula_id: widget.aula_id,
        matriculasDaTurmaAtiva: matriculas_da_gestao_da_turma_ativa,
        faltasOnlines: faltas,
        isLiked: _isLiked,
        justificavasDaMatricula: justificavasDaMatricula);*/
  }

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  bool get wantKeepAlive => true;

  void addData({
    required String id,
    required String justificativaId,
    required String matriculaId,
    required String aulaId,
    required bool status,
    required String? justificativaDescricao,
    required int? codigo,
    required bool? existe_anexo,
  }) {
    dataFaltas!.add({
      "id": id.isNotEmpty ? id : "nova_falta",
      "justificativa_id": justificativaId.isNotEmpty ? justificativaId : "null",
      "matricula_id": matriculaId,
      "aula_id": aulaId,
      "justificativa_descricao": justificativaDescricao,
      "codigo": codigo,
      "isBaixa": false,
      "status": status,
      "existe_anexo": existe_anexo,
    });
  }

  Future<void> getDataFrequencias() async {
    // ignore: unused_local_variable
    int countFalseStatus = 0;
    for (var item in dataFrequencias!) {
      for (var falta in dataFaltas!) {
        if (falta['matricula_id'].toString() ==
                item['matricula_id'].toString() &&
            falta['aula_id'].toString() == item['aula_id'].toString()) {
          item['id'] = falta['id'].toString();
          item['justificativa_id'] = falta['justificativa_id'].toString();
          item['matricula_id'] = falta['matricula_id'].toString();
          item['aula_id'] = falta['aula_id'].toString();
          item['justificativa_descricao'] =
              falta['justificativa_descricao'].toString();
          item['status'] = falta['status'];
          item['existe_anexo'] = falta['existe_anexo'];
        }
      }
    }
    setState(() {});
  }

  Future<void> setStatus({required int index, required bool status}) async {
    if (index <= dataFrequencias!.length) {
      var item = dataFrequencias![index];
      item['status'] = status;

      setState(() {});
    } else {
      print('Índice fora dos limites da lista');
    }
  }

  Future<void> setJustificativaById(
      {required int index, required int? justificativaId}) async {
    if (index <= dataFrequencias!.length) {
      var item = dataFrequencias![index];
      item['justificativa_id'] = item['justificativa_id'].toString();
      setState(() {});
    } else {
      print('Índice fora dos limites da lista');
    }
  }

  Future<void> aplicarFrequencia(
      bool value, dynamic matricula, int index, BuildContext context) async {
    final faltas = FaltasDaAulaOnlineEnviarHttp();
    if (value == true) {
      CustomDialogs.showLoadingDialog(context, show: true);
      await apiServiceFalta.setFrequencia(
        matriculaId: matricula['matricula_id'],
        aulaId: aula_id,
        presente: 1,
      );
      CustomSnackBar.showSuccessSnackBar(
        context,
        'Frequência registrada com sucesso!',
      );
      CustomDialogs.showLoadingDialog(context, show: false);
      _atualizarEstadoFrequencia(index, matricula, true, true);

      return;
    }
    justificavas = await ordenarJustificativas(justificavas);
    setState(() => justificavas);

    final bool? result = await faltas.setFrequencia(
      matriculaId: matricula['matricula_id'],
      aulaId: matricula['aula_id'].toString(),
      presente: 0,
    );
    print('result: $result');
    if (result == null) {
      print('Nenhuma seleção foi feita');
      return;
    }

    CustomDialogs.showLoadingDialog(context, show: true, message: 'Aguarde...');

    final bool presente = result;

    _atualizarEstadoFrequencia(index, matricula, false, false);

    CustomDialogs.showLoadingDialog(context, show: false);

    CustomSnackBar.showSuccessSnackBar(
      context,
      'Frequência registrada com sucesso!',
    );

    setState(() => dataFrequencias!.clear());
    await carregarDados();
  }

  Future<void> dialogSwitch(
      bool value, dynamic matricula, int index, BuildContext context) async {
    if (value == true) {
      CustomDialogs.showLoadingDialog(context, show: true);
      await apiServiceFalta.setFrequencia(
        matriculaId: matricula['matricula_id'],
        aulaId: aula_id,
        presente: 1,
      );
      CustomSnackBar.showSuccessSnackBar(
        context,
        'Frequência registrada com sucesso!',
      );
      CustomDialogs.showLoadingDialog(context, show: false);
      _atualizarEstadoFrequencia(index, matricula, true, true);

      return;
    }
    Justificativa? justificativaSelecionada;
    justificavas = await ordenarJustificativas(justificavas);
    setState(() => justificavas);
    if (matricula.containsKey('justificativa_id') &&
        matricula['justificativa_id'] != null &&
        matricula.containsKey('justificativa_descricao') &&
        matricula['justificativa_descricao'] != null) {
      final justificativaId = matricula['justificativa_id'].toString();
      final justificativaDescricao =
          matricula['justificativa_descricao'].toString();

      justificativaSelecionada = Justificativa(
        id: justificativaId,
        descricao: justificativaDescricao,
      );
    } else {
      justificativaSelecionada = null;
    }
    final bool? result = await JustificativaDialog.exibirDialogoJustificativa(
        context,
        justificativaSelecionada: justificativaSelecionada!.id == 'null'
            ? null
            : justificativaSelecionada,
        mensagem: 'Por favor, selecione uma das opções de frequência abaixo:',
        statusFalta: matricula['status'],
        justificativas: justificavas,
        matricula: matricula,
        selecionandoId: widget.aula!.id.toString(),
        onArquivoSelecionado: (value) => {debugPrint(value!.toString())});
    print('result: $result');
    if (result == null) {
      print('Nenhuma seleção foi feita');
      return;
    }

    CustomDialogs.showLoadingDialog(context, show: true, message: 'Aguarde...');

    final bool presente = result;

    _atualizarEstadoFrequencia(index, matricula, false, false);

    CustomDialogs.showLoadingDialog(context, show: false);

    CustomSnackBar.showSuccessSnackBar(
      context,
      'Frequência registrada com sucesso!',
    );

    setState(() => dataFrequencias!.clear());
    await carregarDados();
  }

  void _atualizarEstadoFrequencia(
      int index, dynamic matricula, bool status, bool presente) {
    setState(() {
      justificavasDaMatricula[index] = null;
      setJustificativaById(index: index, justificativaId: null);
      setStatus(index: index, status: presente);
      matricula['status'] = presente;
    });
  }

  Future<List<Justificativa>> ordenarJustificativas(
      List<Justificativa> justificativas) async {
    justificativas.sort((a, b) =>
        a.descricao.toUpperCase().compareTo(b.descricao.toUpperCase()));

    return justificativas;
  }

  Future<void> baixaAnexo({
    required String aulaId,
    required String matriculaId,
    required int index,
    required BuildContext context,
  }) async {
    setState(() => dataFrequencias![index]['isBaixa'] = true);
    bool isConnectedNotifier = await InternetConnectivityService.isConnected();

    if (!isConnectedNotifier) {
      CustomSnackBar.showErrorSnackBar(
        context,
        'Você está offline no momento. Verifique sua conexão com a internet.',
      );
      setState(() => dataFrequencias![index]['isBaixa'] = false);
      return;
    }
    final relatoriosHttp = RelatoriosHttp();
    final response = await relatoriosHttp.baixaAnexoFalta(
      aulaId: aulaId,
      matriculaId: matriculaId,
    );

    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final tempFilePath = '${directory.path}/anexo_$aulaId$matriculaId.pdf';

      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(response.bodyBytes);

      await OpenFilex.open(tempFilePath);
      setState(() => dataFrequencias![index]['isBaixa'] = false);
      return;
    }

    CustomSnackBar.showErrorSnackBar(
      context,
      'Nenhum anexo disponível no momento. Tente novamente mais tarde.',
    );
    setState(() => dataFrequencias![index]['isBaixa'] = false);
    //throw Exception('Falha ao baixar o anexo: ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        title: const Text(
          'Frequência Online',
          style: TextStyle(color: AppTema.primaryDarkBlue),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 5, bottom: 10),
              child: DadosDaGestaoCardComponente(
                selecionandoId: widget.selecionandoId,
                dataDaAula: widget.dataDaAula,
                aula: widget.aula,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: Card(
                  color: AppTema.primaryWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: ListView.builder(
                    itemCount: dataFrequencias!.length,
                    itemBuilder: (context, index) {
                      final matricula = dataFrequencias![index];
                      // print('--------------------------------');
                      // print(matricula.toString());
                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: matricula['matricula_situacao'] != 'TRANSFERIDO'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.only(left: 5, top: 15),
                                    child: matricula['aluno_nome'].length > 35
                                        ? Tooltip(
                                            message: '${matricula.aluno_nome}',
                                            child: Text(
                                              '${matricula.aluno_nome.substring(0, 35).toUpperCase()}...',
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                color: AppTema.primaryDarkBlue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            matricula['aluno_nome']
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              color: AppTema.primaryDarkBlue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  matricula['status'] == false &&
                                          matricula['justificativa_descricao']
                                                  .toString() !=
                                              ''
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Row(
                                            children: [
                                              const Text(
                                                'Justificativa:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppTema.primaryDarkBlue,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                matricula[
                                                        'justificativa_descricao']
                                                    .toString(),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 10),
                                      Row(
                                        children: [
                                          Icon(
                                            matricula['status']!
                                                ? Icons.thumb_up
                                                : Icons.thumb_up,
                                            color: matricula['status']
                                                ? AppTema.success
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 0),
                                          Switch(
                                            value: matricula['status'],
                                            onChanged: (value) async =>
                                                await aplicarFrequencia(value,
                                                    matricula, index, context),
                                            activeColor: AppTema.success,
                                            inactiveThumbColor: Colors.grey,
                                            inactiveTrackColor:
                                                Colors.grey.withOpacity(0.5),
                                          ),
                                          const SizedBox(width: 0),
                                          Icon(
                                            matricula['status']!
                                                ? Icons.thumb_down
                                                : Icons.thumb_down,
                                            color: matricula['status']
                                                ? Colors.grey
                                                : Colors.red,
                                          ),
                                          const SizedBox(width: 10),
                                          matricula['status'] == false
                                              ? SizedBox(
                                                  width: 160.0,
                                                  height: 30.0,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: AppTema
                                                          .primaryAmarelo,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      await dialogSwitch(
                                                        matricula['status'],
                                                        matricula,
                                                        index,
                                                        context,
                                                      );
                                                    },
                                                    child: const Text(
                                                      'Observação',
                                                      style: TextStyle(
                                                        color: AppTema
                                                            .primaryWhite,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                          const SizedBox(width: 10),
                                          matricula['status'] == false &&
                                                  matricula['existe_anexo'] ==
                                                      true
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CustomAnexoDownloadButton(
                                                      label: 'Baixar Anexo',
                                                      onPressed: () async =>
                                                          await baixaAnexo(
                                                        aulaId:
                                                            matricula['aula_id']
                                                                .toString(),
                                                        matriculaId: matricula[
                                                                'matricula_id']
                                                            .toString(),
                                                        context: context,
                                                        index: index,
                                                      ),
                                                      backgroundColor:
                                                          AppTema.error,
                                                      textColor: Colors.white,
                                                      borderRadius: 8.0,
                                                      padding: 0.0,
                                                      loading: matricula[
                                                                  'isBaixa'] ==
                                                              true
                                                          ? true
                                                          : false,
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox()
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                        left: 5,
                                        top: 15,
                                      ),
                                      child: matricula['aluno_nome'] != null
                                          ? matricula['aluno_nome'].length > 35
                                              ? Tooltip(
                                                  message:
                                                      matricula['aluno_nome'],
                                                  child: Text(
                                                    '${matricula['aluno_nome'].substring(0, 35).toUpperCase()}...',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  matricula['aluno_nome']
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                          : const SizedBox(),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTema.error,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      margin: const EdgeInsets.only(
                                        left: 5,
                                        top: 5,
                                      ),
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        top: 5,
                                        right: 10,
                                        bottom: 5,
                                      ),
                                      child: Text(
                                        'TRANSFERIDO'.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
            /*ElevatedButton(
              onPressed: () async {
                await salvarFaltas();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor:
                        Colors.green, // Define a cor de fundo como verde
                    content: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors
                              .white, // Define a cor do ícone como branco
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Frequência atualizada com sucesso',
                          style: TextStyle(
                            color: Colors
                                .white, // Define a cor do texto como branco
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTema.primaryAzul,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Enviar',
                style: TextStyle(color: Colors.white),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
