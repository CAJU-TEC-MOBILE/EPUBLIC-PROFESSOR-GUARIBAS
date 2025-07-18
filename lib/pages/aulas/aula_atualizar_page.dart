import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/constants/emojis.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/corrigir_data_completa_americana_para_ano_mes_dia_somente.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/data/verificar_se_data_atual_esta_entre_duas_datas.dart';
import 'package:professor_acesso_notifiq/functions/boxs/horarios/remover_horarios_repetidos.dart';
import 'package:professor_acesso_notifiq/help/console_log.dart';
import 'package:professor_acesso_notifiq/models/aula_model.dart';
import 'package:professor_acesso_notifiq/models/autorizacao_model.dart';
import 'package:professor_acesso_notifiq/models/etapa_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/models/relacao_dia_horario_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/aulas_offline_online_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';
import '../../componentes/button/custom_calendario_button.dart';
import '../../componentes/dialogs/custom_disciplinas_dialogs.dart';
import '../../componentes/dialogs/custom_snackbar.dart';
import '../../componentes/global/preloader.dart';
import '../../help/data_time.dart';
import '../../models/aula_ativa_model.dart';
import '../../models/auth_model.dart';
import '../../models/avaliador_model.dart';
import '../../models/disciplina_aula_model.dart';
import '../../models/disciplina_model.dart';
import '../../models/solicitacao_model.dart';
import '../../repository/aula_repository.dart';
import '../../repository/autorizacao_repository.dart';
import '../../services/controller/aula_controller.dart';
import '../../services/controller/auth_controller.dart';
import '../../services/controller/avaliador_controller.dart';
import '../../services/controller/disciplina_aula_controller.dart';
import '../../services/controller/disciplina_controller.dart';
import '../../services/controller/etapa_controller.dart';
import '../../services/controller/pedido_controller.dart';
import '../../services/controller/solicitacao_controller.dart';
import '../../utils/constants.dart';
import '../../utils/datetime_utils.dart';
import '../../wigets/cards/custom_solicitar_showbottomsheet.dart';
import '../../wigets/custom_periodo_card.dart';
import '../../wigets/polivalencia/custom_conteudo_polivalencia.dart';

class AulaAtualizarPage extends StatefulWidget {
  final String? aulaLocalId;
  final String? instrutorDisciplinaTurmaId;
  const AulaAtualizarPage(
      {super.key, this.aulaLocalId, this.instrutorDisciplinaTurmaId});
  @override
  State<AulaAtualizarPage> createState() => _AulaAtualizarPageState();
}

