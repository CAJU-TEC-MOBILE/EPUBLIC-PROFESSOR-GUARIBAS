import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/corrigir_data_completa_americana_para_ano_mes_dia_somente.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/data/retornar_dia_da_semana.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/gerar_uuid_identificador.dart';
import 'package:professor_acesso_notifiq/help/console_log.dart';
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
import '../../componentes/button/custom_calendario_button.dart';
import '../../componentes/button/custom_calendario_infantil_button.dart';
import '../../componentes/dialogs/custom_snackbar.dart';
import '../../componentes/dropdown/custom_dropdown_experiencia.dart';
import '../../services/controller/tipo_aula_controller.dart';

class CriarAulaInfantilPage extends StatefulWidget {
  const CriarAulaInfantilPage({super.key});

  @override
  State<CriarAulaInfantilPage> createState() => _CriarAulaInfantilPageState();
}

class _CriarAulaInfantilPageState extends State<CriarAulaInfantilPage> {
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
  final tipoAulaController = TipoAulaController();
  double sizedBoxHeight = 4.0;
  // ignore: non_constant_identifier_names
  String? _aula_selecionada;
  bool statusSemanas = false;
  String? _diaDaSemana;
  final List<int> _horariosSelecionados = [];
  DateTime? _dataSelecionada;
  // ignore: prefer_final_fields
  Box _horariosBox = Hive.box('horarios');
  // ignore: unused_field, prefer_final_fields
  Box _gestaoAtivaBox = Hive.box('gestao_ativa');
  // ignore: non_constant_identifier_names
  List<dynamic>? horarios_data;
  // List<dynamic>? listaFiltradaDeHorarios;
  List<RelacaoDiaHorario>? listaFiltradaDeHorariosPorHorariosDaColunaDaGestao;
  List<SistemaBncc> sistemaBncc = SistemaBnccServiceAdapter().listar();
  List<SistemaBncc> sistemaBnccSelecionadosNoDropDown = [];
  List<SistemaBncc> sistemaBnccParaCamposDeExperiecia = [];
  List<int> diasParaSeremExibidosNoCalendario = [];
  GestaoAtiva? gestaoAtivaModel;
  String inicioPeriodoEtapa = '';
  String fimPeriodoEtapa = '';
  List<String>? semanas;

  // ignore: unused_field
  final _multiKey = GlobalKey<DropdownSearchState<SistemaBncc>>();
  // ignore: unused_field
  bool? _popupBuilderSelection = false;
  final _popupBuilderKey = GlobalKey<DropdownSearchState<SistemaBncc>>();
  var _horario_selecionado;
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
  List<String> selectedExperiencias = [];

  void _handleSelectionChanged(List<String> selecionadas) {
    setState(() {
      selectedExperiencias = selecionadas;
    });
  }

