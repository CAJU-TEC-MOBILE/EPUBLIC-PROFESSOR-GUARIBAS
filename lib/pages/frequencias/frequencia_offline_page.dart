import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:professor_acesso_notifiq/componentes/dialogs/custom_justificativa_offline_dialog.dart';
import 'package:professor_acesso_notifiq/componentes/gestoes/dados_gestao_card_componente.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/models/faltas_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/models/justificativa_model.dart';
import 'package:professor_acesso_notifiq/models/matricula_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/faltas_offlines_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/justificativas_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/matriculas_da_turma_ativa_service_adapter.dart';
import '../../componentes/button/custom_anexo_download_button.dart';
import '../../componentes/dialogs/custom_dialogs.dart';
import '../../componentes/dialogs/custom_snackbar.dart';
import '../../componentes/dialogs/custom_padrao_dialog.dart';
import '../../componentes/global/preloader.dart';
import '../../models/aula_model.dart';
import '../../models/historico_requencia_model.dart';
import '../../repository/matricula_repository.dart';
import '../../services/controller/aula_controller.dart';
import '../../services/controller/historico_requencia_controller.dart';
import '../../services/faltas/falta_controller.dart';
import 'package:open_filex/open_filex.dart';

class FrequenciaOfflinePage extends StatefulWidget {
  final String aula_id;
  final Aula? aula;
  const FrequenciaOfflinePage({super.key, required this.aula_id, this.aula});
  @override
  State<FrequenciaOfflinePage> createState() => _FrequenciaOfflinePageState();
}

