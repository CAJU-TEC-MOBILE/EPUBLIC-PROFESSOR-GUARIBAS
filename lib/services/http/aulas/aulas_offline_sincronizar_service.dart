import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/verificar_conexao_com_internet.dart';
import 'package:professor_acesso_notifiq/models/aula_model.dart';
import 'package:professor_acesso_notifiq/models/aula_sistema_bncc_model.dart';
import 'package:professor_acesso_notifiq/models/faltas_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/pages/login_page.dart';
import 'package:professor_acesso_notifiq/services/adapters/aula_sistema_bncc_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/aulas_offline_online_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/faltas_offlines_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'dart:convert';
import 'package:professor_acesso_notifiq/services/widgets/snackbar_service_widget.dart';
import '../../../componentes/dialogs/custom_snackbar.dart';
import '../../../componentes/global/preloader.dart';
import '../../../models/historico_requencia_model.dart';
import '../../../models/matricula_model.dart';
import '../../../models/serie_model.dart';
import '../../adapters/gestao_ativa_service_adapter.dart';
import '../../controller/aula_controller.dart';
import '../../controller/disciplina_aula_controller.dart';
import '../../controller/historico_requencia_controller.dart';
import '../../controller/serie_aula_controller.dart';
import '../../faltas/falta_controller.dart';
import '../../shared_preference_service.dart';
import '../faltas/faltas_da_aula_online_enviar_http.dart';

class AulasOfflineSincronizarService {
  final preference = SharedPreferenceService();
  static const String _prefix_url = 'notifiq-professor/aulas/sincronizar-aula';
  Box authBox = Hive.box('auth');
  Future<Map<dynamic, dynamic>?> _getAuthData() async {
    return authBox.get('auth');
  }

