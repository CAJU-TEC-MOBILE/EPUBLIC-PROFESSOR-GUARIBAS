import 'dart:convert';
import 'dart:math';
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
import 'package:professor_acesso_notifiq/models/etapa_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/models/horario_model.dart';
import 'package:professor_acesso_notifiq/models/relacao_dia_horario_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/aulas_offline_online_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/autorizacoes_service.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/regras_logicas/autorizacoes/listar_unica_autorizacao_por_etapa_e_gestao_e_ultimoItem_regra_logica.dart';
import 'package:professor_acesso_notifiq/services/http/autorizacoes/autorizacoes_listar_http.dart';

import '../../componentes/button/custom_calendario_button.dart';
import '../../componentes/dialogs/custom_snackbar.dart';
import '../../componentes/dialogs/custom_dialogs.dart';
import '../../componentes/dropdown/custom_dropdown_experiencia.dart';
import '../../help/data_time.dart';
import '../../models/auth_model.dart';
import '../../models/disciplina_aula_model.dart';
import '../../models/disciplina_model.dart';
import '../../services/adapters/auth_service_adapter.dart';
import '../../services/controller/aula_controller.dart';
import '../../services/controller/disciplina_aula_controller.dart';
import '../../services/controller/disciplina_controller.dart';
import '../../services/controller/pedido_controller.dart';
import 'listagem_aulas_page.dart';

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
  Auth authModel = AuthServiceAdapter().exibirAuth();

  bool isStatus = false;
  bool isLoading = true;
  bool isLoadigList = true;
  List<DisciplinaAula> disciplinasAulas = [];
  String? _diaDaSemana;
  String? _errorText;
  String? _aula_selecionada;
  var _horario_selecionado;
  var _etapa_selecionada;
  Etapa? etapa_selecionada_objeto;
  bool data_etapa_valida = true;
  DateTime? _dataSelecionada;
  var texto1_etapa;
  var texto2_etapa;
  String cursoDescricao = '';
  Box _horariosBox = Hive.box('horarios');
  List<dynamic>? horarios_data;
  List<dynamic>? listaFiltradaDeHorarios;
  List<RelacaoDiaHorario>? listaFiltradaDeHorariosPorHorariosDaColunaDaGestao;
  List<int> diasParaSeremExibidosNoCalendario = [];
  List<Etapa>? listaDeEtapas;
  GestaoAtiva? gestaoAtivaModel;
  List<Autorizacao> autorizacoesDoUsuario =
      AutorizacoesServiceAdapter().listar();
  List<Disciplina> disciplinas = [];
  List<Disciplina> selectedDisciplinas = [];
  Autorizacao? autorizacaoSelecionada;
  String inicioPeriodoEtapa = '';
  String fimPeriodoEtapa = '';
  List<String>? semanas;
  bool statusPeriudo = false;
  String statusDaAutorizacao = 'INICIO';
  List<String> tipos = [
    'Aula Normal',
    'Aula Remota',
    'Reposição',
    'Aula Extra',
    'Substituição',
    'Aula Antecipada',
    'Aula Extra-Atividade',
    'Recuperação'
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
  String circuitoId = '';
  List<String> selectedExperiencias = [];

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
    // print("status: $status");
    setState(() => situacaoStatus = status);
  }

  // Define the callback function
  void _handleSelectionChanged(List<String> selecionadas) {
    setState(() {
      selectedExperiencias = selecionadas;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Se o valor não foi passado diretamente no construtor, tenta obtê-lo dos argumentos da rota
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && widget.instrutorDisciplinaTurmaId == null) {
      instrutorDisciplinaTurmaId =
          args['instrutorDisciplinaTurmaId']!.toString();
      print(instrutorDisciplinaTurmaId);
    } else {
      instrutorDisciplinaTurmaId = widget.instrutorDisciplinaTurmaId;
    }
  }

  void initState() {
    super.initState();

    iniciando();
    // atualizarAutorizacoes();
    // getDisciplinas();
    // horarios_data = _horariosBox.get('horarios');
    // gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
    // gestaoAtivaModel?.circuito.etapas;
    // listaDeEtapas = filtrarEtapasPorGestaoAtiva();
    // // listaFiltradaDeHorarios = filtrarListaDeObjetoPorCondicaoUnica(
    // //     lista_de_objetos: horarios_data!, condicao: gestaoAtivaModel?.turno_id);
    // listaFiltradaDeHorariosPorHorariosDaColunaDaGestao = gestaoAtivaModel?.relacoesDiasHorarios;
    // listaFiltradaDeHorariosPorHorariosDaColunaDaGestao?.sort((a, b) => a.horario.descricao.compareTo(b.horario.descricao));
    // _mostrarCalendario(context);
    // _dataSelecionada =
    // _ajustarDataParaDiasMaisProximoDoCampoRelacoesDiasHorarios(DateTime.now());
    // carregarDados(criadaPeloCelularId: widget.aulaLocalId);
  }

  Future<void> iniciando() async {
    try {
      setState(() {
        isLoading = true;
      });

      //await atualizarAutorizacoes();

      horarios_data = await _horariosBox.get('horarios');
      gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
      gestaoAtivaModel?.circuito.etapas;
      listaDeEtapas = filtrarEtapasPorGestaoAtiva();
      // listaFiltradaDeHorarios = filtrarListaDeObjetoPorCondicaoUnica(
      //     lista_de_objetos: horarios_data!, condicao: gestaoAtivaModel?.turno_id);
      listaFiltradaDeHorariosPorHorariosDaColunaDaGestao =
          gestaoAtivaModel?.relacoesDiasHorarios;
      listaFiltradaDeHorariosPorHorariosDaColunaDaGestao
          ?.sort((a, b) => a.horario.descricao.compareTo(b.horario.descricao));
      await _mostrarCalendario(context);
      _dataSelecionada =
          _ajustarDataParaDiasMaisProximoDoCampoRelacoesDiasHorarios(
              DateTime.now());
      await carregarDados(criadaPeloCelularId: widget.aulaLocalId);
      await getConfiguracaoDisciplinas();
      await getDisciplinasAula();

      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        isLoading = false;
      });
      await gerarTextEditingController();
      _situacao();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('error-iniciando-aula-atualização: $e');
    }
  }

  Future<void> atualizarAutorizacoes() async {
    AutorizacoesListarHttp apiService = AutorizacoesListarHttp();
    http.Response response = await apiService.executar();
    Map<dynamic, dynamic> responseDecode = await jsonDecode(response.body);
    await AutorizacoesServiceAdapter()
        .salvar(responseDecode['autorizacoes_atualizadas']);
    setState(() {
      //print('setState de autorizacoesDoUsuario');
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

  Future<void> carregarDados({required String? criadaPeloCelularId}) async {
    try {
      AulaController aulaController = AulaController();

      await aulaController.init();

      if (criadaPeloCelularId == null) {
        print("ID criadaPeloCelularId é nulo.");
        return;
      }

      List<Aula> aulas = await aulaController.getAulaCriadaPeloCelular(
          criadaPeloCelular: criadaPeloCelularId);

      if (aulas.isNotEmpty) {
        for (var aula in aulas) {
          int? etapaId = int.tryParse(aula.etapa_id);
          if (etapaId != null) {
            carregarEtapaSelecionada(etapaId);
          } else {
            print("Etapa ID não é um número válido para a aula: $aula");
          }
          setState(() => _diaDaSemana = aula.dia_da_semana.toString());
          carregarTipoSelecionada(aula.tipoDeAula);
          carregarDataSelecionada(aula.dataDaAula);
          carregarHorarioSelecionada(aula.horarioID);
          carregarConteudoSelecionada(aula.conteudo);
          carregarMetodologiaSelecionada(aula.metodologia);
          carregarExperienciaSelecionada(aula.experiencias);
        }
      } else {
        print(
            "Nenhuma aula encontrada com o ID fornecido: $criadaPeloCelularId");
      }
    } catch (e) {
      print("Erro ao carregar os dados: $e");
    }
  }

  void carregarEtapaSelecionada(int novaSelecao) {
    var etapaSelecionada = listaDeEtapas!.firstWhere(
      (item) => item.id == novaSelecao.toString(),
      orElse: () => Etapa(
        id: '-1', // ID
        circuito_nota_id: '',
        curso_descricao: '',
        descricao: '',
        periodo_inicial: '',
        periodo_final: '',
        situacao_faltas: '',
        etapa_global: '',
      ),
    );

    if (etapaSelecionada.id != '-1') {
      _etapa_selecionada = int.parse(etapaSelecionada.id);
      selecaoEtapa(novaSelecao: _etapa_selecionada);
      texto1_etapa =
          'Início da etapa: ${converterDataAmericaParaBrasil(dataString: etapaSelecionada.periodo_inicial.toString())}';
      texto2_etapa =
          'Final da etapa: ${converterDataAmericaParaBrasil(dataString: etapaSelecionada.periodo_final.toString())}';
      etapa_selecionada_objeto = etapaSelecionada;
      verificarSeExistemAutorizacoesParaEssaEtapaEgestao();
      data_etapa_valida = verificarSeDataAtualEstaEntreDuasDatas(
        dataInicial: etapaSelecionada.periodo_inicial.toString(),
        dataFinal: etapaSelecionada.periodo_final.toString(),
      );
      setState(() {
        _etapa_selecionada;
        circuitoId = etapaSelecionada.circuito_nota_id.toString();
        texto1_etapa;
        texto2_etapa;
        data_etapa_valida;
        etapa_selecionada_objeto;
      });
    } else {
      print('Etapa não encontrada para o ID: $novaSelecao');
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

    print('Tipo selecionado: $tipoSelecionado');
  }

  void carregarDataSelecionada(String? data) {
    if (data == null) {
      print('Data não selecionada.');
      return;
    }

    // Converte a string em DateTime
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
    if (horarioSelecionado == null) {
      print('Horário não selecionada.');
      return;
    }
    int? horarioSelecionadoId = int.tryParse(horarioSelecionado);
    setState(() {
      _horario_selecionado = horarioSelecionadoId;
    });

    print('Data selecionada: $horarioSelecionado');
  }

  void carregarConteudoSelecionada(String? conteudo) {
    if (conteudo == null) {
      print('Conteúdo não selecionada.');
      return;
    }
    setState(() {
      _conteudoController.text = conteudo;
    });

    print('Conteúdo selecionada: $conteudo');
  }

  void carregarMetodologiaSelecionada(String? metodologia) {
    if (metodologia == null) {
      print('Metodologia não selecionada.');
      return;
    }
    setState(() {
      _metodologiaController.text = metodologia;
    });

    print('Metodologia selecionada: $metodologia');
  }

  void carregarExperienciaSelecionada(List<String> experienciaSelecionada) {
    if (experienciaSelecionada.isEmpty) {
      print('Nenhuma experiência selecionada.');
      return;
    }
    setState(() {
      selectedExperiencias = experienciaSelecionada;
    });

    print('Experiências selecionadas: $experienciaSelecionada');
  }

  Future<bool> atualizarAula() async {
    try {
      const DURATION_DELAY = Duration(seconds: 3);

      CustomDialogs.showLoadingDialog(context,
          show: true, message: 'Aguardando...');
      setState(() => isStatus = true);

      //print(widget.aulaLocalId.toString());

      DisciplinaAulaController disciplinaAulaController =
          DisciplinaAulaController();
      AulasOfflineOnlineServiceAdapter aulasOfflineOnlineServiceAdapter =
          AulasOfflineOnlineServiceAdapter();

      await disciplinaAulaController.init();
      await disciplinaAulaController.removerAulasPeloCriadaPeloCelular(
          criadaPeloCelular: widget.aulaLocalId);
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
        CustomDialogs.showLoadingDialog(context, show: false);
        setState(() => isStatus = false);
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
        criadaPeloCelular: widget.aulaLocalId.toString(),
        etapa_id: _etapa_selecionada.toString(),
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
      );

      bool sucesso = await aulasOfflineOnlineServiceAdapter.atualizar(
        aula: aulaAtualizada,
        isPolivalencia: gestaoAtivaModel!.is_polivalencia,
        disciplina: selectedDisciplinas,
      );

      await Future.delayed(DURATION_DELAY);

      CustomDialogs.showLoadingDialog(context, show: false);
      setState(() => isStatus = false);

      if (!sucesso) {
        CustomSnackBar.showErrorSnackBar(
            context, 'Aula não atualizada com sucesso.');
        return false;
      }

      CustomSnackBar.showSuccessSnackBar(
        context,
        'Aula atualizada com sucesso',
      );
      Navigator.pushNamed(context, '/index-fundamental');
      //Navigator.pop(context);
      //Navigator.pop(context);

      return true;
    } catch (e) {
      print('error-atualizar-aula: $e');
      return false;
    }
  }

  Future<void> getConfiguracaoDisciplinas() async {
    try {
      disciplinas.clear();

      DisciplinaController disciplinaController = DisciplinaController();
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
      print("===> $disciplinasCarregadas");
      setState(() {
        disciplinas = disciplinasCarregadas;
      });

      //debugPrint('Disciplinas carregadas com sucesso: $disciplinasCarregadas');
    } catch (e, stacktrace) {
      debugPrint('Error ao carregar as disciplinas: $e');
      debugPrint('Stacktrace: $stacktrace');
    }
  }

  Future<void> getDisciplinasAula() async {
    try {
      selectedDisciplinas.clear();

      DisciplinaAulaController disciplinaAulaController =
          DisciplinaAulaController();
      await disciplinaAulaController.init();

      if (gestaoAtivaModel == null) {
        setState(() {
          disciplinasAulas = [];
        });
        return;
      }

      final List<DisciplinaAula> aulasCarregadas =
          await disciplinaAulaController.getDisciplinaAulaCriadaPeloCelular(
        criadaPeloCelular: widget.aulaLocalId,
      );

      if (aulasCarregadas.isEmpty) {
        return;
      }

      List<dynamic> items;
      controllers.clear();
      for (final disciplina in disciplinas) {
        for (final aula in aulasCarregadas) {
          //debugPrint('DATA: ${aula.data.toString()}');

          if (aula.id == disciplina.id) {
            List<dynamic> items = [];

            // Inicializar 'disciplina.data' uma única vez se for nulo
            disciplina.data ??= [];

            aula.data.forEach((item) {
              // Certifique-se de que 'horarios' existe antes de adicionar
              if (item['horarios'] != null) {
                items.addAll(item['horarios']);
              }
            });

            setState(() {
              // Atualizar os dados da disciplina com os horários encontrados
              disciplina.data = items;
            });

            final disc = Disciplina(
              id: disciplina.id,
              codigo: disciplina.codigo,
              descricao: disciplina.descricao,
              idtTurmaId: disciplina.idtTurmaId,
              idt_id: disciplina.idt_id,
              checkbox: true,
              data: disciplina.data,
            );
            setState(() {
              disciplina.checkbox = true;
            });
            // Verificação se 'conteudo' existe antes de criar o controlador
            String? conteudo =
                aula.data.isNotEmpty && aula.data[0].containsKey('conteudo')
                    ? aula.data[0]['conteudo']
                    : '';
            await addDisciplinaVisualizacao(
                disc, conteudo, '2', disciplina.data);
          }
        }
      }

      //debugPrint('Disciplinas selecionadas carregadas com sucesso: $selectedDisciplinas');
      setState(() {
        selectedDisciplinas;
        //disciplinas = selectedDisciplinas;
      });
    } catch (e, stacktrace) {
      debugPrint('Error ao carregar disciplinas selecionadas: $e');
      debugPrint('Stacktrace: $stacktrace');
    }
  }

  void _showMultiSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTema.backgroundColorApp,
            title: const Text('Selecione as disciplinas'),
            content: SizedBox(
              height: 300,
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 8,
                child: SingleChildScrollView(
                  child: Column(
                    children: disciplinas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return CheckboxListTile(
                        activeColor: AppTema.primaryAmarelo,
                        title: Text(item.descricao.toString()),
                        value: item.checkbox,
                        onChanged: (bool? selected) {
                          setState(() {
                            isLoadigList = false;
                            var newController = TextEditingController();
                            if (selected == true) {
                              item.checkbox = true;
                              item.data = null;
                              controllers.insert(index, newController);
                              addDisciplina(item);
                            } else {
                              item.checkbox = false;
                              item.data = null;
                              selectedDisciplinas
                                  .removeWhere((disc) => disc.id == item.id);
                              controllers.removeAt(index);
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
                child: const Text(
                  'Ok',
                  style: TextStyle(color: AppTema.primaryDarkBlue),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedDisciplinas.clear();
                    // print(selectedDisciplinas);
                    disciplinas.forEach((item) {
                      item.checkbox = false;
                      item.data = [];
                    });
                  });
                  Navigator.of(context).pop(false);
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
    debugPrint('=== gerar-text-editing-controller ==');
    setState(() {
      isLoadigList = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    if (selectedDisciplinas.isEmpty) {
      return;
    }

    // Limpa os controladores existentes para evitar duplicatas ao regenerar os controladores
    controllers.clear();

    // Itera sobre cada disciplina selecionada
    for (final disc in selectedDisciplinas) {
      // Verifica se 'disc.data' não é nulo antes de iterar
      if (disc.data != null) {
        // Itera sobre cada item de 'disc.data'
        for (final item in disc.data!) {
          debugPrint(item['conteudo']);
          final controller =
              TextEditingController(text: item['conteudo'] ?? '');
          controllers.add(controller);
        }
      }
    }

    setState(() {
      //print(controllers);
      controllers;
    });

    setState(() {
      isLoadigList = false;
    });
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
    disciplinas.forEach((item) {
      item.checkbox = false;
      item.data = [];
    });
    setState(() {});
  }

  Future<void> gestaoAtivaDias() async {
    semanas = await gestaoAtivaModel!.getRelacoesDia();
    List<RelacaoDiaHorario> relacao =
        await gestaoAtivaModel!.getRelacoesDiasHorarios();
    setState(() => semanas);
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
        etapa_selecionada_objeto = etapaSelecionada;

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
                          child: Container(
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
                                        // !! SELECIONAR A ETAPA !!
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          child: const Text(
                                            'Selecione a etapa',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ),
                                        // Text(
                                        //     '_etapa_selecionada: $_etapa_selecionada'),
                                        Container(
                                            child: DropdownButtonFormField<int>(
                                          value: _etapa_selecionada,
                                          onChanged: (int? novaSelecao) async =>
                                              await selecaoEtapa(
                                            novaSelecao: novaSelecao,
                                          ),
                                          focusColor: AppTema.primaryDarkBlue,
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
                                                    horizontal: 16.0),
                                          ),
                                          icon: const Icon(
                                            Icons
                                                .arrow_drop_down, // Ícone da seta
                                            color: Colors
                                                .black, // Cor do ícone da seta
                                          ),
                                          items: listaDeEtapas!
                                              .map<DropdownMenuItem<int>>(
                                                  (objeto) {
                                            return DropdownMenuItem<int>(
                                                value: int.parse(objeto.id),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Text(
                                                    '${objeto.descricao}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ));
                                          }).toList(),
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Por favor, selecione uma etapa';
                                            }
                                            return null;
                                          },
                                        )),
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Column(
                                                      children: [
                                                        const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            'Informações sobre esta etapa ',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppTema
                                                                    .primaryDarkBlue),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                              texto1_etapa
                                                                  .toString()),
                                                        ),
                                                        const SizedBox(
                                                          height: 3,
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            texto2_etapa
                                                                .toString(),
                                                            style: const TextStyle(
                                                                color: AppTema
                                                                    .primaryDarkBlue),
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
                                            ? AvisoDeRegraAutorizacoesComponente(
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
                                                dataEtapaValida:
                                                    data_etapa_valida,
                                                etapaId:
                                                    etapa_selecionada_objeto !=
                                                            null
                                                        ? etapa_selecionada_objeto!
                                                            .id
                                                        : '',
                                                instrutorDisciplinaTurmaID:
                                                    gestaoAtivaModel!.idt_id
                                                        .toString(),
                                                statusPeriudo: statusPeriudo,
                                              )
                                            : const SizedBox(),

                                        // !! CONTAINER GERAL DOS FORMULÁRIO !!
                                        ((data_etapa_valida && // !! LÓGICA PARA MOSTRAR CAMPO DE CRIAR AULA OU NÃO !!
                                                    etapa_selecionada_objeto !=
                                                        null) ||
                                                (etapa_selecionada_objeto !=
                                                        null &&
                                                    situacaoStatus ==
                                                        'APROVADO' &&
                                                    !verificarSeDataAtualEmaior(
                                                        data:
                                                            autorizacaoSelecionada!
                                                                .dataExpiracao
                                                                .toString())))
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      child: const Text(
                                                        'Tipo de Aula',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    InputDecorator(
                                                      decoration:
                                                          InputDecoration(
                                                        fillColor: AppTema
                                                            .backgroundColorApp,
                                                        filled: true,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Colors.grey,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    16.0),
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
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    8,
                                                                    8,
                                                                    8),
                                                          ),
                                                          icon: const Icon(
                                                            Icons
                                                                .arrow_drop_down, // Ícone da seta
                                                            color: Colors
                                                                .black, // Cor do ícone da seta
                                                          ),
                                                          items: tipos.map<
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

                                                    // !! SELECIONAR A DATA !!
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      child: const Text(
                                                        'Data da Aula',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    Container(
                                                        child: Column(
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
                                                                    height:
                                                                        16.0,
                                                                  ),
                                                                  // // !! DIA DA SEMANA !!
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
                                                                height: 16)
                                                            : const SizedBox(
                                                                height: 0),
                                                        // Container(
                                                        //   decoration:
                                                        //       BoxDecoration(
                                                        //     border: Border.all(
                                                        //         color: Colors
                                                        //             .black,
                                                        //         width: 1.0),
                                                        //     borderRadius:
                                                        //         BorderRadius
                                                        //             .circular(
                                                        //                 8.0),
                                                        //   ),
                                                        //   child: Container(
                                                        //     width:
                                                        //         double.infinity,
                                                        //     decoration:
                                                        //         BoxDecoration(
                                                        //       color: Colors
                                                        //           .grey[350],
                                                        //       borderRadius:
                                                        //           BorderRadius
                                                        //               .circular(
                                                        //                   8.0),
                                                        //     ),
                                                        //     height: 45,
                                                        //     child:
                                                        //         ElevatedButton(
                                                        //       style: ElevatedButton.styleFrom(
                                                        //           backgroundColor:
                                                        //               Colors
                                                        //                   .transparent,
                                                        //           side:
                                                        //               BorderSide
                                                        //                   .none,
                                                        //           elevation:
                                                        //               0.0),
                                                        //       onPressed: () {
                                                        //         _mostrarCalendario(
                                                        //             context);
                                                        //       },
                                                        //       child: Align(
                                                        //         alignment: Alignment
                                                        //             .centerLeft,
                                                        //         child: Row(
                                                        //           mainAxisAlignment:
                                                        //               MainAxisAlignment
                                                        //                   .spaceBetween,
                                                        //           children: [
                                                        //             Text(
                                                        //               '${DateFormat('dd/MM/yyyy').format(_dataSelecionada!)}',
                                                        //               style:
                                                        //                   const TextStyle(
                                                        //                 color: Colors
                                                        //                     .black,
                                                        //                 fontWeight:
                                                        //                     FontWeight.normal,
                                                        //               ),
                                                        //               textAlign:
                                                        //                   TextAlign
                                                        //                       .start,
                                                        //             ),
                                                        //             const Icon(
                                                        //               Icons
                                                        //                   .arrow_drop_down,
                                                        //               color: Colors
                                                        //                   .black,
                                                        //             ),
                                                        //           ],
                                                        //         ),
                                                        //       ),
                                                        //       /*style: ButtonStyle(
                                                        //                                   backgroundColor:
                                                        //                                       MaterialStateProperty
                                                        //                                           .all<
                                                        //                                               Color>(
                                                        //                                     AppTema
                                                        //                                         .secondaryAmarelo, // Cor de fundo
                                                        //                                   ),
                                                        //                                 ),*/
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                        //Text(_horario_selecionado.toString()),
                                                        const SizedBox(
                                                            height: 16),
                                                        gestaoAtivaModel!
                                                                    .is_polivalencia !=
                                                                1
                                                            ? Column(
                                                                children: [
                                                                  // !! SELECIONAR UM HORÁRIO !!
                                                                  _aula_selecionada !=
                                                                          'Aula Remota'
                                                                      ? Align(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                const EdgeInsets.only(bottom: 10),
                                                                            child:
                                                                                const Text(
                                                                              'Selecione o Horário',
                                                                              style: TextStyle(fontSize: 16, color: Colors.black),
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
                                                                          onChanged: (var novaSelecao) =>
                                                                              setState(() => _horario_selecionado = novaSelecao),
                                                                          focusColor:
                                                                              Colors.black,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            fillColor:
                                                                                AppTema.backgroundColorApp,
                                                                            filled:
                                                                                true,
                                                                            border:
                                                                                OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              borderSide: const BorderSide(
                                                                                color: Colors.black,
                                                                                width: 1.0,
                                                                              ),
                                                                            ),
                                                                            contentPadding:
                                                                                const EdgeInsets.symmetric(horizontal: 16.0),
                                                                          ),
                                                                          icon:
                                                                              const Icon(
                                                                            Icons.arrow_drop_down,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                          items:
                                                                              removeHorariosRepetidos(listaOriginal: listaFiltradaDeHorariosPorHorariosDaColunaDaGestao!)!.map<DropdownMenuItem<int>>((objeto) {
                                                                            return DropdownMenuItem<int>(
                                                                              value: int.parse(objeto.horario.id),
                                                                              child: Text(objeto.horario.descricao),
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

                                                                  // !! CONTEÚDO !!

                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10,
                                                                        top:
                                                                            15),
                                                                    child:
                                                                        const Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
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
                                                                            const BorderSide(color: Colors.grey),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
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
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : const SizedBox(),
                                                        // Text(gestaoAtivaModel!.is_polivalencia.toString()),
                                                        // Text(selectedDisciplinas.toString()),
                                                        gestaoAtivaModel
                                                                    ?.is_polivalencia ==
                                                                1
                                                            ? Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            8.0,
                                                                        bottom:
                                                                            8.0),
                                                                    child:
                                                                        TextButton(
                                                                      onPressed:
                                                                          () =>
                                                                              _showMultiSelectDialog(context),
                                                                      style: OutlinedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            AppTema.primaryAmarelo,
                                                                        fixedSize: const Size(
                                                                            400.0,
                                                                            48.0),
                                                                        side: const BorderSide(
                                                                            width:
                                                                                1.0,
                                                                            color:
                                                                                AppTema.primaryAmarelo),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        'Selecione as disciplinas dessa aula',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10,
                                                                        top:
                                                                            15),
                                                                    child:
                                                                        const Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        'Conteúdos',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  selectedDisciplinas
                                                                          .isNotEmpty
                                                                      ? Card(
                                                                          color:
                                                                              AppTema.backgroundColorApp,
                                                                          elevation:
                                                                              8.0,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child: !isLoadigList
                                                                                ? Column(
                                                                                    children: selectedDisciplinas.asMap().entries.map((entry) {
                                                                                      final index = entry.key;
                                                                                      final item = entry.value;

                                                                                      if (item.data == null) {
                                                                                        return const SizedBox();
                                                                                      }

                                                                                      return Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                                                            child: Column(
                                                                                              children: item.data!.asMap().entries.map((dataEntry) {
                                                                                                final dataIndex = dataEntry.key;
                                                                                                final elemente = dataEntry.value;

                                                                                                List<int> horarios = (elemente['horarios'] ?? []).cast<int>();
                                                                                                final conteudo = (elemente['conteudo'] ?? '');

                                                                                                if (controllers.length <= dataIndex) {
                                                                                                  controllers.add(TextEditingController(text: conteudo));
                                                                                                }

                                                                                                final controller = controllers[index];

                                                                                                return Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    // Text('Total de Controladores: ${controllers.length.toString()}'),
                                                                                                    // Text('Conteúdo Atual: $conteudo'),
                                                                                                    // Text('Index: ${index.toString()}'),
                                                                                                    _buildLabel('${item.descricao.toString()}:'),
                                                                                                    TextFormField(
                                                                                                      controller: controller,
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
                                                                                                          return 'Por favor, insira o conteúdo';
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
                                                                                                          borderRadius: BorderRadius.circular(8.0),
                                                                                                          border: Border.all(
                                                                                                            color: Colors.grey,
                                                                                                            width: 1.0,
                                                                                                          ),
                                                                                                        ),
                                                                                                        child: MultiSelectDialogField<int>(
                                                                                                          items: removeHorariosRepetidos(
                                                                                                            listaOriginal: listaFiltradaDeHorariosPorHorariosDaColunaDaGestao!,
                                                                                                          )!
                                                                                                              .map(
                                                                                                                (objeto) => MultiSelectItem<int>(
                                                                                                                  int.parse(objeto.horario.id),
                                                                                                                  objeto.horario.descricao,
                                                                                                                ),
                                                                                                              )
                                                                                                              .toList(),
                                                                                                          listType: MultiSelectListType.CHIP,
                                                                                                          initialValue: horarios,
                                                                                                          searchIcon: const Icon(Icons.search),
                                                                                                          title: const Text('Horários'),
                                                                                                          searchHint: 'Pesquisar',
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
                                                                                                            color: Colors.white,
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
                                                                                  )
                                                                                : const Center(
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(8.0),
                                                                                      child: Column(
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: EdgeInsets.all(8.0),
                                                                                            child: CircularProgressIndicator(
                                                                                              color: AppTema.primaryAmarelo,
                                                                                            ),
                                                                                          ),
                                                                                          Text('Carregando...'),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                          ),
                                                                        )
                                                                      : const SizedBox(),
                                                                ],
                                                              )
                                                            : const SizedBox(),

                                                        // !! METODOLOGIA !!
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
                                                            if (value!
                                                                .isEmpty) {
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
                                                                              returnoSelcionadas:
                                                                                  selectedExperiencias,
                                                                              onSelectionChanged:
                                                                                  _handleSelectionChanged),*/

                                                        const SizedBox(
                                                            height: 16.0),
                                                        Column(
                                                          children: [
                                                            ///Text('isStatus: $isStatus'),
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
                                                                        if (_formKey.currentState!.validate() &&
                                                                            (_errorText == null ||
                                                                                _errorText == '')) {
                                                                          await atualizarAula();
                                                                        }
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            AppTema.primaryDarkBlue,
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
                                                                          color:
                                                                              Colors.white,
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
                                                                            AppTema.primaryDarkBlue,
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
                                                                        width:
                                                                            16,
                                                                        height:
                                                                            16,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2.0,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                      ],
                                                    ))
                                                  ])
                                            : const Text('')
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

  Widget _buildDisciplinaFields(
      Disciplina item, Map<String, dynamic> elemente) {
    // Initialize content from elemente
    String conteudo = elemente['conteudo'] ?? '';

    // Create TextEditingController and set the initial value
    TextEditingController conteudoController =
        TextEditingController(text: conteudo);

    // Add a listener to update the data model when the user types
    conteudoController.addListener(() {
      setState(() {
        elemente['conteudo'] =
            conteudoController.text; // Save the input back to the map
      });
    });

    return Column(
      children: [
        _buildLabel('${item.descricao.toString()}:'),
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
          validator: (value) {
            if (value!.isEmpty) {
              return validationMessage;
            }
            return null;
          },
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
        ),
      ],
    );
  }
}
