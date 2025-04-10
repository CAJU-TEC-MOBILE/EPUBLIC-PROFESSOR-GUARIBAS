import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:professor_acesso_notifiq/componentes/autorizacoes/aviso_de_regra_autorizacoes_componente.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/constants/autorizacoes/autorizacoes_status_const.dart';
import 'package:professor_acesso_notifiq/constants/emojis.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/corrigir_data_completa_americana_para_ano_mes_dia_somente.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/data/converter_data_americana_para_brasileira.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/data/verificar_se_data_atual_e_maior.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/data/verificar_se_data_atual_esta_entre_duas_datas.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/gerar_uuid_identificador.dart';
import 'package:professor_acesso_notifiq/functions/boxs/gestoes/filtrar_etapas_por_gestao_ativa.dart';
import 'package:professor_acesso_notifiq/functions/boxs/horarios/remover_horarios_repetidos.dart';
import 'package:professor_acesso_notifiq/models/aula_model.dart';
import 'package:professor_acesso_notifiq/models/autorizacao_model.dart';
import 'package:professor_acesso_notifiq/models/disciplina_model.dart';
import 'package:professor_acesso_notifiq/models/etapa_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/models/relacao_dia_horario_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/aulas_offline_online_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/autorizacoes_service.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/regras_logicas/autorizacoes/listar_unica_autorizacao_por_etapa_e_gestao_e_ultimoItem_regra_logica.dart';
import 'package:professor_acesso_notifiq/services/http/autorizacoes/autorizacoes_listar_http.dart';
import 'dart:ui' as ui;
import '../../componentes/aulas/custom_disciplina_field.dart';
import '../../componentes/button/custom_calendario_button.dart';
import '../../componentes/dialogs/custom_snackbar.dart';
import '../../help/data_time.dart';
import '../../models/auth_model.dart';
import '../../services/adapters/auth_service_adapter.dart';
import '../../services/controller/disciplina_controller.dart';
import '../../services/controller/pedido_controller.dart';

class CriarAulaPage extends StatefulWidget {
  final String? instrutorDisciplinaTurmaId;
  const CriarAulaPage({super.key, this.instrutorDisciplinaTurmaId});

  @override
  State<CriarAulaPage> createState() => _CriarAulaPageState();
}

class _CriarAulaPageState extends State<CriarAulaPage> {
  final TextEditingController _conteudoController = TextEditingController();
  final TextEditingController _metodologiaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final pedidoController = PedidoController();
  Auth authModel = AuthServiceAdapter().exibirAuth();

  var _disciplinas_selecionada;
  String? _errorText;
  String? _aula_selecionada;
  var _horario_selecionado;
  var _etapa_selecionada;
  Etapa? etapa_selecionada_objeto;
  bool data_etapa_valida = true;
  DateTime? _dataSelecionada;
  String? _diaDaSemana;

  var texto1_etapa;
  var texto2_etapa;
  String cursoDescricao = '';
  Box _horariosBox = Hive.box('horarios');
  List<dynamic>? horarios_data;
  List<dynamic>? listaFiltradaDeHorarios;
  List<RelacaoDiaHorario>? listaFiltradaDeHorariosPorHorariosDaColunaDaGestao;
  List<int> diasParaSeremExibidosNoCalendario = [];
  List<Etapa>? listaDeEtapas;
  Etapa? etapaSelecionada;
  GestaoAtiva? gestaoAtivaModel;
  List<Autorizacao> autorizacoesDoUsuario =
      AutorizacoesServiceAdapter().listar();
  Autorizacao? autorizacaoSelecionada;
  String statusDaAutorizacao = 'INICIO';

  String? instrutorDisciplinaTurmaId;
  List<String> selectedExperiencias = [];
  List<Disciplina> disciplinas = [];
  List<Disciplina> selectedDisciplinas = [];
  List<dynamic> selectorData = [];
  List<int> _horariosSelecionados = [];
  List<dynamic> horarioDaDisciplinas = [];
  String inicioPeriodoEtapa = '';
  String fimPeriodoEtapa = '';
  List<String>? semanas;
  String situacaoStatus = '';
  String circuitoId = '';
  bool statusPeriudo = false;

  Future<void> _situacao() async {
    await pedidoController.init();
    String status =
        await pedidoController.getTipoStatusPeloInstrutorDisciplinaTurmaID(
      instrutorDisciplinaTurmaID:
          gestaoAtivaModel!.instrutorDisciplinaTurma_id.toString(),
      etapaId: _etapa_selecionada.toString(),
      userId: authModel.id,
      circuitoId: circuitoId,
    );
    // debugPrint("status: $status");
    setState(() => situacaoStatus = status);
  }