class _FrequenciaOfflinePageState extends State<FrequenciaOfflinePage>
    with AutomaticKeepAliveClientMixin<FrequenciaOfflinePage> {
  final GestaoAtiva? gestaoAtivaModel =
      GestaoAtivaServiceAdapter().exibirGestaoAtiva();
  HistoricoPresenca? historicoPresenca;
  List<Matricula> matriculas_da_gestao_da_turma_ativa = [];
  List<Justificativa> justificativas = [];
  Aula? aula;
  List<dynamic> justificavasDaMatricula = [];
  List<Falta> faltas = [];
  bool frequenciaJaCriada = false;
  late String aula_id = '';
  List<bool?> _isLiked = [];
  final faltaController = FaltaController();
  final aulaController = AulaController();
  final historicoPresencaController = HistoricoPresencaController();
  final repository = MatriculaRepository();
  Future<void> _aula() async {
    await aulaController.init();
    aula = await aulaController.aula(
      criadaPeloCelular: widget.aula_id.toString(),
    );
    setState(() => aula);
  }

  Future<void> carregarDados() async {
    await _aula();
    await carregarJustificativas();
    List<Matricula> response =
        await MatriculasDaTurmaAtivaServiceAdapter().listar();
    await carregarDadosCasoJaTenhaFaltaSalva();
    setState(() {
      matriculas_da_gestao_da_turma_ativa = response;
      aula_id = widget.aula_id;
      _isLiked = List.generate(response.length, (_) => true);
      justificavasDaMatricula = List.generate(response.length, (_) => null);
    });
    if (frequenciaJaCriada == true) {
      matriculas_da_gestao_da_turma_ativa.asMap().forEach((index, matricula) {
        for (var falta in faltas) {
          if (falta.matricula_id.toString() ==
                  matricula.matricula_id.toString() &&
              falta.aula_id.toString() == aula_id.toString()) {
            _isLiked[index] = false;
            for (var justificativa in justificativas) {
              if (justificativa.id.toString() ==
                  falta.justificativa_id.toString()) {
                justificavasDaMatricula[index] = int.parse(justificativa.id);
              }
            }
          }
        }
      });
    }
    await getAjusteMatricula();
  }

  Future<void> getAjusteMatricula() async {
    try {
      await historicoPresencaController.init();
      if (matriculas_da_gestao_da_turma_ativa.isEmpty) {
        return;
      }
      for (var matricula in matriculas_da_gestao_da_turma_ativa) {
        String? caminho =
            await historicoPresencaController.getAnexoeAulaPorAula(
          widget.aula!.criadaPeloCelular.toString(),
          matricula.aluno_id.toString(),
        );
        matricula.existe_anexo = caminho != null && caminho.isNotEmpty;
      }
      setState(() {});
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> deleteAnexo(String? criadaPeloCelular, String? alunoId) async {
    try {
      await historicoPresencaController.init();
      await historicoPresencaController.deletarAnexoPorAula(
        criadaPeloCelular,
        alunoId,
      );
      await getAjusteMatricula();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<List<Falta>> carregarDadosCasoJaTenhaFaltaSalva() async {
    List<Falta> response = await FaltasOfflinesServiceAdapter().listar();
    setState(() {
      faltas = response;
      aula_id = widget.aula_id;
      _isLiked = List.generate(response.length, (_) => false);
    });
    for (var falta in faltas) {
      if (falta.aula_id.toString() == widget.aula_id.toString()) {
        frequenciaJaCriada = true;
      }
    }
    return faltas;
  }

  Future<void> carregarJustificativas() async {
    List<Justificativa> response =
        await JustificativasServiceAdapter().listar();
    setState(() {
      justificativas = response;
    });
  }

  bool verificarSwitch(Matricula matricula) {
    bool presenca = true;
    if (frequenciaJaCriada == true) {
      for (var falta in faltas) {
        if (falta.matricula_id.toString() ==
                matricula.matricula_id.toString() &&
            falta.aula_id.toString() == aula_id.toString()) presenca = false;
      }
    }
    return presenca;
  }

  Future<void> salvarFaltas(BuildContext context) async {
    print("============================================");
    try {
      await aulaController.init();
      bool status = await aulaController.registrarFrequencia(
        criadaPeloCelular: widget.aula_id.toString(),
      );
      if (!status) {
        CustomSnackBar.showSuccessSnackBarFalta(
          context,
          'O código relacionado à frequência não foi encontrado.',
        );
        return;
      }
      await FaltasOfflinesServiceAdapter().salvar(
        criadaPeloCelular: widget.aula_id,
        matriculasDaTurmaAtiva: matriculas_da_gestao_da_turma_ativa,
        isLiked: _isLiked,
        justificavasDaMatricula: justificavasDaMatricula,
      );
      CustomSnackBar.showSuccessSnackBarFalta(
        context,
        'Frequência salva com sucesso!',
      );
      Navigator.pop(context);
    } catch (e) {
      CustomSnackBar.showErrorSnackBar(context, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    carregarDados();
    faltaController.getFaltaPorAulaId(aula_id: widget.aula_id.toString());
  }

  Future<List<Justificativa>> ordenarJustificativas(
      List<Justificativa> justificativas) async {
    justificativas.sort((a, b) =>
        a.descricao.toUpperCase().compareTo(b.descricao.toUpperCase()));
    return justificativas;
  }

  Future<void> dialogSwitch(
    bool value,
    Matricula matricula,
    int index,
    BuildContext context,
  ) async {
    try {
      CustomDialogs.showLoadingDialog(context, show: true);
      if (value == true) {
        CustomDialogs.showLoadingDialog(context, show: false);
        return;
      }
      justificativas = await ordenarJustificativas(justificativas);
      setState(() => justificativas);
      final bool? result =
          await JustificativaOfflineDialog.exibirDialogoJustificativa(
        context,
        mensagem: 'Por favor, selecione uma das opções de frequência abaixo:',
        statusFalta: _isLiked[index]!,
        justificativas: justificativas,
        matricula: matricula,
        justificativaSelecionada:
            matricula.justificativa_id != -1 && matricula.justificativa_id != 0
                ? Justificativa(
                    id: matricula.justificativa_id.toString(),
                    descricao: matricula.justificativa.toString(),
                  )
                : null,
        criadaPeloCelular: widget.aula!.criadaPeloCelular.toString(),
        onFileSelecionado: (value) => {},
        selecionandoId: widget.aula!.id.toString(),
        onSustificativaSelecionado: (value) {
          _atualizarEstadoFrequencia(
            index,
            matricula,
            value!.descricao.toString(),
            int.tryParse(value.id.toString()),
            true,
          );
        },
        onArquivoSelecionado: (value) {
          historicoPresenca = HistoricoPresenca(
            id: matricula.matricula_id.toString(),
            justificativaId: matricula.justificativa_id.toString(),
            alunoId: matricula.aluno_id.toString(),
            anexo: value,
            criadaPeloCelular: widget.aula!.criadaPeloCelular.toString(),
            aulaId: widget.aula!.id.toString(),
            disciplinaId: '',
            franquiaId: '',
            gestaoId: '',
            professorId: widget.aula!.instrutorDisciplinaTurma_id,
            turmaId: widget.aula!.turma_id.toString(),
            presenca: false,
          );
          setState(() => historicoPresenca);
        },
      );
      if (result == null) {
        CustomDialogs.showLoadingDialog(context, show: false);
        return;
      }
      setState(
        () => historicoPresenca!.justificativaId =
            matricula.justificativa_id.toString(),
      );
      await Future.delayed(const Duration(seconds: 1));
      await salvaDadosFrequenciaLocal();
      await getAjusteMatricula();
      CustomDialogs.showLoadingDialog(context, show: false);
    } catch (e) {
      CustomDialogs.showLoadingDialog(context, show: false);
    }
  }

  void _atualizarEstadoFrequencia(int index, Matricula matricula,
      String? justificativa, int? justificativa_id, bool presente) {
    matricula.justificativa = justificativa;
    matricula.justificativa_id = justificativa_id;
    matriculas_da_gestao_da_turma_ativa[index] = matricula;
    setState(() {
      matriculas_da_gestao_da_turma_ativa;
      _isLiked[index] = false;
    });
  }

  Future<void> salvaDadosFrequenciaLocal() async {
    try {
      await historicoPresencaController.init();
      await historicoPresencaController.getDebugPrint();
      await historicoPresencaController.existeFileAulaPorAula(
        historicoPresenca!.criadaPeloCelular.toString(),
        historicoPresenca!.alunoId.toString(),
      );
      if (historicoPresenca == null) {
        return;
      }
      await historicoPresencaController.create(historicoPresenca!);
      CustomSnackBar.showSuccessSnackBarFalta(
        context,
        'Anexo salvo com sucesso!',
      );
    } catch (e) {
      CustomSnackBar.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> baixaAnexo({
    required String? alunoId,
    required BuildContext context,
  }) async {
    try {
      showLoading(context);
      await aulaController.init();
      await historicoPresencaController.init();
      await aulaController.registrarFrequencia(
        criadaPeloCelular: widget.aula_id.toString(),
      );
      String? caminho = await historicoPresencaController.getAnexoeAulaPorAula(
        widget.aula!.criadaPeloCelular.toString(),
        alunoId,
      );
      if (caminho == null) {
        CustomSnackBar.showErrorSnackBar(
          context,
          'Nenhum anexo disponível no momento. Tente novamente mais tarde.',
        );
        hideLoading(context);
        return;
      }
      // await OpenFilex.open(tempFilePath);
      // final params = ShareParams(
      //   text: 'Great picture',
      //   files: [XFile(caminho)],
      // );
      // final result = await SharePlus.instance.share(params);
      // if (result.status == ShareResultStatus.success) {
      //   hideLoading(context);
      //   return;
      // }
      await OpenFilex.open(caminho);
      hideLoading(context);
    } catch (error) {
      hideLoading(context);
      CustomSnackBar.showErrorSnackBar(
        context,
        error.toString(),
      );
    }
  }

  Future<void> verificarPermissaoEBaixar({
    required String alunoId,
    required BuildContext context,
    required Function(String, BuildContext) baixaAnexo,
  }) async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      await baixaAnexo(alunoId, context);
    } else {
      status = await Permission.storage.request();
      if (status.isGranted) {
        await baixaAnexo(alunoId, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permissão negada para acessar o armazenamento.'),
            action: SnackBarAction(
              label: 'Configurações',
              onPressed: () async {
                await openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTema.backgroundColorApp,
        appBar: AppBar(
          title: const Text(
            'Frequência',
            style: TextStyle(color: AppTema.primaryDarkBlue),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
          leading: IconButton(
            onPressed: () async {
              await _aula();
              if (aula!.status_frequencia == true) {
                if (aula!.e_aula_infantil == 1) {
                  Navigator.pushNamed(context, '/index-infantil');
                  return;
                }
                Navigator.pushNamed(context, '/index-fundamental');
                return;
              }
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomPadraoDialog(
                    title: 'Aviso',
                    message:
                        "Você tem certeza que deseja sair sem salvar as frequência?",
                    onCancel: () => Navigator.of(context).pop(false),
                    onConfirm: () async {
                      await repository.removeArquivoDaFrequencia(
                        criadaPeloCelular: widget.aula_id,
                      );
                      Navigator.of(context).pop(true);
                      if (aula!.e_aula_infantil == 1) {
                        Navigator.pushNamed(context, '/index-infantil');
                        return;
                      }
                      Navigator.pushNamed(context, '/index-fundamental');
                      return;
                    },
                  );
                },
              );
            },
            icon: Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 5, bottom: 10),
                child: DadosDaGestaoCardComponente(
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
                      addAutomaticKeepAlives: true,
                      scrollDirection: Axis.vertical,
                      itemCount: matriculas_da_gestao_da_turma_ativa.length,
                      itemBuilder: (context, index) {
                        Matricula matricula =
                            matriculas_da_gestao_da_turma_ativa[index];
                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: matricula.matricula_situacao == 'CURSANDO' ||
                                  matricula.matricula_situacao == "RECEBIDA" ||
                                  matricula.matricula_situacao == "APROVADO" ||
                                  matricula.matricula_situacao == "REPROVADO"
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        top: 15,
                                      ),
                                      child: matricula.aluno_nome.length > 35
                                          ? Tooltip(
                                              message: matricula.aluno_nome,
                                              child: Text(
                                                '${matricula.aluno_nome.substring(0, 35).toUpperCase()}...',
                                                style: const TextStyle(
                                                  fontSize: 18.0,
                                                  color:
                                                      AppTema.primaryDarkBlue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              matricula.aluno_nome
                                                  .toString()
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                color: AppTema.primaryDarkBlue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                    _isLiked[index] == false &&
                                            matricula.justificativa
                                                    .toString() !=
                                                ''
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
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
                                                  matricula.justificativa
                                                      .toString(),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 10),
                                        Row(
                                          children: [
                                            Icon(
                                              _isLiked[index]!
                                                  ? Icons.thumb_up
                                                  : Icons.thumb_up_outlined,
                                              color: _isLiked[index]!
                                                  ? AppTema.success
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 0),
                                            Switch(
                                              value: _isLiked[index]!,
                                              onChanged: (value) async {
                                                if (value != false) {
                                                  await deleteAnexo(
                                                      widget.aula!
                                                          .criadaPeloCelular
                                                          .toString(),
                                                      matricula.aluno_id
                                                          .toString());
                                                }
                                                setState(() {
                                                  _isLiked[index] = value;
                                                  matricula.justificativa = '';
                                                  matricula.justificativa_id =
                                                      -1;
                                                });
                                              },
                                              activeColor: const Color.fromARGB(
                                                  255, 52, 118, 54),
                                              inactiveThumbColor: Colors.grey,
                                              inactiveTrackColor:
                                                  Colors.grey.withOpacity(0.5),
                                            ),
                                            const SizedBox(width: 0),
                                            Icon(
                                              _isLiked[index]!
                                                  ? Icons.thumb_down_outlined
                                                  : Icons.thumb_down,
                                              color: _isLiked[index]!
                                                  ? Colors.grey
                                                  : Colors.red,
                                            ),
                                            const SizedBox(width: 10),
                                            _isLiked[index] == false
                                                ? SizedBox(
                                                    width: 160.0,
                                                    height: 34.0,
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
                                                          _isLiked[index]!,
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
                                            !_isLiked[index]! &&
                                                    matricula.existe_anexo ==
                                                        true
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 8.0,
                                                    ),
                                                    child:
                                                        CustomAnexoDownloadButton(
                                                      label: 'Baixar Anexo',
                                                      onPressed: () async {
                                                        await baixaAnexo(
                                                          alunoId: matricula
                                                              .aluno_id,
                                                          context: context,
                                                        );
                                                      },
                                                      backgroundColor:
                                                          AppTema.error,
                                                      textColor: Colors.white,
                                                      borderRadius: 8.0,
                                                      padding: 0.0,
                                                      loading:
                                                          _isLiked[index] ==
                                                                  true
                                                              ? true
                                                              : false,
                                                    ),
                                                  )
                                                : const SizedBox(),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 15),
                                        child: matricula.aluno_nome.length > 35
                                            ? Tooltip(
                                                message: matricula.aluno_nome,
                                                child: Text(
                                                  '${matricula.aluno_nome.substring(0, 35).toUpperCase()}...',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                matricula.aluno_nome
                                                    .toString()
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppTema.error,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        margin: const EdgeInsets.only(
                                            left: 5, top: 5),
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            top: 5,
                                            right: 10,
                                            bottom: 5),
                                        child: Text(
                                          matricula.matricula_situacao
                                              .toUpperCase(),
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
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async => await salvarFaltas(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTema.primaryDarkBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
