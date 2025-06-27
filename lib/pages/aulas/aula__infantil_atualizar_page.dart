import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/corrigir_data_completa_americana_para_ano_mes_dia_somente.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/data/retornar_dia_da_semana.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/gerar_uuid_identificador.dart';
import 'package:professor_acesso_notifiq/models/aula_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/models/relacao_dia_horario_model.dart';
import 'package:professor_acesso_notifiq/models/sistema_bncc_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/aula_sistema_bncc_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/aulas_offline_online_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:professor_acesso_notifiq/services/adapters/sistema_bncc_service_adapter.dart';
import 'package:professor_acesso_notifiq/functions/boxs/horarios/remover_horarios_repetidos.dart';
import '../../componentes/button/custom_calendario_infantil_button.dart';
import '../../componentes/dialogs/custom_dialogs.dart';
import '../../componentes/dialogs/custom_snackbar.dart';
import '../../componentes/dropdown/custom_dropdown_experiencia.dart';
import '../../help/data_time.dart';
import '../../services/controller/aula_controller.dart';
import '../../services/controller/tipo_aula_controller.dart';

class AulaInfantilAtualizarPage extends StatefulWidget {
  final String? aulaLocalId;
  final String? instrutorDisciplinaTurmaId;
  const AulaInfantilAtualizarPage(
      {super.key, this.aulaLocalId, this.instrutorDisciplinaTurmaId});

  @override
  State<AulaInfantilAtualizarPage> createState() =>
      _AulaInfantilAtualizarPageState();
}

class _AulaInfantilAtualizarPageState extends State<AulaInfantilAtualizarPage> {
  final TextEditingController _saberesConhecimentosController =
      TextEditingController();
  final TextEditingController _metodologiaController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  final TextEditingController _eixosTematicoController =
      TextEditingController();
  final TextEditingController _estrategiaEnsinoController =
      TextEditingController();
  final TextEditingController _recursoController = TextEditingController();
  final TextEditingController _atividadeClasseController =
      TextEditingController();
  final TextEditingController _atividadeCasaController =
      TextEditingController();
  final TextEditingController _selecioneHorario = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorText;
  // ignore: non_constant_identifier_names
  String? _aula_selecionada;
  String? _diaDaSemana;
  List<int> _horariosSelecionados = [];
  DateTime? _dataSelecionada;
  // ignore: prefer_final_fields
  Box _horariosBox = Hive.box('horarios');
  // ignore: unused_field, prefer_final_fields
  Box _gestaoAtivaBox = Hive.box('gestao_ativa');
  // ignore: non_constant_identifier_names
  List<dynamic>? horarios_data;
  bool loadingPage = true;
  bool loadingBtn = false;
  var _horario_selecionado;
  final tipoAulaController = TipoAulaController();
  // List<dynamic>? listaFiltradaDeHorarios;
  List<RelacaoDiaHorario>? listaFiltradaDeHorariosPorHorariosDaColunaDaGestao;
  List<SistemaBncc> sistemaBncc = SistemaBnccServiceAdapter().listar();
  List<SistemaBncc> sistemaBnccSelecionadosNoDropDown = [];
  List<SistemaBncc> sistemaBnccParaCamposDeExperiecia = [];
  List<int> diasParaSeremExibidosNoCalendario = [];
  GestaoAtiva? gestaoAtivaModel;
  // ignore: unused_field
  final _multiKey = GlobalKey<DropdownSearchState<SistemaBncc>>();
  // ignore: unused_field
  final bool? _popupBuilderSelection = false;
  bool statusSemanas = false;
  String inicioPeriodoEtapa = '';
  String fimPeriodoEtapa = '';
  List<String>? semanas;
  final _popupBuilderKey = GlobalKey<DropdownSearchState<SistemaBncc>>();
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

  List<String> experiencias = [
    "O eu, o outro e o nós",
    "Corpo, gestos e movimentos",
    "Escuta, fala, pensamento e imaginação",
    "Traços, sons, cores e formas",
    "Espaço, tempo, quantidades, relações e transformações",
  ];