  void _handleSelectionChanged(List<String> selecionadas) {
    setState(() {
      selectedExperiencias = selecionadas;
    });
  }

  void _validadePeriodoEtapa() {
    try {
      if (etapa_selecionada_objeto == null) {
        //debugPrint("Sem etapa selecionada.");
        return;
      }
      String dataAtualStr = DataTime.getDataAtualFormatoISO();
      String dataInicialStr = etapa_selecionada_objeto!.periodo_inicial;
      String dataFinalStr = etapa_selecionada_objeto!.periodo_final;

      DateTime dataAtual = DateTime.parse(dataAtualStr);
      DateTime dataInicial = DateTime.parse(dataInicialStr);
      DateTime dataFinal = DateTime.parse(dataFinalStr);

      if (dataAtual.isAfter(dataInicial.subtract(const Duration(days: 1))) &&
          dataAtual.isBefore(dataFinal.add(const Duration(days: 1)))) {
        setState(() => statusPeriudo = true);
        // debugPrint("A data atual está dentro do período. $statusPeriudo");
        return;
      }
      // debugPrint("A data atual está FORA do período. $statusPeriudo");
      setState(() => statusPeriudo = false);
    } catch (e) {
      setState(() => statusPeriudo = false);
      debugPrint(
          'error-validade-periodo-etapa: $e\n status-periudo: $statusPeriudo');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && widget.instrutorDisciplinaTurmaId == null) {
      instrutorDisciplinaTurmaId =
          args['instrutorDisciplinaTurmaId']!.toString();
    } else {
      instrutorDisciplinaTurmaId = widget.instrutorDisciplinaTurmaId;
    }
  }

  @override
  void initState() {
    super.initState();
    _situacao();
    //atualizarAutorizacoes();
    getDisciplinas();
    horarios_data = _horariosBox.get('horarios');
    gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
    gestaoAtivaModel?.circuito.etapas;
    listaDeEtapas = filtrarEtapasPorGestaoAtiva();
    // listaFiltradaDeHorarios = filtrarListaDeObjetoPorCondicaoUnica(
    //     lista_de_objetos: horarios_data!, condicao: gestaoAtivaModel?.turno_id);
    listaFiltradaDeHorariosPorHorariosDaColunaDaGestao =
        gestaoAtivaModel?.relacoesDiasHorarios;
    listaFiltradaDeHorariosPorHorariosDaColunaDaGestao
        ?.sort((a, b) => a.horario.descricao.compareTo(b.horario.descricao));
    _mostrarCalendario(context);
    _dataSelecionada =
        _ajustarDataParaDiasMaisProximoDoCampoRelacoesDiasHorarios(
            DateTime.now());
  }

  Future<void> atualizarAutorizacoes() async {
    AutorizacoesListarHttp apiService = AutorizacoesListarHttp();
    http.Response response = await apiService.executar();
    Map<dynamic, dynamic> responseDecode = await jsonDecode(response.body);
    await AutorizacoesServiceAdapter()
        .salvar(responseDecode['autorizacoes_atualizadas']);
    setState(() {
      print('setState de autorizacoesDoUsuario');
      autorizacoesDoUsuario = AutorizacoesServiceAdapter().listar();
    });
  }

  verificarSeExistemAutorizacoesParaEssaEtapaEgestao() {
    statusDaAutorizacao = 'INICIO';
    autorizacaoSelecionada =
        ListarUnicaAutorizacaoPorEtapaEGestaoEultimoItemRegraLogica().executar(
            autorizacoes: autorizacoesDoUsuario,
            etapaID: _etapa_selecionada.toString());
    if (autorizacaoSelecionada!.id.toString() == '') {
      statusDaAutorizacao = 'SEM RETORNO';
      return;
    }

    if (autorizacaoSelecionada!.status.toString() ==
        AutorizacoesStatusConst.pendente) {
      statusDaAutorizacao = 'PENDENTE';
      return;
    }
    if (autorizacaoSelecionada!.status.toString() ==
            AutorizacoesStatusConst.aprovado &&
        !verificarSeDataAtualEmaior(
            data: autorizacaoSelecionada!.dataExpiracao.toString())) {
      statusDaAutorizacao = 'APROVADO';
      return;
    }

    if (autorizacaoSelecionada!.status.toString() ==
        AutorizacoesStatusConst.cancelado) {
      statusDaAutorizacao = 'CANCELADO';
      return;
    }
  }