  Future<dynamic> executar(BuildContext context, Aula aula,
      List<String> experiencias, List<Serie> seriesSelecionadas) async {
    final url = '${ApiBaseURLService.baseUrl}/$_prefix_url';
    GestaoAtiva? gestaoAtivaModel;
    gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
    Map<dynamic, dynamic>? authData = await _getAuthData();
    List<Falta> faltasDaAula = await FaltasOfflinesServiceAdapter()
        .listarFaltasDeAulaEspecifica(
            criadaPeloCelular: aula.criadaPeloCelular.toString());
    DisciplinaAulaController disciplinaAulaController =
        DisciplinaAulaController();
    SerieAulaController serieAulaController = SerieAulaController();
    AulaController aulaController = AulaController();
    await aulaController.init();
    await disciplinaAulaController.init();
    await serieAulaController.init();
    List<Map<String, dynamic>> horariosExtras = [];
    List<Map<String, dynamic>> seriesExtras = [];
    List<String> conteudoPolivalencia = [];
    List<String> disciplinas = [];
    List<int> series = [];
    print(
        "-----------------FALTAS DA AULA A SER SINCRONIZADA----------------------");
    dynamic isConnected = await checkInternetConnection();
    if (isConnected) {
      List<Map<String, dynamic>> faltasDaAulaJson =
          faltasDaAula.map((falta) => falta.toMap()).toList();
      List<AulaSistemaBncc> aulaSitemaBnnccDessaAula =
          await AulaSistemaBnccServiceAdapter()
              .listarDeAulaEspecifica(aulaOfflineId: aula.criadaPeloCelular);
      List<Map<String, dynamic>> aulaSitemaBnnccDessaAulaJson =
          aulaSitemaBnnccDessaAula.map((sistema) => sistema.toMap()).toList();
      if (experiencias.isEmpty) {
        debugPrint("Nenhuma experiência encontrada.");
      }
      print('disciplinas: $disciplinas');
      print('disciplina_id: ${aula.disciplina_id.toString()}');
      print('e_aula_infantil: ${aula.e_aula_infantil.toString()}');
      print(
          'instrutorDisciplinaTurma_id: ${aula.instrutorDisciplinaTurma_id.toString()}');
      print('aula.horarioID: ${validateNull(aula.horarioID)}');
      print('horarios_infantis: ${jsonEncode(aula.horarios_infantis)}');
      print(
          'campos_de_experiencias: ${(aula.campos_de_experiencias.toString())}');
      if (aula.is_polivalencia == 1) {
        horariosExtras = await disciplinaAulaController.getHorariosExtras(
          criadaPeloCelular: aula.criadaPeloCelular,
        );
        conteudoPolivalencia =
            await disciplinaAulaController.getConteudoPolivalencia(
          criadaPeloCelular: aula.criadaPeloCelular,
        );
        disciplinas = await disciplinaAulaController.getDisciplinas(
          criadaPeloCelular: aula.criadaPeloCelular,
        );
      }
      if (gestaoAtivaModel!.multi_etapa == 1) {
        series = await aulaController.getAulaSeries(
          criadaPeloCelular: aula.criadaPeloCelular,
        );
      }
      if (gestaoAtivaModel.multi_etapa == 1 &&
          gestaoAtivaModel.is_polivalencia == 1) {
        seriesExtras = await serieAulaController.getSeriesExtras(
          criadaPeloCelular: aula.criadaPeloCelular,
        );
      }
      print('series: $series');
      print('=======================');
      print('tipoDeAula: ${aula.tipoDeAula.toString()}');
      print('is_polivalencia: ${aula.is_polivalencia}');
      print('conteudoPolivalencia: $conteudoPolivalencia');
      print('horariosExtras: $horariosExtras');
      print('disciplinas: $disciplinas');
      print('=======================');
      await preference.init();
      String? token = await preference.getToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: {
          'instrutorDisciplinaTurma_id': aula.instrutorDisciplinaTurma_id,
          'instrutor_id': aula.instrutor_id,
          'disciplina_id': aula.disciplina_id,
          'turma_id': aula.turma_id,
          'e_aula_infantil': jsonEncode(aula.e_aula_infantil),
          'horarios': aula.horarios_infantis.toString(),
          'horario_id': aula.horarioID,
          'is_polivalencia': jsonEncode(aula.is_polivalencia),
          'horario_inicial': '00:00:00',
          'horario_final': '00:00:00',
          'series': series.isNotEmpty ? jsonEncode(series) : jsonEncode([]),
          'horarios_infantis': aula.horarios_infantis.isNotEmpty
              ? aula.horarios_infantis.toString()
              : jsonEncode([]),
          'situacao': aula.situacao,
          'data': aula.dataDaAula,
          'conteudo': aula.conteudo,
          'tipo_de_aula': aula.tipoDeAula,
          'metodologia': aula.metodologia,
          'saberes_conhecimentos': aula.saberes_conhecimentos,
          'dia_da_semana': aula.dia_da_semana,
          'criadaPeloCelular': aula.criadaPeloCelular,
          'etapa_id': aula.etapa_id,
          'faltas_da_aula': jsonEncode(faltasDaAulaJson),
          'idt_id': aula.instrutorDisciplinaTurma_id,
          'is_mobile': '1',
          'aula_sistema_bncc_salvas_no_dispotivo':
              jsonEncode(aulaSitemaBnnccDessaAulaJson),
          'eixos': aula.eixos,
          'estrategias': aula.estrategias,
          'recursos': aula.recursos,
          'atividade_casa': aula.atividade_casa,
          'atividade_classe': aula.atividade_classe,
          'observacoes': aula.observacoes,
          'campos_de_experiencias': jsonEncode(experiencias),
          'conteudo_polivalencia': conteudoPolivalencia.isNotEmpty
              ? jsonEncode(conteudoPolivalencia)
              : '',
          'disciplinas':
              disciplinas.isNotEmpty ? disciplinas.toString() : jsonEncode([]),
          'horarios_extras': horariosExtras.isNotEmpty
              ? jsonEncode(horariosExtras)
              : jsonEncode(null),
          'series_extras': seriesExtras.isNotEmpty
              ? jsonEncode(seriesExtras)
              : jsonEncode(null)
        },
      );
      try {
        if (response.statusCode == 200) {
          final decodedResponse = jsonDecode(response.body);
          String aulaId = decodedResponse["aula_id"].toString();
          await envioDeAnexo(
            context: context,
            criadaPeloCelular: aula.criadaPeloCelular.toString(),
            aulaId: aulaId,
          );
          await envioDeSemAnexo(
            context: context,
            criadaPeloCelular: aula.criadaPeloCelular.toString(),
            aulaId: aulaId,
          );
          await AulasOfflineOnlineServiceAdapter().remover(aula);
          await FaltasOfflinesServiceAdapter()
              .removerFaltasSincronizadas(faltasDaAula);
          await AulaSistemaBnccServiceAdapter().deletarDeAulaEspecifica(
            aulaOfflineID: aula.criadaPeloCelular,
          );
          Future.microtask(() {
            CustomSnackBar.showSuccessSnackBar(
              context,
              'Sincronização realizada com sucesso!',
            );
          });
        } else if (response.statusCode == 401) {
          hideLoading(context);
          Future.microtask(() {
            CustomSnackBar.showErrorSnackBar(
              context,
              'Conexão expirada.',
            );
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
          });
        } else if (response.statusCode == 409) {
          Future.microtask(() {
            CustomSnackBar.showInfoSnackBar(
              context,
              'Aula conflitada.',
            );
          });
        } else {
          Future.microtask(() {
            CustomSnackBar.showErrorSnackBar(
              context,
              'Erro de conexão.',
            );
          });
        }
      } catch (error) {
        Future.microtask(() {
          CustomSnackBar.showErrorSnackBar(
            context,
            'Erro de conexão.',
          );
        });
      }
    } else {
      Future.microtask(() {
        CustomSnackBar.showErrorSnackBar(
          context,
          'Erro de conexão.',
        );
      });
    }
    Navigator.of(context).pop();
  }

  Future<List<String>> getExperiencias(
      {required String? criadaPeloCelularId}) async {
    if (criadaPeloCelularId == null) {
      debugPrint("ID criadaPeloCelularId é nulo.");
      return [];
    }
    AulaController aulaController = AulaController();
    List<Aula> aulas = await aulaController.getAulaCriadaPeloCelular(
        criadaPeloCelular: criadaPeloCelularId);
    if (aulas.isEmpty) {
      return [];
    }
    Set<String> experienciasSet = {};
    for (var aula in aulas) {
      experienciasSet.addAll(aula.experiencias);
    }
    return experienciasSet.toList();
  }

  dynamic validateNull(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return value.trim().isEmpty || value == 'null' ? null : value;
    }
    if (value is int) {
      return value == 0 ? null : value;
    }
    return value;
  }

  Future<void> envioDeAnexo({
    required BuildContext context,
    required String? criadaPeloCelular,
    required String aulaId,
  }) async {
    if (criadaPeloCelular == null || aulaId.isEmpty) {
      debugPrint(
          "Parâmetros inválidos. Criação pelo celular e aulaId são obrigatórios.");
      return;
    }
    try {
      final historicoPresencaController = HistoricoPresencaController();
      final faltas = FaltasDaAulaOnlineEnviarHttp();
      final faltaController = FaltaController();
      await historicoPresencaController.init();
      final dados = await historicoPresencaController
          .getHistoricoPresencaPeloCriadaPeloCelular(criadaPeloCelular);
      final List<Future> envioTasks = [];
      if (dados.isEmpty) {
        print(
            "Nenhum dado encontrado para a criadaPeloCelular: $criadaPeloCelular");
        return;
      }
      for (HistoricoPresenca item in dados) {
        if (item.anexo != null) {
          File aulaFile = File(item.anexo.toString());
          final envioTask = faltas.setJustificarFalta(
            context: context,
            matriculaId: item.id.toString(),
            aulaId: aulaId,
            observacao: '',
            justificativaId: item.justificativaId.toString(),
            files: [aulaFile],
          ).then((result) {
            print('Envio de arquivo com sucesso: $result');
          }).catchError((e) {
            print('Erro ao enviar arquivo para o item ${item.id}: $e');
          });
          envioTasks.add(envioTask);
        }
      }
      await Future.wait(envioTasks);
      print('Todos os arquivos foram enviados com sucesso.');
    } catch (e) {
      print('Erro no envio de anexo: $e');
    }
  }

  Future<void> envioDeSemAnexo({
    required BuildContext context,
    required String? criadaPeloCelular,
    required String aulaId,
  }) async {
    if (criadaPeloCelular == null || aulaId.isEmpty) {
      debugPrint(
          "Parâmetros inválidos. Criação pelo celular e aulaId são obrigatórios.");
      return;
    }
    try {
      final historicoPresencaController = HistoricoPresencaController();
      final faltas = FaltasDaAulaOnlineEnviarHttp();
      final faltaController = FaltaController();
      await historicoPresencaController.init();
      final List<Future> envioTasks = [];
      print(
          "Nenhum dado encontrado para a criadaPeloCelular: $criadaPeloCelular");
      List<Matricula> matriculas =
          await faltaController.getFaltaPorAulaId(aula_id: aulaId);
      for (Matricula matricula in matriculas) {
        final envioTask = faltas
            .setJustificarFalta(
          context: context,
          matriculaId: matricula.matricula_id.toString(),
          aulaId: aulaId,
          observacao: '',
          files: [],
          justificativaId: matricula.justificativa_id.toString(),
        )
            .then((result) {
          print('Envio de arquivo com sucesso: $result');
        }).catchError((e) {
          print('Erro ao enviar arquivo para o item $e');
        });
        envioTasks.add(envioTask);
      }
      await Future.wait(envioTasks);
      print('Todos os arquivos foram enviados com sucesso.');
    } catch (e) {
      print('Erro no envio de anexo: $e');
    }
  }
}