  List<String> selectedExperiencias = [];

  // Define the callback function
  void _handleSelectionChanged(List<String> selecionadas) {
    setState(() {
      selectedExperiencias = selecionadas;
    });
  }

  @override
  void initState() {
    super.initState();
    gestaoAtivaDias();
    // getTipos();
    carregarDados(criadaPeloCelularId: widget.aulaLocalId);
    horarios_data = _horariosBox.get('horarios');
    gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
    _dataSelecionada = DateTime.now();
    // listaFiltradaDeHorarios = filtrarListaDeObjetoPorCondicaoUnica(
    //     lista_de_objetos: horarios_data!,
    //     condicao: gestao_ativa_data!['turno_id']);
    listaFiltradaDeHorariosPorHorariosDaColunaDaGestao =
        gestaoAtivaModel?.relacoesDiasHorarios;
    listaFiltradaDeHorariosPorHorariosDaColunaDaGestao
        ?.sort((a, b) => a.horario.descricao.compareTo(b.horario.descricao));
    _mostrarCalendario(null);
    _dataSelecionada =
        _ajustarDataParaDiasMaisProximoDoCampoRelacoesDiasHorarios(
            DateTime.now());
    // _diaDaSemana = retornarDiaDaSemana(
    //     dataBrasileira:
    //         DateFormat('dd/MM/yyyy').format(_dataSelecionada!).toString());
  }

  Future<void> _salvarAula() async {
    var aula = Aula(
      id: '',
      e_aula_infantil: 1,
      instrutor_id: gestaoAtivaModel?.idt_instrutor_id.toString(),
      disciplina_id: gestaoAtivaModel?.idt_disciplina_id.toString(),
      turma_id: gestaoAtivaModel?.idt_turma_id.toString(),
      tipoDeAula: _aula_selecionada.toString(),
      dataDaAula: corrigirDataCompletaAmericanaParaAnoMesDiaSomente(
          dataString: _dataSelecionada.toString()),
      horarioID: _horariosSelecionados.length == 1
          ? _horariosSelecionados[0].toString()
          : '',
      horarios_infantis: _horariosSelecionados,
      conteudo: '',
      metodologia: _metodologiaController.text.toString(),
      saberes_conhecimentos: _saberesConhecimentosController.text.toString(),
      dia_da_semana: _diaDaSemana.toString(),
      situacao: 'Aguardando confirmação',
      criadaPeloCelular: widget.aulaLocalId,
      etapa_id: '',
      instrutorDisciplinaTurma_id: gestaoAtivaModel?.idt_id.toString(),
      eixos: _eixosTematicoController.text,
      estrategias: _estrategiaEnsinoController.text,
      recursos: _recursoController.text,
      is_polivalencia: gestaoAtivaModel!.is_polivalencia ?? 0,
      atividade_casa: _atividadeCasaController.text,
      atividade_classe: _atividadeClasseController.text,
      campos_de_experiencias: selectedExperiencias.toString(),
      experiencias: selectedExperiencias.isNotEmpty ? selectedExperiencias : [],
      observacoes: _observacaoController.text,
    );

    bool status =
        await AulasOfflineOnlineServiceAdapter().salvar(novaAula: aula);
    //print('status: $status');
    await AulaSistemaBnccServiceAdapter().salvarVarios(
      sistemaBncc: sistemaBnccSelecionadosNoDropDown,
      aulaOfflineId: aula.criadaPeloCelular.toString(),
    );
    if (status != true) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: AppTema.error,
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Aula já existe para o dia ',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ));
      return;
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTema.success,
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Aula criada com sucesso',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
    // ignore: use_build_context_synchronously
    Navigator.pushNamed(context, '/home');
  }