class _AulaAtualizarPageState extends State<AulaAtualizarPage> {
  final TextEditingController _conteudoController = TextEditingController();
  final TextEditingController _metodologiaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final pedidoController = PedidoController();
  final authController = AuthController();
  final avaliadorController = AvaliadorController();
  final solicitacaoController = SolicitacaoController();
  final autorizacaoRepository = AutorizacaoRepository();
  final disciplinaAulaController = DisciplinaAulaController();
  final aulasOfflineOnlineServiceAdapter = AulasOfflineOnlineServiceAdapter();
  final aulaController = AulaController();
  final _aulaRepository = AulaRepository();
  final disciplinaController = DisciplinaController();
  final _etapaController = EtapaController();
  String circuitoId = '';
  AulaAtivaModel aulaAtiva = AulaAtivaModel.vazio();
  String aulaLocalId = '';
  bool statusPeriudo = false;
  bool statusPeriodo = false;
  AuthModel authModel = AuthModel.vazio();
  Etapa etapa = Etapa.vazio();
  List<AvaliadorModel> avaliadores = [];
  List<SolicitacaoModel> solicitacoes = [];
  bool isStatus = false;
  bool isLoading = true;
  bool isLoadigList = true;
  List<DisciplinaAula> disciplinasAulas = [];
  String? _diaDaSemana;
  String? _errorText;
  String? _aula_selecionada;
  var _horario_selecionado;
  Etapa? etapaSelecionada;
  Etapa? etapa_selecionada_objeto;
  bool data_etapa_valida = true;
  DateTime? _dataSelecionada;
  List<Etapa> etapas = [];
  var texto1_etapa;
  var texto2_etapa;
  String cursoDescricao = '';
  final Box _horariosBox = Hive.box('horarios');
  List<dynamic>? horarios_data;
  List<dynamic>? listaFiltradaDeHorarios;
  List<RelacaoDiaHorario>? listaFiltradaDeHorariosPorHorariosDaColunaDaGestao;
  List<int> diasParaSeremExibidosNoCalendario = [];
  List<Etapa> listaDeEtapas = [];
  GestaoAtiva? gestaoAtivaModel;
  List<AutorizacaoModel> autorizacoesDoUsuario = [];
  List<Disciplina> disciplinas = [];
  List<Disciplina> selectedDisciplinas = [];
  AutorizacaoModel? autorizacaoSelecionada;
  String inicioPeriodoEtapa = '';
  String fimPeriodoEtapa = '';
  List<String>? semanas;
  String statusDaAutorizacao = 'INICIO';
  List<String> tipos = [
    "Aula Remota",
    "Aula Normal",
    "Reposição",
    "Aula Extra",
    "Substituição",
    "Aula Antecipada",
    "Atividade Extra-classe",
    "Recuperação",
  ];
  List<TextEditingController> controllers = [];
  TextEditingController controller = TextEditingController();
  String? instrutorDisciplinaTurmaId;
  bool isLoad = false;
  List<String> experiencias = [
    "O eu, o outro e o nós",
    "Corpo, gestos e movimentos",
    "Escuta, fala, pensamento e imaginação",
    "Traços, sons, cores e formas",
    "Espaço, tempo, quantidades, relações e transformações",
  ];

  String situacaoStatus = '';

  List<String> selectedExperiencias = [];