  Future<void> _salvarAula() async {
     
    print("TOTAL: ${selectedDisciplinas.length.toString()}");
    if (selectedDisciplinas.isEmpty && gestaoAtivaModel!.is_polivalencia == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTema.primaryAmarelo,
          content: Row(
            children: [
              Text(
                'Adicione ao menos um campo de conteúdo!',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }
    //print('gestaoAtivaModel?.idt_id.toString(): ${gestaoAtivaModel?.idt_id.toString()}');
    var aula = Aula(
      id: '',
      e_aula_infantil: 0,
      instrutor_id: gestaoAtivaModel?.idt_instrutor_id.toString(),
      disciplina_id: gestaoAtivaModel?.idt_disciplina_id.toString(),
      turma_id: gestaoAtivaModel?.idt_turma_id.toString(),
      tipoDeAula: _aula_selecionada.toString(),
      dataDaAula: corrigirDataCompletaAmericanaParaAnoMesDiaSomente(
          dataString: _dataSelecionada.toString()),
      horarioID: _horario_selecionado.toString(),
      horarios_infantis:
          _horario_selecionado != null ? [_horario_selecionado] : [],
      conteudo: _conteudoController.text.toString(),
      metodologia: _metodologiaController.text.toString(),
      saberes_conhecimentos: '',
      dia_da_semana: _diaDaSemana.toString(),
      situacao: 'Aguardando confirmação',
      criadaPeloCelular: gerarUuidIdentification().toString(),
      etapa_id: _etapa_selecionada.toString(),
      instrutorDisciplinaTurma_id: gestaoAtivaModel?.idt_id.toString(),
      campos_de_experiencias: selectedExperiencias.toString(),
      is_polivalencia: gestaoAtivaModel!.is_polivalencia ?? 0,
      //instrutorDisciplinaTurma_id: instrutorDisciplinaTurmaId.toString(),
      eixos: '',
      estrategias: '',
      recursos: '',
      atividade_casa: '',
      atividade_classe: '',
      experiencias: selectedExperiencias.length > 0 ? selectedExperiencias : [],
      observacoes: '',
    );
    bool status = await AulasOfflineOnlineServiceAdapter().salvar(
        novaAula: aula,
        isPolivalencia: gestaoAtivaModel!.is_polivalencia,
        disciplina: selectedDisciplinas);

    if (status != true) {
      CustomSnackBar.showErrorSnackBar(
        context,
        'Já existe uma aula criada para este dia. Por favor, escolha uma data diferente.',
      );
      return;
    }
    CustomSnackBar.showSuccessSnackBar(
      context,
      'Aula criada com sucesso!',
    );
    Navigator.pushNamed(context, '/index-fundamental');
  }

  // DateTime _ajustarDataParaDiasMaisProximoDoCampoRelacoesDiasHorarios(
  //     DateTime data) {
  //   print(int.parse(data.weekday.toString()) - 1);
  //   print('135115531');
  //   print(DateTime.now());
  //   // while (data.weekday != 3) {
  //   //   data = data.add(Duration(days: 1));
  //   // }
  //   return data.add(Duration(days: 2));
  // }

  DateTime _ajustarDataParaDiasMaisProximoDoCampoRelacoesDiasHorarios(
      DateTime data) {
    if (diasParaSeremExibidosNoCalendario.isNotEmpty) {
      while (data.weekday != diasParaSeremExibidosNoCalendario[0]) {
        data = data.add(Duration(days: 1));
      }
    }
    return data;
  }

  Future<void> _mostrarCalendario(BuildContext context) async {
    listaFiltradaDeHorariosPorHorariosDaColunaDaGestao!.forEach((element) {
      if (int.parse(element.dia.id) == 0) {
        // diasParaSeremExibidosNoCalendario?.add('monday');
        diasParaSeremExibidosNoCalendario.add(1);
      }
      if (int.parse(element.dia.id) == 1) {
        // diasParaSeremExibidosNoCalendario.add('tuesday');
        diasParaSeremExibidosNoCalendario.add(2);
      }
      if (int.parse(element.dia.id) == 2) {
        // diasParaSeremExibidosNoCalendario.add('wednesday');
        diasParaSeremExibidosNoCalendario.add(3);
      }
      if (int.parse(element.dia.id) == 3) {
        // diasParaSeremExibidosNoCalendario.add('thursday');
        diasParaSeremExibidosNoCalendario.add(4);
      }
      if (int.parse(element.dia.id) == 4) {
        // diasParaSeremExibidosNoCalendario.add('friday');
        diasParaSeremExibidosNoCalendario.add(5);
      }
      if (int.parse(element.dia.id) == 5) {
        // diasParaSeremExibidosNoCalendario.add('saturday');
        diasParaSeremExibidosNoCalendario.add(6);
      }
      if (int.parse(element.dia.id) == 6) {
        // diasParaSeremExibidosNoCalendario.add('sunday');
        diasParaSeremExibidosNoCalendario.add(7);
      }
    });
    if (_dataSelecionada != null) {
      final DateTime? dataSelecionada = await showDatePicker(
        context: context,
        initialDate: _dataSelecionada!,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        selectableDayPredicate: (DateTime day) {
          bool diaDaSemanaParaSerExibido = false;
          diasParaSeremExibidosNoCalendario
              .forEach((numeroDoDIaDaSemanaComecandoPorUm) {
            if (numeroDoDIaDaSemanaComecandoPorUm == day.weekday) {
              diaDaSemanaParaSerExibido = true;
            }
          });
          return diaDaSemanaParaSerExibido;
          // return day.weekday == DateTime.tuesday || day.weekday == DateTime.thursday;
        },
      );
      if (dataSelecionada != null) {
        setState(() {
          _dataSelecionada = dataSelecionada;
        });
      }
    }
  }

  void _validateDropdown(String? value) {
    if (value == null || value.isEmpty || value == '') {
      setState(() {
        _errorText = 'Por favor, selecione uma aula ';
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }
  }

  Future<void> getDisciplinas() async {
    disciplinas.clear();
    selectedDisciplinas.clear();

    DisciplinaController disciplinaController = DisciplinaController();
    await disciplinaController.init();

    if (gestaoAtivaModel != null) {
      final model = gestaoAtivaModel!;

      disciplinas = await disciplinaController.getAllDisciplinasPeloTurmaId(
        turmaId: model.idt_turma_id.toString(),
        idtId: model.idt_id.toString(),
      );
      await iniciarDisiplinas();
      setState(() {
        print('disciplinas: $disciplinas');
      });
    } else {
      print('gestaoAtivaModel é nulo.');
    }
  }

  void _showMultiSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTema.backgroundColorApp,
            title: const Text('Selecione as disciplinas dessa aula'),
            content: SizedBox(
              height: 300,
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 8,
                child: SingleChildScrollView(
                  child: Column(
                    children: disciplinas.map((item) {
                      return CheckboxListTile(
                        activeColor: AppTema.primaryAmarelo,
                        title: Text(item.descricao.toString()),
                        value: item.checkbox,
                        onChanged: (bool? selected) {
                          setState(() {
                            item.checkbox = selected ?? false;
                            if (selected == true) {
                              addDisciplina(item);
                            } else {
                              removeDisciplina(item);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Ok',
                    style: TextStyle(color: AppTema.primaryDarkBlue)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedDisciplinas.clear();
                    for (var item in disciplinas) {
                      item.checkbox = false;
                      item.data = [];
                    }
                  });
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Limpar Seleções',
                  style: TextStyle(color: AppTema.primaryDarkBlue),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void addDisciplina(Disciplina disciplinaDetails) {
    if (disciplinaDetails.data != null && disciplinaDetails.data is List) {
      (disciplinaDetails.data as List)
          .add({'conteudo': " ", 'metodologia': '', 'horarios': []});
    } else {
      disciplinaDetails.data = [
        {'conteudo': " ", 'metodologia': '', 'horarios': []}
      ];
    }

    selectedDisciplinas.add(disciplinaDetails);

    setState(() {});
  }

  void removeDisciplina(Disciplina disciplinaDetails) {
    disciplinaDetails.data = [];
    selectedDisciplinas
        .removeWhere((disciplina) => disciplina.id == disciplinaDetails.id);
    setState(() {});
  }

  Future<void> iniciarDisiplinas() async {
    disciplinas.forEach((item) {
      item.checkbox = false;
      item.data = [];
    });

    setState(() {});
  }

  Future<void> selecaoEtapa({required int? novaSelecao}) async {
    try {
      _etapa_selecionada = novaSelecao;

      final etapaSelecionada = listaDeEtapas?.firstWhere(
        (e) => e.id.toString() == novaSelecao.toString(),
      );

      if (etapaSelecionada == null) {
        throw Exception('Etapa selecionada não encontrada na lista de etapas.');
      }

      setState(() {
        _etapa_selecionada;
        etapa_selecionada_objeto = etapaSelecionada;

        circuitoId = etapaSelecionada.circuito_nota_id.toString();
        texto1_etapa =
            'Início da etapa: ${converterDataAmericaParaBrasil(dataString: etapaSelecionada.periodo_inicial.toString())}';
        texto2_etapa =
            'Final da etapa: ${converterDataAmericaParaBrasil(dataString: etapaSelecionada.periodo_final.toString())}';

        inicioPeriodoEtapa = etapaSelecionada.periodo_inicial.toString();
        fimPeriodoEtapa = etapaSelecionada.periodo_final.toString();

        data_etapa_valida = verificarSeDataAtualEstaEntreDuasDatas(
          dataInicial: inicioPeriodoEtapa!,
          dataFinal: fimPeriodoEtapa!,
        );
      });

      verificarSeExistemAutorizacoesParaEssaEtapaEgestao();
      await gestaoAtivaDias();

      // debugPrint('_etapa_selecionada: $_etapa_selecionada');
      // debugPrint('etapa_selecionada_objeto: $etapa_selecionada_objeto');
    } catch (e) {
      debugPrint(
        'Erro ao processar a seleção da etapa ($novaSelecao): $e',
      );
    }
  }

  Future<void> gestaoAtivaDias() async {
    semanas = await gestaoAtivaModel!.getRelacoesDia();
    List<RelacaoDiaHorario> relacao =
        await gestaoAtivaModel!.getRelacoesDiasHorarios();

    setState(() => semanas);
  }

  Future<bool> validatePolivalenciaHorarios(
    BuildContext context,
    List<int> horarioIds,
  ) async {
    for (var disciplina in selectedDisciplinas) {
      for (var item in disciplina.data ?? []) {
        for (var h in item['horarios'] ?? []) {
          if (horarioIds.where((item) => item == h).isNotEmpty) {
            CustomSnackBar.showInfoSnackBar(
              context,
              'Horário já está sendo usado pela disciplina "${disciplina.descricao}"',
            );
            return false;
          }
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _situacao();
    _validadePeriodoEtapa();
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        title: const Text('Criar aula'),
        iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: gestaoAtivaModel!.is_infantil == true
          ? Center(
              child: Text(
                  'Infelizmente essa turma não possui um circuito ${Emojis.sadEmoji}'),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: AppTema.primaryWhite,
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // !! SELECIONAR A ETAPA !!
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: const Text(
                                  'Selecione a etapa',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              DropdownButtonFormField<int>(
                                value: _etapa_selecionada,
                                elevation: 1,
                                onChanged: (int? novaSelecao) async =>
                                    await selecaoEtapa(
                                  novaSelecao: novaSelecao,
                                ),
                                focusColor: AppTema.primaryDarkBlue,
                                dropdownColor: AppTema.primaryWhite,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppTema.backgroundColorApp,
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: AppTema.primaryDarkBlue,
                                        width: 1.0),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: AppTema.primaryAmarelo,
                                      width: 1.0,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                      color: AppTema.primaryDarkBlue,
                                      width: 1.0,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppTema.primaryDarkBlue,
                                ),
                                items: listaDeEtapas!
                                    .map<DropdownMenuItem<int>>((objeto) {
                                  return DropdownMenuItem<int>(
                                    value: int.parse(objeto.id),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        '${objeto.descricao}',
                                        style: const TextStyle(
                                            color: AppTema.primaryDarkBlue),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Por favor, selecione uma etapa';
                                  }
                                  return null;
                                },
                              ),
                              _etapa_selecionada != null &&
                                      situacaoStatus != 'PENDENTE'
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                          // left: 15,
                                          top: 10,
                                          bottom: 10),
                                      child: Card(
                                        elevation: 0.0,
                                        color: AppTema.primaryAmarelo,
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 15, 15, 15),
                                          child: Column(
                                            children: [
                                              const Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Informações sobre esta etapa ',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppTema
                                                          .primaryDarkBlue),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  texto1_etapa.toString(),
                                                  style: const TextStyle(
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  texto2_etapa.toString(),
                                                  style: const TextStyle(
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              etapa_selecionada_objeto != null &&
                                      situacaoStatus != 'APROVADO' &&
                                      statusPeriudo != true
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: AvisoDeRegraAutorizacoesComponente(
                                        etapa_selecionada_objeto:
                                            etapa_selecionada_objeto,
                                        autorizacaoSelecionada:
                                            autorizacaoSelecionada,
                                        statusDaAutorizacao:
                                            statusDaAutorizacao,
                                        dataLogicaExpiracao:
                                            verificarSeDataAtualEmaior(
                                          data: autorizacaoSelecionada!
                                              .dataExpiracao
                                              .toString(),
                                        ),
                                        dataEtapaValida: data_etapa_valida,
                                        etapaId:
                                            etapa_selecionada_objeto != null
                                                ? etapa_selecionada_objeto!.id
                                                : '',
                                        instrutorDisciplinaTurmaID:
                                            gestaoAtivaModel!.idt_id.toString(),
                                        statusPeriudo: statusPeriudo,
                                      ),
                                    )
                                  : const SizedBox(), // aqui
                              // Text(data_etapa_valida.toString()),
                              // Text(etapa_selecionada_objeto.toString()),
                              // Text(situacaoStatus.toString()),
                              // Text(autorizacaoSelecionada.toString()),
                              // !! CONTAINER GERAL DOS FORMULÁRIO !!
                              ((data_etapa_valida && // !! LÓGICA PARA MOSTRAR CAMPO DE CRIAR AULA OU NÃO !!
                                          etapa_selecionada_objeto != null) ||
                                      (etapa_selecionada_objeto != null &&
                                          situacaoStatus == 'APROVADO' &&
                                          !verificarSeDataAtualEmaior(
                                              data: autorizacaoSelecionada!
                                                  .dataExpiracao
                                                  .toString())))
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            child: const Text(
                                              'Tipo de Aula',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          InputDecorator(
                                            decoration: InputDecoration(
                                              fillColor:
                                                  AppTema.backgroundColorApp,
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: const BorderSide(
                                                  color:
                                                      AppTema.primaryDarkBlue,
                                                  width: 1.0,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: _aula_selecionada,
                                                dropdownColor:
                                                    AppTema.primaryWhite,
                                                onChanged:
                                                    (String? novaSelecao) =>
                                                        setState(() =>
                                                            _aula_selecionada =
                                                                novaSelecao),
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 8, 8, 8),
                                                ),
                                                icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.black,
                                                ),
                                                items: <String>[
                                                  'Aula Normal',
                                                  'Aula Remota',
                                                  'Reposição',
                                                  'Aula Extra',
                                                  'Substituição',
                                                  'Aula Antecipada',
                                                  'Aula Extra-Atividade',
                                                  'Recuperação',
                                                ].map<DropdownMenuItem<String>>(
                                                  (String opcao) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: opcao,
                                                      child: Text(opcao),
                                                    );
                                                  },
                                                ).toList(),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 5, left: 15),
                                            child: Text(
                                              _errorText ?? '',
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          // !! SELECIONAR A DATA !!
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            child: const Text(
                                              'Data da Aula',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          // Text(inicioPeriodoEtapa),
                                          // Text(fimPeriodoEtapa),
                                          // Text(semanas.toString()),
                                          Column(
                                            children: [
                                              CustomCalendarioButton(
                                                firstDate: DateTime(1999),
                                                lastDate: DateTime(2090),
                                                semanas: semanas!,
                                                fimPeriodoEtapa:
                                                    fimPeriodoEtapa,
                                                inicioPeriodoEtapa:
                                                    inicioPeriodoEtapa,
                                                onDateSelected: (selectedDate) {
                                                  _diaDaSemana =
                                                      DataTime.diaDaSemana(
                                                          selectedDate
                                                              .toString());
                                                  setState(() {
                                                    _dataSelecionada =
                                                        selectedDate.toLocal();
                                                    _diaDaSemana;
                                                  });
                                                },
                                              ),
                                              _diaDaSemana != null
                                                  ? Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 16.0,
                                                        ),
                                                        // // !! DIA DA SEMANA !!
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10),
                                                            child: const Text(
                                                              'Dia da Semana',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Card(
                                                            color: AppTema
                                                                .backgroundColorApp,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      10,
                                                                      5,
                                                                      10,
                                                                      5),
                                                              child: Text(
                                                                _diaDaSemana
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : const SizedBox(),
                                              _diaDaSemana != null
                                                  ? const SizedBox(height: 16)
                                                  : const SizedBox(height: 0),
                                              const SizedBox(height: 16),
                                              gestaoAtivaModel
                                                          ?.is_polivalencia !=
                                                      1
                                                  ? Column(
                                                      children: [
                                                        // !! SELECIONAR UM HORÁRIO !!
                                                        _aula_selecionada !=
                                                                'Aula Remota'
                                                            ? Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child:
                                                                    Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              10),
                                                                  child:
                                                                      const Text(
                                                                    'Selecione o Horário',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ),
                                                              )
                                                            : const SizedBox(),
                                                        _aula_selecionada !=
                                                                'Aula Remota'
                                                            ? DropdownButtonFormField<
                                                                int>(
                                                                dropdownColor:
                                                                    AppTema
                                                                        .primaryWhite,
                                                                value:
                                                                    _horario_selecionado,
                                                                onChanged: (var novaSelecao) =>
                                                                    setState(() =>
                                                                        _horario_selecionado =
                                                                            novaSelecao),
                                                                focusColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  filled: true,
                                                                  fillColor: AppTema
                                                                      .backgroundColorApp,
                                                                  enabledBorder:
                                                                      const OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .all(
                                                                      Radius.circular(
                                                                          8.0),
                                                                    ),
                                                                    borderSide: BorderSide(
                                                                        color: AppTema
                                                                            .primaryDarkBlue,
                                                                        width:
                                                                            1.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      const OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .all(
                                                                      Radius.circular(
                                                                          8.0),
                                                                    ),
                                                                    borderSide: BorderSide(
                                                                        color: AppTema
                                                                            .primaryDarkBlue,
                                                                        width:
                                                                            1.0),
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                  ),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16.0),
                                                                ),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .arrow_drop_down,
                                                                    color: Colors
                                                                        .black),
                                                                items: removeHorariosRepetidos(
                                                                        listaOriginal:
                                                                            listaFiltradaDeHorariosPorHorariosDaColunaDaGestao!)!
                                                                    .map<DropdownMenuItem<int>>(
                                                                        (objeto) {
                                                                  return DropdownMenuItem<
                                                                      int>(
                                                                    value: int.parse(
                                                                        objeto
                                                                            .horario
                                                                            .id),
                                                                    child: Text(objeto
                                                                        .horario
                                                                        .descricao),
                                                                  );
                                                                }).toList(),
                                                                validator:
                                                                    (value) {
                                                                  if (value ==
                                                                      null) {
                                                                    return 'Por favor, selecione um horário';
                                                                  }
                                                                  return null;
                                                                },
                                                              )
                                                            : const SizedBox(),
                                                      ],
                                                    )
                                                  : const SizedBox(),

                                              // !! CONTEÚDO !!
                                              gestaoAtivaModel
                                                          ?.is_polivalencia ==
                                                      1
                                                  ? Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0,
                                                                  bottom: 8.0),
                                                          child: TextButton(
                                                            onPressed: () =>
                                                                _showMultiSelectDialog(
                                                                    context),
                                                            style:
                                                                OutlinedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  AppTema
                                                                      .primaryAmarelo,
                                                              fixedSize:
                                                                  const Size(
                                                                      400.0,
                                                                      48.0),
                                                              side: const BorderSide(
                                                                  width: 1.0,
                                                                  color: AppTema
                                                                      .primaryAmarelo),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              'Selecione as disciplinas dessa aula',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                        ),
                                                        //Text(selectedDisciplinas.toString()),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 10,
                                                                  top: 15),
                                                          child: const Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Conteúdos',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                        ),
                                                      
                                                        selectedDisciplinas
                                                                .isNotEmpty
                                                            ? Card(
                                                                color: AppTema
                                                                    .backgroundColorApp,
                                                                elevation: 8.0,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    children:
                                                                        selectedDisciplinas
                                                                            .map((item) {
                                                                      return Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 4.0),
                                                                            child:
                                                                                Column(
                                                                              children: item.data!.map((elemente) {
                                                                                List<int> horarios = (elemente['horarios'] ?? []).cast<int>();
                                                                                return Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    _buildLabel('${item.descricao.toString()}:'),
                                                                                    //DisciplinaField(item: item,elemente:elemente, returnAndovalor: elemente['contexto']),
                                                                                    TextFormField(
                                                                                      maxLines: 8,
                                                                                      decoration: InputDecoration(
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderSide: const BorderSide(color: Colors.grey),
                                                                                          borderRadius: BorderRadius.circular(8.0),
                                                                                        ),
                                                                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(8.0),
                                                                                        ),
                                                                                      ),
                                                                                      onChanged: (value) {
                                                                                        setState(() {
                                                                                          elemente['conteudo'] = value;
                                                                                        });
                                                                                      },
                                                                                      validator: (value) {
                                                                                        if (value!.isEmpty) {
                                                                                          return 'Por favor, preencha o campo';
                                                                                        }
                                                                                        return null;
                                                                                      },
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 8.0),
                                                                                      child: Text(
                                                                                        'Horário de ${item.descricao.toString()}:',
                                                                                        style: const TextStyle(
                                                                                          fontWeight: FontWeight.w800,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                                                                                          border: Border.all(
                                                                                            color: Colors.grey, // Custom border color
                                                                                            width: 1.0, // Custom border width
                                                                                          ),
                                                                                        ),
                                                                                        child: MultiSelectDialogField<int>(
                                                                                          items: removeHorariosRepetidos(listaOriginal: listaFiltradaDeHorariosPorHorariosDaColunaDaGestao!)!
                                                                                              .map(
                                                                                                (objeto) => MultiSelectItem<int>(
                                                                                                  int.parse(objeto.horario.id),
                                                                                                  objeto.horario.descricao,
                                                                                                ),
                                                                                              )
                                                                                              .toList(),
                                                                                          listType: MultiSelectListType.CHIP,
                                                                                          initialValue: horarios, // Use the extracted 'horarios'
                                                                                          searchIcon: const Icon(Icons.search),
                                                                                          title: const Text('Horários'),
                                                                                          searchHint: 'Pesquisar', // Search hint in Portuguese
                                                                                          cancelText: const Text(
                                                                                            'Cancelar',
                                                                                            style: TextStyle(
                                                                                              fontWeight: FontWeight.bold,
                                                                                              color: AppTema.primaryAzul,
                                                                                            ),
                                                                                          ),
                                                                                          confirmText: const Text(
                                                                                            'Confirmar',
                                                                                            style: TextStyle(
                                                                                              fontWeight: FontWeight.bold,
                                                                                              color: AppTema.primaryAzul,
                                                                                            ),
                                                                                          ),
                                                                                          buttonText: const Text('Selecione'),
                                                                                          buttonIcon: const Icon(Icons.arrow_drop_down),
                                                                                          selectedColor: AppTema.secondaryAmarelo,
                                                                                          selectedItemsTextStyle: const TextStyle(
                                                                                            color: Colors.white, // Selected text color
                                                                                          ),
                                                                                          onConfirm: (List<int> selected) async {
                                                                                            bool status = await validatePolivalenciaHorarios(
                                                                                              context,
                                                                                              selected,
                                                                                            );
                                                                                            if (!status) {
                                                                                              return;
                                                                                            }
                                                                                            setState(() {
                                                                                              horarios = selected;
                                                                                              elemente['horarios'] = selected;
                                                                                            });
                                                                                          },
                                                                                          validator: (selected) {
                                                                                            if (selected == null || selected.isEmpty) {
                                                                                              return 'Por favor, selecione ao menos um horário';
                                                                                            }
                                                                                            return null;
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              }).toList(),
                                                                            ),
                                                                          ),
                                                                          const Divider(),
                                                                        ],
                                                                      );
                                                                    }).toList(),
                                                                  ),
                                                                ),
                                                              )
                                                            : const SizedBox(),
                                                      ],
                                                    )
                                                  : const SizedBox(),
                                              gestaoAtivaModel
                                                          ?.is_polivalencia !=
                                                      1
                                                  ? Column(
                                                      children: [
                                                        Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10,
                                                                    top: 15),
                                                            child: const Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                'Conteúdo',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            )),
                                                        TextFormField(
                                                          controller:
                                                              _conteudoController,
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Por favor, preencha o conteúdo';
                                                            }
                                                            return null;
                                                          },
                                                          maxLines: 8,
                                                          decoration:
                                                              InputDecoration(
                                                            fillColor: AppTema
                                                                .backgroundColorApp,
                                                            filled: true,
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        5),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : const SizedBox(),
                                              // !! METODOLOGIA !!
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 10, top: 15),
                                                child: const Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Metodologia',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              TextFormField(
                                                controller:
                                                    _metodologiaController,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Por favor, preencha a metodologia';
                                                  }
                                                  return null;
                                                },
                                                maxLines: 8,
                                                decoration: InputDecoration(
                                                  fillColor: AppTema
                                                      .backgroundColorApp,
                                                  filled: true,
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                              ),
                                              /*Container(
                                                                  margin: const EdgeInsets.only(
                                                                      bottom: 10, top: 15),
                                                                  child: const Align(
                                                                    alignment:
                                                                        Alignment.centerLeft,
                                                                    child: Text(
                                                                      'Campos de Experiência',
                                                                      style: TextStyle(
                                                                          fontSize: 16,
                                                                          color: Colors.black),
                                                                    ),
                                                                  ),
                                                                ),
                                                               CustomDropdownExperiencia(
                                                                    onSelectionChanged:
                                                                        _handleSelectionChanged),*/

                                              const SizedBox(height: 16.0),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    _validateDropdown(
                                                        _aula_selecionada);

                                                    if (_formKey.currentState!
                                                            .validate() &&
                                                        (_errorText == null ||
                                                            _errorText == '')) {
                                                      await _salvarAula();
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppTema.primaryDarkBlue,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 24.0,
                                                        vertical: 12.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Salvar',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ])
                                  : const Text('')
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDisciplinaFields(
      Disciplina item, Map<String, dynamic> elemente) {
    // Inicializa o TextEditingController com o valor de 'conteudo'
    TextEditingController conteudoController =
        TextEditingController(text: elemente['conteudo']);

    // Listen to changes in the text field and update elemente['conteudo']
    conteudoController.addListener(() {
      elemente['conteudo'] = conteudoController.text;
    });

    return Column(
      children: [
        _buildLabel('${item.descricao}:'),
        _buildTextField(conteudoController, 'Por favor, preencha o conteúdo'),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String validationMessage) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          maxLines: 8,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return validationMessage;
            }
            return null;
          },
        ),
      ],
    );
  }
}