  DateTime _ajustarDataParaDiasMaisProximoDoCampoRelacoesDiasHorarios(
      DateTime data) {
    if (diasParaSeremExibidosNoCalendario.isNotEmpty) {
      while (data.weekday != diasParaSeremExibidosNoCalendario[0]) {
        data = data.add(const Duration(days: 1));
      }
    }
    return data;
  }

  Future<void> _mostrarCalendario(BuildContext? context) async {
    // ignore: avoid_function_literals_in_foreach_calls
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
    if (_dataSelecionada != null && context != null) {
      final DateTime? dataSelecionada = await showDatePicker(
        context: context,
        initialDate: _dataSelecionada!,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        selectableDayPredicate: (DateTime day) {
          bool diaDaSemanaParaSerExibido = false;
          diasParaSeremExibidosNoCalendario
              // ignore: avoid_function_literals_in_foreach_calls
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
          _diaDaSemana = retornarDiaDaSemana(
              dataBrasileira: DateFormat('dd/MM/yyyy')
                  .format(_dataSelecionada!)
                  .toString());
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
        debugPrint("ID criadaPeloCelularId é nulo.");
        return;
      }

      List<Aula> aulas = await aulaController.getAulaCriadaPeloCelular(
          criadaPeloCelular: criadaPeloCelularId);

      if (aulas.isNotEmpty) {
        for (var aula in aulas) {
          setState(() => _dataSelecionada = DateTime.tryParse(aula.dataDaAula));
          setState(() => _diaDaSemana = aula.dia_da_semana.toString());
          // debugPrint('experiencias: $experiencias');
          carregarExperienciaSelecionada(aula.experiencias);
          carregarTipoSelecionada(aula.tipoDeAula);
          carregarDataSelecionada(aula.dataDaAula);
          carregarHorarioSelecionada(aula.horarios_infantis);
          carregarHorarioSelecionadaId(aula.horarioID);
          // Carregar outros dados gerais
          carregarDadosGeral(
            atividadeCasa: aula.atividade_casa,
            atividadeClasse: aula.atividade_classe,
            eixos: aula.eixos,
            estrategiaEnsino: aula.estrategias,
            observacao: aula.observacoes,
            recurso: aula.recursos,
          );

          // Se necessário, adicione estas funções:
          // await carregarConteudoSelecionada(aula.conteudo);
          // await carregarMetodologiaSelecionada(aula.metodologia);
        }
      } else {
        print(
            "Nenhuma aula encontrada com o ID fornecido: $criadaPeloCelularId");
      }
    } catch (e) {
      // Log de erro
      print("Erro ao carregar os dados: $e");
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

  void carregarHorarioSelecionadaId(horarioSelecionado) {
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

  void carregarHorarioSelecionada(List<int> horarioSelecionado) {
    if (horarioSelecionado.isEmpty) {
      print('Sem Horário');
      return;
    }
    _horariosSelecionados = horarioSelecionado;
    setState(() {
      _horariosSelecionados;
    });
    print('Data selecionada: $horarioSelecionado');
  }

  void carregarDadosGeral(
      {required String? eixos,
      required String? estrategiaEnsino,
      required String? recurso,
      required String atividadeCasa,
      required String atividadeClasse,
      required String? observacao}) {
    _eixosTematicoController.text = eixos.toString();
    _estrategiaEnsinoController.text = estrategiaEnsino.toString();
    _recursoController.text = recurso.toString();
    _atividadeCasaController.text = atividadeCasa.toString();
    _atividadeClasseController.text = atividadeClasse.toString();
    _observacaoController.text = observacao.toString();
    setState(() {});
  }

  Future<void> carregarExperienciaSelecionada(
      List<String> novasExperiencias) async {
    // Aguardar 3 segundos
    await Future.delayed(const Duration(seconds: 3));

    // Atualizar o estado com as novas experiências após o atraso
    setState(() {
      selectedExperiencias = novasExperiencias;
      loadingPage = false;
    });
  }

  Future<bool> atualizarAulaInfantil() async {
    setState(() {
      loadingBtn = true;
    });

    CustomDialogs.showLoadingDialog(context,
        show: true, message: 'Aguardando...');
    AulaController aulaController = AulaController();

    await aulaController.init();

    print("_diaDaSemana: $_diaDaSemana");
    Aula aulaAtualizada = Aula(
      id: '',
      e_aula_infantil: 1,
      is_polivalencia: gestaoAtivaModel!.is_polivalencia ?? 0,
      instrutor_id: gestaoAtivaModel?.idt_instrutor_id.toString(),
      disciplina_id: gestaoAtivaModel?.idt_disciplina_id.toString(),
      turma_id: gestaoAtivaModel?.idt_turma_id.toString(),
      tipoDeAula: _aula_selecionada.toString(),
      dataDaAula: corrigirDataCompletaAmericanaParaAnoMesDiaSomente(
          dataString: _dataSelecionada.toString()),
      horarioID: _horario_selecionado.toString(),
      horarios_infantis: _horariosSelecionados,
      conteudo: '',
      metodologia: _metodologiaController.text.toString(),
      saberes_conhecimentos: _saberesConhecimentosController.text.toString(),
      dia_da_semana: _diaDaSemana.toString(),
      situacao: 'Aguardando confirmação',
      criadaPeloCelular: gerarUuidIdentification().toString(),
      etapa_id: '',
      instrutorDisciplinaTurma_id: gestaoAtivaModel?.idt_id.toString(),
      eixos: _eixosTematicoController.text,
      estrategias: _estrategiaEnsinoController.text,
      recursos: _recursoController.text,
      atividade_casa: _atividadeCasaController.text,
      atividade_classe: _atividadeClasseController.text,
      campos_de_experiencias: selectedExperiencias.toString(),
      experiencias: selectedExperiencias.isNotEmpty ? selectedExperiencias : [],
      observacoes: _observacaoController.text,
    );

    await aulaController.updateAulaCriadaPeloCelular(
      criadaPeloCelular: widget.aulaLocalId,
      aulaAtualizada: aulaAtualizada,
    );

    await Future.delayed(const Duration(seconds: 3));

    CustomDialogs.showLoadingDialog(context, show: false);
    CustomSnackBar.showSuccessSnackBar(context, 'Aula atualizada com sucesso!');

    setState(() {
      loadingBtn = false;
    });
    Navigator.pushNamed(context, '/index-infantil');

    // Navigator.pop(context);
    // Navigator.pop(context);
    return true;
  }

  Future<void> gestaoAtivaDias() async {
    try {
      setState(() => statusSemanas = true);
      List<GestaoAtiva> gestaoAtivaList =
          _gestaoAtivaBox.values.whereType<GestaoAtiva>().toList();

      gestaoAtivaList.addAll(
        _gestaoAtivaBox.values
            .whereType<Map>()
            .map((value) => GestaoAtiva.fromMap(value))
            .toList(),
      );

      if (gestaoAtivaList.isNotEmpty) {
        semanas = await gestaoAtivaList.first.getRelacoesDia();
        setState(() {
          statusSemanas = false;
          semanas;
        });
        return;
      }
      print('Nenhuma instância de GestaoAtiva encontrada no _gestaoAtivaBox.');

      print('gestao: $gestaoAtivaList');
      setState(() => statusSemanas = false);
    } catch (e) {
      setState(() => statusSemanas = false);
      print('Erro ao processar gestaoAtivaDias: $e');
    }
  }

  Future<void> getTipos() async {
    await tipoAulaController.init();
    tipos = await tipoAulaController.getDescricaoAll();
    setState(() => tipos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        title: const Text('Atualizar aula infantil'),
        iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: loadingPage != false
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTema.primaryAmarelo,
              ),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: AppTema.primaryWhite,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: const Text(
                                  'Tipo de aula',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                              InputDecorator(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppTema.backgroundColorApp,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _aula_selecionada,
                                    onChanged: (String? novaSelecao) {
                                      setState(() {
                                        _aula_selecionada = novaSelecao;
                                      });
                                    },
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 8, 8, 8),
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black,
                                    ),
                                    items: tipos.map<DropdownMenuItem<String>>(
                                      (String opcao) {
                                        return DropdownMenuItem<String>(
                                          value: opcao,
                                          child: Text(opcao),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),

                              Text(
                                _errorText ?? '',
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(
                                height: 0.0,
                              ),

                              // !! SELECIONAR A DATA !!
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: const Text(
                                  'Selecione uma data',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                              Column(
                                children: [
                                  statusSemanas != true
                                      ? CustomCalendarioInfantilButton(
                                          initialDate: _dataSelecionada,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                          semanas: semanas!,
                                          onDateSelected: (selectedDate) {
                                            _diaDaSemana = DataTime.diaDaSemana(
                                                selectedDate.toString());
                                            setState(() {
                                              _diaDaSemana;
                                              _dataSelecionada =
                                                  selectedDate.toLocal();
                                            });
                                          },
                                        )
                                      : const SizedBox(),
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     border: Border.all(
                                  //         color: Colors.black, width: 1.0),
                                  //     borderRadius: BorderRadius.circular(8.0),
                                  //   ),
                                  //   child: SizedBox(
                                  //     width: double.infinity,
                                  //     height: 45,
                                  //     child: ElevatedButton(
                                  //       style: ButtonStyle(
                                  //         backgroundColor:  WidgetStateProperty.all(AppTema.primaryWhite),
                                  //         elevation: WidgetStateProperty.all(0.0),
                                  //         shape: WidgetStateProperty.all(
                                  //           RoundedRectangleBorder(
                                  //             borderRadius:
                                  //                 BorderRadius.circular(8.0),
                                  //             side: BorderSide.none,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       onPressed: () {
                                  //         _mostrarCalendario(context);
                                  //       },
                                  //       child: Align(
                                  //         alignment: Alignment.centerLeft,
                                  //         child: Row(
                                  //           mainAxisAlignment:
                                  //               MainAxisAlignment.spaceBetween,
                                  //           children: [
                                  //             Text(
                                  //               // ignore: unnecessary_string_interpolations
                                  //               '${DateFormat('dd/MM/yyyy').format(_dataSelecionada!)}',
                                  //               style: const TextStyle(
                                  //                 color: Colors.black,
                                  //                 fontWeight: FontWeight.normal,
                                  //               ),
                                  //               textAlign: TextAlign.start,
                                  //             ),
                                  //             const Icon(Icons.arrow_drop_down, color: Colors.black,),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),

                                  const SizedBox(height: 16),

                                  // !! DIA DA SEMANA !!
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: const Text(
                                        'Dia da semana',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Card(
                                      color: AppTema.backgroundColorApp,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 5, 10, 5),
                                        child: Text(
                                          _diaDaSemana.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // !! SELECIONAR UM HORÁRIO !!
                                  _aula_selecionada != 'Aula Remota'
                                      ? Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            child: const Text(
                                              'Selecione um horário',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                  _aula_selecionada != 'Aula Remota'
                                      ? Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                8.0), // Adding rounded corners
                                            border: Border.all(
                                              color: Colors
                                                  .grey, // Custom border color
                                              width: 1.0, // Custom border width
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              DropdownButtonFormField<int>(
                                                value: _horario_selecionado,
                                                dropdownColor:
                                                    AppTema.primaryWhite,
                                                onChanged: (var novaSelecao) =>
                                                    setState(() =>
                                                        _horario_selecionado =
                                                            novaSelecao),
                                                focusColor: Colors.black,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: AppTema
                                                      .backgroundColorApp,
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black,
                                                        width: 1.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.black,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.black,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16.0),
                                                ),
                                                icon: const Icon(
                                                  Icons
                                                      .arrow_drop_down, // Ícone da seta
                                                  color: Colors
                                                      .black, // Cor do ícone da seta
                                                ),
                                                items: removeHorariosRepetidos(
                                                        listaOriginal:
                                                            listaFiltradaDeHorariosPorHorariosDaColunaDaGestao!)!
                                                    .map<DropdownMenuItem<int>>(
                                                        (objeto) {
                                                  return DropdownMenuItem<int>(
                                                    value: int.parse(
                                                        objeto.horario.id),
                                                    child: Text(objeto
                                                        .horario.descricao),
                                                  );
                                                }).toList(),
                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Por favor, selecione um horário';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                      : const Text(''),

                                  // !! SABERES E CONHECIMENTOS!!

                                  /*Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 10, top: 15),
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Saberes e Conhecimentos',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  )),
                              TextFormField(
                                controller: _saberesConhecimentosController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor, preencha o conteúdo';
                                  }
                                  return null;
                                },
                                maxLines:
                                    8, // Define o número máximo de linhas que o campo de texto pode ter
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.grey), // Define a cor da borda ao clicar
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical:
                                          5), // Ajusta a altura vertical do campo de texto
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),*/

                                  // !! METODOLOGIA !!
                                  /*Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 10, top: 15),
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Estratégia Didática (Metodologia)',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  ),),
                              TextFormField(
                                controller: _metodologiaController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor, preencha a metodologia';
                                  }
                                  return null;
                                },
                                maxLines: 8,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),*/
                                  const SizedBox(height: 16.0),
                                  Container(
                                    margin: const EdgeInsets.only(
                                      bottom: 10,
                                      top: 15,
                                    ),
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Eixos temáticos',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _eixosTematicoController,
                                    maxLines: 8,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'O campo eixos temáticos é obrigatório';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppTema.backgroundColorApp,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10, top: 15),
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Estratégias de ensino',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _estrategiaEnsinoController,
                                    maxLines: 8,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'O campo estratégias de ensino é obrigatório';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppTema.backgroundColorApp,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10, top: 15),
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Recursos',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _recursoController,
                                    maxLines: 8,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'O campo recursos é obrigatório';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppTema.backgroundColorApp,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10, top: 15),
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Atividade de classe',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _atividadeClasseController,
                                    maxLines: 8,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'O campo atividade de classe é obrigatório';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppTema.backgroundColorApp,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10, top: 15),
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Atividade de casa',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _atividadeCasaController,
                                    maxLines: 8,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppTema.backgroundColorApp,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10, top: 15),
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Observações',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _observacaoController,
                                    maxLines: 8,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppTema.backgroundColorApp,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  /*const SizedBox(height: 16.0),
                              // !! METODOLOGIA !!sds
                              Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 10, top: 15),
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Objetivos de Aprendizagem e Desenv.',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  ),),
                              DropdownSearch<SistemaBncc>.multiSelection(
                                onChanged: (value) {
                                  if (value.length !=
                                      sistemaBnccSelecionadosNoDropDown.length) {
                                    sistemaBnccSelecionadosNoDropDown = value;
                                    setState(() {
                                      sistemaBnccParaCamposDeExperiecia =
                                          sistemaBnccSelecionadosNoDropDown;
                                    });
                                  }
                                },
                                key: _multiKey,
                                items: sistemaBncc
                                    .where((sistema) => sistema.parent_id != '')
                                    .toList(),
                                itemAsString: (item) =>
                                    '[${item.apelido.toUpperCase()}] \n\n${retornarTextoComPrimeiraLetraMaiscula(texto: item.descricao)}\n__________________________',
                                popupProps: PopupPropsMultiSelection.dialog(
                                  onItemAdded: (l, s) {
                                    sistemaBnccSelecionadosNoDropDown = l;
                                    SistemaBncc? bnccAdicionando =
                                        sistemaBncc.firstWhereOrNull((sistema) =>
                                            sistema.id.toString() ==
                                            s.parent_id.toString());
                        
                                    if (bnccAdicionando != null) {
                                      setState(() {
                                        sistemaBnccParaCamposDeExperiecia
                                            .add(bnccAdicionando);
                                      });
                                    }
                        
                                    _handleCheckBoxState();
                                  },
                                  onItemRemoved: (l, s) {
                                    sistemaBnccSelecionadosNoDropDown = l;
                        
                                    if (sistemaBnccParaCamposDeExperiecia
                                            .length >=
                                        1) {
                                      int index =
                                          sistemaBnccParaCamposDeExperiecia
                                              .indexWhere((sistema) =>
                                                  sistema.id.toString() ==
                                                  s.parent_id.toString());
                                      setState(() {
                                        sistemaBnccParaCamposDeExperiecia
                                            .removeAt(index);
                                      });
                                    }
                        
                                    _handleCheckBoxState();
                                  },
                                  showSearchBox: true,
                                  itemBuilder: (context, item, isSelected) {
                                    return Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color.fromARGB(
                                                255, 133, 131, 131),
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '[${item.apelido.toUpperCase()}] \n\n${retornarTextoComPrimeiraLetraMaiscula(texto: item.descricao)}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 11, 11, 11)),
                                            ),
                                          ),
                                          const Padding(
                                              padding: EdgeInsets.only(left: 8)),
                                          isSelected
                                              ? const Icon(
                                                  Icons.check_box_outlined)
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    );
                                  },
                                   
                        
                                  containerBuilder: (ctx, popupWidget) {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.all(3),
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  // How should I unselect all items in the list?
                                                  _multiKey.currentState
                                                      ?.closeDropDownSearch();
                                                },
                                                child: const Text(
                                                    'Cancelar'),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.all(3),
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  // How should I select all items in the list?
                                                  _multiKey.currentState
                                                      ?.popupSelectAllItems();
                                                },
                                                child:
                                                    const Text('Todos'),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.all(3),
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  // How should I unselect all items in the list?
                                                  _multiKey.currentState
                                                      ?.popupDeselectAllItems();
                                                },
                                                child: const Text(
                                                    'Limpar'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(child: popupWidget),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Text('sistemaBncc: $sistemaBnccParaCamposDeExperiecia'),*/
                                  // !! Campos de Experiência !!
                                  Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10, top: 15),
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Campos de experiencias',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),

                                  CustomDropdownExperiencia(
                                    onSelectionChanged: _handleSelectionChanged,
                                    returnoSelcionadas: selectedExperiencias,
                                  ),
                                  /*sistemaBnccParaCamposDeExperiecia.length > 0
                                  ? Container(
                                      height: MediaQuery.sizeOf(context).width *
                                          (sistemaBnccParaCamposDeExperiecia
                                                  .length /
                                              10),
                                      child: Align(
                                        child: ListView.builder(
                                          itemCount:
                                              sistemaBnccParaCamposDeExperiecia
                                                  .length,
                                          itemBuilder: (BuildContext context,
                                              int indexSistemaBnncSelecionado) {
                                            SistemaBncc? sistemaBnncDoIndexAtual =
                                                sistemaBnccParaCamposDeExperiecia[
                                                    indexSistemaBnncSelecionado];
                        
                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Card(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Text(
                                                    sistemaBnncDoIndexAtual
                                                            .descricao
                                                            .toString() ??
                                                        "Item não encontrado",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  )
                                                  // Exibe uma mensagem de erro quando o item não é encontrado
                                                  ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : const SizedBox(
                                      width: double.infinity,
                                      child: Card(
                                        child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text('Não preenchido')),
                                      ),
                                    ),*/
                                  const SizedBox(height: 16.0),
                                  Column(
                                    children: [
                                      loadingBtn != true
                                          ? SizedBox(
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
                                                    await atualizarAulaInfantil();
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppTema.primaryDarkBlue,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 24.0,
                                                      vertical: 12.0),
                                                  shape: RoundedRectangleBorder(
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
                                          : SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  return;
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppTema.primaryDarkBlue,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 28.0,
                                                      vertical: 2.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                                child: const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ],
                                  )
                                ],
                              )
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
}