  Future<void> _situacao() async {
    try {
      await pedidoController.init();
      String status =
          await pedidoController.getTipoStatusPeloInstrutorDisciplinaTurmaID(
        instrutorDisciplinaTurmaID:
            gestaoAtivaModel!.instrutorDisciplinaTurma_id.toString(),
        etapaId: etapaSelecionada!.id.toString(),
        userId: authModel.id,
        circuitoId: circuitoId,
      );
      setState(() => situacaoStatus = status);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'situacao',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
    iniciando();
  }

  Future<void> _etapas() async {
    listaDeEtapas.clear();

    await _etapaController.init();

    circuitoId = (gestaoAtivaModel!.circuito_nota_id.toString());

    listaDeEtapas =
        await _etapaController.etapasPeloCircuitoId(circuitoId: circuitoId);
    setState(() {
      listaDeEtapas;
      circuitoId;
    });
  }

  Future<void> iniciando() async {
    try {
      setState(() {
        isLoading = true;
      });

      horarios_data = await _horariosBox.get('horarios');

      await _etapas();
      await loadData();
      await getConfiguracaoDisciplinas();
      await getDisciplinasAula();

      await Future.delayed(const Duration(seconds: 3));

      listaFiltradaDeHorariosPorHorariosDaColunaDaGestao =
          gestaoAtivaModel?.relacoesDiasHorarios;

      listaFiltradaDeHorariosPorHorariosDaColunaDaGestao
          ?.sort((a, b) => a.horario.descricao.compareTo(b.horario.descricao));

      setState(() {
        isLoading = false;
      });

      await gerarTextEditingController();
      await _situacao();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ConsoleLog.mensagem(
        titulo: 'error-iniciando-aula-atualização',
        mensagem: e.toString(),
        tipo: 'erro',
      );
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

  Future<void> loadData() async {
    try {
      aulaAtiva = await _aulaRepository.aulaAtiva();

      if (aulaAtiva.criadaPeloCelular == null ||
          aulaAtiva.criadaPeloCelular!.isEmpty) {
        ConsoleLog.mensagem(
          titulo: 'load-data',
          mensagem: 'Aula não encontrada',
          tipo: 'erro',
        );
        return;
      }

      if (aulaAtiva.etapa_id != null) {
        await carregarEtapa(
          etapaId: aulaAtiva.etapa_id.toString(),
        );
      }
      aulaLocalId = aulaAtiva.criadaPeloCelular;
      carregarTipoSelecionada(aulaAtiva.tipoDeAula ?? '');
      carregarDataSelecionada(aulaAtiva.dataDaAula ?? '');
      carregarHorarioSelecionada(aulaAtiva.horarioID ?? '');
      carregarConteudoSelecionada(aulaAtiva.conteudo ?? '');
      carregarMetodologiaSelecionada(aulaAtiva.metodologia ?? '');
      carregarExperienciaSelecionada(aulaAtiva.experiencias ?? []);

      _diaDaSemana = aulaAtiva.dia_da_semana ?? '';

      setState(() {
        _diaDaSemana;
        aulaAtiva;
        aulaLocalId;
      });
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'load-data',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  Future<void> carregarEtapa({required String etapaId}) async {
    try {
      listaDeEtapas.where((item) => item.id == etapaId).toList();

      if (listaDeEtapas.isEmpty) {
        return;
      }

      etapaSelecionada =
          listaDeEtapas.where((item) => item.id == etapaId).toList().first;

      if (etapaSelecionada == null) {
        return;
      }

      etapa = etapaSelecionada!;

      circuitoId = etapa.circuito_nota_id.toString();

      data_etapa_valida = verificarSeDataAtualEstaEntreDuasDatas(
        dataInicial: etapa.periodo_inicial.toString(),
        dataFinal: etapa.periodo_final.toString(),
      );

      setState(() {
        etapa;
        circuitoId;
        etapaSelecionada;
        data_etapa_valida;
      });
      selecaoEtapa(model: etapaSelecionada);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'carregar-etapa',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  void carregarTipoSelecionada(String? tipo) {
    if (tipo == null) {
      print('Tipo não selecionado.');
      return;
    }
    String tipoSelecionado =
        tipos.firstWhere((item) => item == tipo, orElse: () => '');
    setState(() {
      _aula_selecionada = tipoSelecionado != '' ? tipoSelecionado : '';
    });
  }

  void carregarDataSelecionada(String? data) {
    if (data == null) {
      print('Data não selecionada.');
      return;
    }
    DateTime? dataSelecionada;
    try {
      dataSelecionada = DateTime.parse(data);
    } catch (e) {
      print('Erro ao converter a data: $e');
      return;
    }
    setState(() {
      _dataSelecionada = dataSelecionada;
    });
    print('Data selecionada: $dataSelecionada');
  }

  void carregarHorarioSelecionada(horarioSelecionado) {
    try {
      if (horarioSelecionado == null) {
        return;
      }
      int? horarioSelecionadoId = int.tryParse(horarioSelecionado);
      setState(() {
        _horario_selecionado = horarioSelecionadoId;
      });
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'gerarTextEditingController',
        mensagem: e.toString(),
        tipo: 'erro',
      );
    }
  }

  void carregarConteudoSelecionada(String? conteudo) {
    if (conteudo == null) {
      print('Conteúdo não selecionada.');
      return;
    }
    setState(() {
      _conteudoController.text = conteudo;
    });
  }

  void carregarMetodologiaSelecionada(String? metodologia) {
    if (metodologia == null) {
      print('Metodologia não selecionada.');
      return;
    }
    setState(() {
      _metodologiaController.text = metodologia;
    });
  }

  void carregarExperienciaSelecionada(List<String> experienciaSelecionada) {
    if (experienciaSelecionada.isEmpty) {
      print('Nenhuma experiência selecionada.');
      return;
    }
    setState(() {
      selectedExperiencias = experienciaSelecionada;
    });
  }

  Future<bool> atualizarAula() async {
    try {
      showLoading(context);
      const durationDelay = Duration(seconds: 3);
      setState(() => isStatus = true);
      await disciplinaAulaController.init();
      await disciplinaAulaController.removerAulasPeloCriadaPeloCelular(
        criadaPeloCelular: widget.aulaLocalId,
      );
      if (selectedDisciplinas.isEmpty &&
          gestaoAtivaModel!.is_polivalencia == 1) {
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
        hideLoading(context);
        setState(() => isStatus = false);
        return false;
      }
      if (_diaDaSemana == null) {
        CustomSnackBar.showErrorSnackBar(
          context,
          'Por favor, selecione uma data',
        );
        return false;
      }
      Aula aulaAtualizada = Aula(
        id: '',
        e_aula_infantil: 0,
        instrutor_id: gestaoAtivaModel?.idt_instrutor_id.toString(),
        disciplina_id: gestaoAtivaModel?.idt_disciplina_id.toString(),
        turma_id: gestaoAtivaModel?.idt_turma_id.toString(),
        tipoDeAula: _aula_selecionada.toString(),
        dataDaAula: corrigirDataCompletaAmericanaParaAnoMesDiaSomente(
          dataString: _dataSelecionada.toString(),
        ),
        horarioID: _horario_selecionado.toString(),
        horarios_infantis: [],
        conteudo: _conteudoController.text.toString(),
        metodologia: _metodologiaController.text.toString(),
        saberes_conhecimentos: '',
        dia_da_semana: _diaDaSemana.toString(),
        situacao: 'Aguardando confirmação',
        criadaPeloCelular: aulaAtiva.criadaPeloCelular,
        etapa_id: etapaSelecionada!.id.toString(),
        instrutorDisciplinaTurma_id: gestaoAtivaModel?.idt_id.toString(),
        campos_de_experiencias: selectedExperiencias.toString(),
        experiencias:
            selectedExperiencias.isNotEmpty ? selectedExperiencias : [],
        is_polivalencia: gestaoAtivaModel!.is_polivalencia ?? 0,
        eixos: '',
        estrategias: '',
        recursos: '',
        atividade_casa: '',
        atividade_classe: '',
        observacoes: '',
        circuito_nota_id: gestaoAtivaModel!.circuito_nota_id,
      );

      bool sucesso = await aulasOfflineOnlineServiceAdapter.atualizar(
        aula: aulaAtualizada,
        isPolivalencia: gestaoAtivaModel!.is_polivalencia,
        disciplina: selectedDisciplinas,
      );

      await Future.delayed(durationDelay);
      hideLoading(context);
      setState(() => isStatus = false);
      if (!sucesso) {
        CustomSnackBar.showErrorSnackBar(
          context,
          'Aula não atualizada com sucesso.',
        );
        return false;
      }
      CustomSnackBar.showSuccessSnackBar(
        context,
        'Aula atualizada com sucesso',
      );
      Navigator.pushNamed(context, '/index-fundamental');
      return true;
    } catch (error) {
      hideLoading(context);
      CustomSnackBar.showErrorSnackBar(
        context,
        error.toString(),
      );
      return false;
    }
  }

  Future<void> getConfiguracaoDisciplinas() async {
    try {
      disciplinas.clear();
      await disciplinaController.init();
      if (gestaoAtivaModel == null) {
        setState(() {
          disciplinas = [];
        });
        return;
      }
      final model = gestaoAtivaModel!;

      final List<Disciplina> disciplinasCarregadas =
          await disciplinaController.getAllDisciplinasPeloTurmaId(
        turmaId: model.idt_turma_id.toString(),
        idtId: model.idt_id.toString(),
      );
      setState(() {
        disciplinas = disciplinasCarregadas;
      });
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'carregar-etapa',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  Future<void> getDisciplinasAula() async {
    try {
      selectedDisciplinas.clear();

      await disciplinaAulaController.init();

      if (gestaoAtivaModel == null) {
        setState(() {
          disciplinasAulas = [];
        });
        return;
      }

      List<DisciplinaAula> aulasCarregadas =
          await disciplinaAulaController.getDisciplinaAulaCriadaPeloCelular(
        criadaPeloCelular: aulaLocalId,
      );

      if (aulasCarregadas.isEmpty) {
        return;
      }

      for (final disciplina in disciplinas) {
        for (final aula in aulasCarregadas) {
          if (aula.id == disciplina.id) {
            disciplina.checkbox = true;
            for (var item in aula.data) {
              if (disciplina.data.isEmpty) {
                disciplina.data.add({
                  'conteudo': item['conteudo'],
                  'metodologia': '',
                  'horarios': item['horarios'],
                });
              }
              if (disciplina.data.isNotEmpty) {
                disciplina.data.first['conteudo'] = item['conteudo'];
                disciplina.data.first['horarios'] = item['horarios'];
              }
            }
            selectedDisciplinas.add(disciplina);
          }
        }
      }
      setState(() {
        selectedDisciplinas;
      });
    } catch (e, stacktrace) {
      debugPrint('Error ao carregar disciplinas selecionadas: $e');
      debugPrint('Stacktrace: $stacktrace');
    }
  }

  Future<void> addDisciplinaVisualizacao(Disciplina disciplinaDetails,
      String? conteudo, String metodologia, List<dynamic>? horarios) async {
    if (disciplinaDetails.data != null && disciplinaDetails.data is List) {
      (disciplinaDetails.data as List)
          .add({'conteudo': conteudo, 'metodologia': '', 'horarios': []});
    } else {
      disciplinaDetails.data = [
        {'conteudo': conteudo, 'metodologia': '', 'horarios': horarios}
      ];
    }
    selectedDisciplinas.add(disciplinaDetails);
    setState(() {});
  }

  Future<void> gerarTextEditingController() async {
    try {
      setState(() {
        isLoadigList = true;
      });
      await Future.delayed(const Duration(seconds: 3));
      if (selectedDisciplinas.isEmpty) {
        return;
      }
      controllers.clear();
      for (final disc in selectedDisciplinas) {
        if (disc.data != null) {
          for (final item in disc.data!) {
            debugPrint(item['conteudo']);
            final controller =
                TextEditingController(text: item['conteudo'] ?? '');
            controllers.add(controller);
          }
        }
      }
      setState(() {
        controllers;
      });
      setState(() {
        isLoadigList = false;
      });
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'gerarTextEditingController',
        mensagem: e.toString(),
        tipo: 'erro',
      );
    }
  }

  void addDisciplina(Disciplina disciplinaDetails) {
    if (disciplinaDetails.data != null && disciplinaDetails.data is List) {
      (disciplinaDetails.data as List)
          .add({'conteudo': '', 'metodologia': '', 'horarios': []});
    } else {
      disciplinaDetails.data = [
        {'conteudo': '', 'metodologia': '', 'horarios': []}
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
    for (var item in disciplinas) {
      item.checkbox = false;
      item.data = [];
    }
    setState(() {});
  }

  Future<void> gestaoAtivaDias() async {
    semanas = await gestaoAtivaModel!.getRelacoesDia();
    List<RelacaoDiaHorario> relacao =
        await gestaoAtivaModel!.getRelacoesDiasHorarios();
    setState(() => semanas);
  }

  Future<void> selecaoEtapa({required Etapa? model}) async {
    try {
      if (model == null) {
        return;
      }

      etapaSelecionada = model;
      etapa = model;
      await selecaoDeEtapa(etapaId: etapa.id);
      setState(() {
        etapa;
        etapaSelecionada;
        circuitoId = etapa.circuito_nota_id.toString();
        inicioPeriodoEtapa = etapa.periodo_inicial.toString();
        fimPeriodoEtapa = etapa.periodo_final.toString();
        data_etapa_valida = verificarSeDataAtualEstaEntreDuasDatas(
          dataInicial: inicioPeriodoEtapa,
          dataFinal: fimPeriodoEtapa,
        );
      });
      await gestaoAtivaDias();
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'selecao-etapa',
        mensagem: e.toString(),
        tipo: 'erro',
      );
    }
  }

  void _validadePeriodoEtapa() {
    try {
      if (etapa_selecionada_objeto == null) {
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
        return;
      }
      setState(() => statusPeriudo = false);
    } catch (e) {
      setState(() => statusPeriudo = false);
    }
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

  Future<void> selecaoDeEtapa({required etapaId}) async {
    etapa = listaDeEtapas
        .where((item) => item.id.toString() == etapaId.toString())
        .first;
    if (etapa.id == '') {
      return;
    }
    DateTime fim = DateTime.parse(etapa.periodo_final);
    DateTime dataAtual = DateTime.now();
    bool status = await autorizacaoRepository.existeStatusEtapaId(
      status: 'APROVADO',
      etapaId: etapaId,
    );
    if (status) {
      setState(() => statusPeriodo = false);
      return;
    }
    if (dataAtual.isBefore(fim)) {
      setState(() => statusPeriodo = false);
      return;
    }
    statusPeriodo = DateTimeUtils.isDataAtualNoPeriodo(
      dataInicial: etapa.periodo_inicial,
      dataFinal: etapa.periodo_final,
    );
    if (statusPeriodo) {
      setState(() => statusPeriodo = false);
      return;
    }
    setState(() => statusPeriodo = true);
  }

  Future<void> _avaliadores() async {
    await avaliadorController.init();
    avaliadores = await avaliadorController.avaliadorPorConfiguracao(
      configuracaoId: gestaoAtivaModel!.configuracao_id.toString(),
    );
    setState(() => avaliadores);
  }

  Future<void> _solicitacoes() async {
    await solicitacaoController.init();
    solicitacoes = await solicitacaoController.all();
    setState(() => avaliadores);
  }

  @override
  Widget build(BuildContext context) {
    _situacao();
    _validadePeriodoEtapa();
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        title: const Text('Atualizar aula'),
        iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: isLoading != true
          ? gestaoAtivaModel!.is_infantil == true
              ? Center(
                  child: Text(
                      'Infelizmente essa turma não possui um circuito ${Emojis.sadEmoji}'),
                )
              : SingleChildScrollView(
                  child: isLoad == false
                      ? Form(
                          key: _formKey,
                          child: SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: AppTema.primaryWhite,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Etapas',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        DropdownButtonFormField<Etapa>(
                                          value: etapaSelecionada,
                                          onChanged: (Etapa? model) async =>
                                              await selecaoEtapa(model: model),
                                          dropdownColor: AppTema.primaryWhite,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                AppTema.backgroundColorApp,
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                              borderSide: BorderSide(
                                                  color:
                                                      AppTema.primaryDarkBlue,
                                                  width: 1.0),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                              borderSide: BorderSide(
                                                  color: AppTema.primaryAmarelo,
                                                  width: 1.0),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                color: AppTema.primaryDarkBlue,
                                                width: 1.0,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.black,
                                          ),
                                          items: listaDeEtapas
                                              .map<DropdownMenuItem<Etapa>>(
                                                  (item) {
                                            return DropdownMenuItem<Etapa>(
                                              value: item,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Text(
                                                  item.descricao,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                        etapa.id != '' &&
                                                gestaoAtivaModel != null
                                            ? Column(
                                                children: [
                                                  const SizedBox(height: 8.0),
                                                  CustomPeriodoCard(
                                                    etapa: etapa,
                                                    isBloqueada: statusPeriodo,
                                                    onPressed: () async {
                                                      showLoading(context);
                                                      await _avaliadores();
                                                      await _solicitacoes();
                                                      await Future.delayed(
                                                          Duration(
                                                        seconds: 1,
                                                      ));
                                                      hideLoading(context);
                                                      CustomSolicitarShowBottomSheet
                                                          .show(
                                                        gestaoAtiva:
                                                            gestaoAtivaModel!,
                                                        context,
                                                        etapa: etapa,
                                                        avaliadores:
                                                            avaliadores,
                                                        solicitacoes:
                                                            solicitacoes,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              )
                                            : const SizedBox(),
                                        etapaSelecionada != null &&
                                                statusPeriodo != true
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    child: const Text(
                                                      'Tipo de Aula',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  InputDecorator(
                                                    decoration: InputDecoration(
                                                      fillColor: AppTema
                                                          .backgroundColorApp,
                                                      filled: true,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 16.0),
                                                    ),
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child: DropdownButton<
                                                          String>(
                                                        dropdownColor: AppTema
                                                            .primaryWhite,
                                                        value:
                                                            _aula_selecionada,
                                                        onChanged: (String?
                                                            novaSelecao) {
                                                          setState(() {
                                                            _aula_selecionada =
                                                                novaSelecao;
                                                          });
                                                        },
                                                        style: const TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 8, 8, 8),
                                                        ),
                                                        icon: const Icon(
                                                          Icons.arrow_drop_down,
                                                          color: Colors.black,
                                                        ),
                                                        items: Constants
                                                            .tiposDeAulas
                                                            .map<
                                                                DropdownMenuItem<
                                                                    String>>(
                                                          (String opcao) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: opcao,
                                                              child:
                                                                  Text(opcao),
                                                            );
                                                          },
                                                        ).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
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
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    child: const Text(
                                                      'Selecione uma data',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      CustomCalendarioButton(
                                                        firstDate:
                                                            DateTime(2000),
                                                        lastDate:
                                                            DateTime(2100),
                                                        semanas: semanas!,
                                                        onDataSelected:
                                                            _dataSelecionada,
                                                        onDateSelected:
                                                            (selectedDate) {
                                                          _diaDaSemana = DataTime
                                                              .diaDaSemana(
                                                                  selectedDate
                                                                      .toString());
                                                          setState(() {
                                                            _dataSelecionada =
                                                                selectedDate
                                                                    .toLocal();
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
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child:
                                                                      Container(
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10),
                                                                    child:
                                                                        const Text(
                                                                      'Dia da Semana',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Card(
                                                                    color: AppTema
                                                                        .backgroundColorApp,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          10,
                                                                          5,
                                                                          10,
                                                                          5),
                                                                      child:
                                                                          Text(
                                                                        _diaDaSemana
                                                                            .toString(),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : const SizedBox(),
                                                      _diaDaSemana != null
                                                          ? const SizedBox(
                                                              height: 0)
                                                          : const SizedBox(
                                                              height: 0),
                                                      const SizedBox(
                                                          height: 16),
                                                      gestaoAtivaModel!
                                                                  .is_polivalencia !=
                                                              1
                                                          ? Column(
                                                              children: [
                                                                _aula_selecionada !=
                                                                        'Aula Remota'
                                                                    ? Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              bottom: 10),
                                                                          child:
                                                                              const Text(
                                                                            'Selecione um horário',
                                                                            style:
                                                                                TextStyle(fontSize: 16, color: Colors.black),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : const SizedBox(),
                                                                _aula_selecionada !=
                                                                        'Aula Remota'
                                                                    ? DropdownButtonFormField<
                                                                        int>(
                                                                        value:
                                                                            _horario_selecionado,
                                                                        onChanged:
                                                                            (var novaSelecao) =>
                                                                                setState(() => _horario_selecionado = novaSelecao),
                                                                        decoration:
                                                                            InputDecoration(
                                                                          fillColor:
                                                                              AppTema.backgroundColorApp,
                                                                          filled:
                                                                              true,
                                                                          border:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Colors.black,
                                                                              width: 1.0,
                                                                            ),
                                                                          ),
                                                                          contentPadding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 16.0),
                                                                        ),
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .arrow_drop_down,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        items: removeHorariosRepetidos(listaOriginal: listaFiltradaDeHorariosPorHorariosDaColunaDaGestao!)!
                                                                            .map<DropdownMenuItem<int>>((objeto) {
                                                                          return DropdownMenuItem<
                                                                              int>(
                                                                            value:
                                                                                int.parse(objeto.horario.id),
                                                                            child:
                                                                                Text(objeto.horario.descricao),
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
                                                                    : const Text(
                                                                        ''),
                                                                Container(
                                                                  margin: const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10,
                                                                      top: 15),
                                                                  child:
                                                                      const Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      'Conteúdo',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextFormField(
                                                                  controller:
                                                                      _conteudoController,
                                                                  validator:
                                                                      (value) {
                                                                    if (value!
                                                                        .isEmpty) {
                                                                      return 'Por favor, preencha o conteúdo';
                                                                    }
                                                                    return null;
                                                                  },
                                                                  maxLines: 8,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    fillColor:
                                                                        AppTema
                                                                            .backgroundColorApp,
                                                                    filled:
                                                                        true,
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          const BorderSide(
                                                                              color: Colors.grey),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    contentPadding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            5),
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : const SizedBox(),
                                                      gestaoAtivaModel
                                                                  ?.is_polivalencia ==
                                                              1
                                                          ? Column(
                                                              children: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) =>
                                                                              CustomDisciplinasDialog(
                                                                        selectedDisciplinas:
                                                                            selectedDisciplinas,
                                                                        onSelectedDisciplinas:
                                                                            (disciplinas) {
                                                                          setState(
                                                                              () {
                                                                            selectedDisciplinas =
                                                                                disciplinas;
                                                                          });
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                  style: OutlinedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        AppTema
                                                                            .primaryAmarelo,
                                                                    fixedSize:
                                                                        const Size(
                                                                            400.0,
                                                                            48.0),
                                                                    side:
                                                                        const BorderSide(
                                                                      width:
                                                                          1.0,
                                                                      color: AppTema
                                                                          .primaryAmarelo,
                                                                    ),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                        8.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Text(
                                                                    'Selecione as disciplinas dessa aula',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 18.0,
                                                                ),
                                                                CustomConteudoPolivalencia(
                                                                  context:
                                                                      context,
                                                                  items:
                                                                      selectedDisciplinas,
                                                                  relacaoDiaHorario:
                                                                      listaFiltradaDeHorariosPorHorariosDaColunaDaGestao ??
                                                                          [],
                                                                ),
                                                              ],
                                                            )
                                                          : const SizedBox(),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                            bottom: 10,
                                                            top: 15),
                                                        child: const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            'Metodologia',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black),
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
                                                        decoration:
                                                            InputDecoration(
                                                          fillColor: AppTema
                                                              .backgroundColorApp,
                                                          filled: true,
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                            ),
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
                                                                  vertical: 5),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 16.0),
                                                      Column(
                                                        children: [
                                                          isStatus != true
                                                              ? SizedBox(
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  child:
                                                                      ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      _validateDropdown(
                                                                          _aula_selecionada);
                                                                      if (_formKey
                                                                              .currentState!
                                                                              .validate() &&
                                                                          (_errorText == null ||
                                                                              _errorText == '')) {
                                                                        await atualizarAula();
                                                                      }
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          AppTema
                                                                              .primaryDarkBlue,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              24.0,
                                                                          vertical:
                                                                              12.0),
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        const Text(
                                                                      'Salvar',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ))
                                                              : SizedBox(
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  child:
                                                                      ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      return;
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          AppTema
                                                                              .primaryDarkBlue,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              28.0,
                                                                          vertical:
                                                                              2.0),
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        const SizedBox(
                                                                      width: 16,
                                                                      height:
                                                                          16,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2.0,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : const SizedBox()
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: AppTema.primaryAmarelo,
                          ),
                        ),
                )
          : const Center(
              child: CircularProgressIndicator(
                color: AppTema.primaryAmarelo,
              ),
            ),
    );
  }
}