  @override
  void initState() {
    super.initState();
    // getTipos();
    gestaoAtivaDias();
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
      //horarioID: _horariosSelecionados.length == 1 ? _horariosSelecionados[0].toString() : '',
      horarioID: _horario_selecionado.toString(),
      horarios_infantis: _horariosSelecionados,
      conteudo: '',
      metodologia: _metodologiaController.text.toString(),
      saberes_conhecimentos: _saberesConhecimentosController.text.toString(),
      dia_da_semana: _diaDaSemana.toString(),
      situacao: 'Aguardando confirmação',
      criadaPeloCelular: gerarUuidIdentification().toString(),
      etapa_id: '',
      is_polivalencia: gestaoAtivaModel!.is_polivalencia ?? 0,
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

    bool status =
        await AulasOfflineOnlineServiceAdapter().salvar(novaAula: aula);
    //print('status: $status');
    await AulaSistemaBnccServiceAdapter().salvarVarios(
      sistemaBncc: sistemaBnccSelecionadosNoDropDown,
      aulaOfflineId: aula.criadaPeloCelular.toString(),
    );
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
    //  ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     backgroundColor: AppTema.success,
    //     content: Row(
    //       children: [
    //         Icon(
    //           Icons.check_circle,
    //           color: Colors.white,
    //         ),
    //         SizedBox(width: 8),
    //         Text(
    //           'Aula criada com sucesso',
    //           style: TextStyle(
    //             color: Colors.white,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    // ignore: use_build_context_synchronously
    Navigator.pushNamed(context, '/index-infantil');
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
    try {
      await tipoAulaController.init();
      tipos = await tipoAulaController.getDescricaoAll();
      setState(() => tipos);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'get-tipos',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  void handleCheckBoxState({bool updateState = true}) {
    var selectedItem =
        _popupBuilderKey.currentState?.popupGetSelectedItems ?? [];
    var isAllSelected =
        _popupBuilderKey.currentState?.popupIsAllItemSelected ?? false;
    _popupBuilderSelection =
        selectedItem.isEmpty ? false : (isAllSelected ? true : null);

    if (updateState) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    handleCheckBoxState(updateState: false);
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        title: const Text('Criar aula infantil'),
        iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        InputDecorator(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppTema.backgroundColorApp,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: AppTema.backgroundColorApp,
                                width: 1.0,
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
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
                              dropdownColor: AppTema.primaryWhite,
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
                        SizedBox(
                          height: sizedBoxHeight,
                        ),

                        // !! SELECIONAR A DATA !!
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: const Text(
                            'Selecione uma data',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        Column(
                          children: [
                            statusSemanas != true
                                ? CustomCalendarioInfantilButton(
                                    //initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    semanas: semanas!,
                                    onDiaSelected: (String diaSemana) =>
                                        setState(
                                            () => _diaDaSemana = diaSemana),
                                    onDateSelected: (selectedDate) {
                                      setState(() => _dataSelecionada =
                                          selectedDate.toLocal());
                                    },
                                  )
                                : const SizedBox(),

                            // Container(
                            //   decoration: BoxDecoration(
                            //     border:
                            //         Border.all(color: Colors.black, width: 1.0),
                            //     borderRadius: BorderRadius.circular(8.0),
                            //   ),
                            //   child: SizedBox(
                            //     width: double.infinity,
                            //     height: 45,
                            //     child: ElevatedButton(
                            //       style: ButtonStyle(
                            //         backgroundColor: WidgetStateProperty.all(
                            //             Colors.grey[300]),
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
                            //             const Icon(Icons.arrow_drop_down),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),

                            _diaDaSemana != null
                                ? Column(
                                    children: [
                                      const SizedBox(
                                        height: 16.0,
                                      ),
                                      // // !! DIA DA SEMANA !!
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          child: const Text(
                                            'Dia da semana',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
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
                                    ],
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 16),

                            // !! SELECIONAR UM HORÁRIO !!

                            _aula_selecionada != 'Aula Remota'
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: const Text(
                                        'Selecione um horário',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ))
                                : const SizedBox(),
                            _aula_selecionada != 'Aula Remota'
                                ? Column(
                                    children: [
                                      DropdownButtonFormField<int>(
                                        value: _horario_selecionado,
                                        dropdownColor: AppTema.primaryWhite,
                                        onChanged: (novaSelecao) {
                                          setState(() {
                                            _horario_selecionado = novaSelecao;
                                          });
                                        },
                                        focusColor: Colors.black,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: AppTema.backgroundColorApp,
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                              width: 1.0,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                              width: 1.0,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16.0),
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                        ),
                                        items: removeHorariosRepetidos(
                                          listaOriginal:
                                              listaFiltradaDeHorariosPorHorariosDaColunaDaGestao!,
                                        )!
                                            .map<DropdownMenuItem<int>>(
                                                (objeto) {
                                          return DropdownMenuItem<int>(
                                            value: int.parse(objeto.horario.id),
                                            child:
                                                Text(objeto.horario.descricao),
                                          );
                                        }).toList(),
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Por favor, selecione um horário';
                                          }
                                          return null;
                                        },
                                      )
                                    ],
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 0.0),
                            Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 15),
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Eixos temáticos',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
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
                                fillColor: AppTema.backgroundColorApp,
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 0.0),
                            Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 15),
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Estratégias de ensino',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
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
                                fillColor: AppTema.backgroundColorApp,
                                filled: true,
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
                            ),
                            const SizedBox(height: 0.0),
                            Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 15),
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
                                fillColor: AppTema.backgroundColorApp,
                                filled: true,
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
                            ),
                            const SizedBox(height: 0.0),
                            Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 15),
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
                                fillColor: AppTema.backgroundColorApp,
                                filled: true,
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
                            ),
                            const SizedBox(height: 0.0),
                            Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 15),
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
                                fillColor: AppTema.backgroundColorApp,
                                filled: true,
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
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 15),
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
                                fillColor: AppTema.backgroundColorApp,
                                filled: true,
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

                            Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 15),
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
                                onSelectionChanged: _handleSelectionChanged),
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () async {
                                  _validateDropdown(_aula_selecionada);
                                  if (_formKey.currentState!.validate() &&
                                      (_errorText == null ||
                                          _errorText == '')) {
                                    await _salvarAula();
                                  }
                                },
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
