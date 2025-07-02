import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/componentes/global/preloader.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/pages/login_page.dart';
import 'package:professor_acesso_notifiq/services/adapters/matriculas_service_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/http/gestoes/gestoes_listar_com_outros_dados_http.dart';
import 'dart:convert';
import 'dart:async';

import 'package:professor_acesso_notifiq/services/widgets/snackbar_service_widget.dart';

import '../../componentes/dialogs/custom_snackbar.dart';
import '../../enums/status_console.dart';
import '../../helpers/console_log.dart';
import '../../models/disciplina_model.dart';
import '../connectivity/internet_connectivity_service.dart';
import '../controller/disciplina_controller.dart';
import '../controller/horario_configuracao_controller.dart';

class GestoesService {
  Future<void> atualizarGestoes(BuildContext context) async {
    GestoesListarComOutrosDadosHttp apiService =
        GestoesListarComOutrosDadosHttp();

    bool isConnected = await InternetConnectivityService.isConnected();

    http.Response response = await apiService.todasAsGestoes();

    if (!isConnected) {
      Future.microtask(() {
        CustomSnackBar.showErrorSnackBar(
          context,
          'Erro ao estabelecer a conexão. Verifique sua conexão com a internet.',
        );
      });
      return;
    }

    try {
      if (response.statusCode == 200) {
        final disciplinaController = DisciplinaController();
        final horarioConfiguracaoController = HorarioConfiguracaoController();

        await disciplinaController.init();
        await horarioConfiguracaoController.init();

        await disciplinaController.clear();
        await horarioConfiguracaoController.clear();

        final Map<String, dynamic> responseJson =
            await jsonDecode(response.body);

        await horarioConfiguracaoController
            .addHorarioConfiguracoes(responseJson['horarios_configuracao']);

        final List<dynamic> gestoesAPI = responseJson['gestoes'];
        for (var gestaoList in gestoesAPI) {
          for (var item in gestaoList) {
            if (item['disciplinas'] != null) {
              for (var disciplina in item['disciplinas']) {
                final itemDisciplina = Disciplina(
                  id: disciplina['id'].toString(),
                  idtTurmaId: disciplina['idt_turma_id'].toString(),
                  descricao: disciplina['descricao'].toString(),
                  codigo: disciplina['codigo'] ?? '',
                  idt_id: disciplina['idt_id'].toString(),
                  checkbox: false,
                );
                disciplinaController.addDisciplina(itemDisciplina);
              }
            }
          }
        }

        if (gestoesAPI.isNotEmpty) {
          await salvarGestoesBox(responseJson['gestoes']);
          await MatriculasServiceAdapter().salvar(responseJson['matriculas']);
        } else {
          Future.microtask(() {
            SnackBarServiceWidget.mostrarSnackBar(context,
                mensagem: 'Nenhuma gestão foi encontrada',
                backgroundColor: AppTema.primaryAmarelo,
                icon: Icons.error_outline,
                iconColor: Colors.white);
          });
        }

        // Future.microtask(() {
        //   CustomSnackBar.showSuccessSnackBar(
        //       context, 'Gestões atualizadas com sucesso!');
        // });
      } else if (response.statusCode == 401) {
        removerDadosAuth();
        Future.microtask(() {
          CustomSnackBar.showErrorSnackBar(context, 'Conexão expirada');
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        });
        return;
      }
    } catch (e) {
      Future.microtask(() {
        CustomSnackBar.showErrorSnackBar(
          context,
          'Erro de conexão: $e',
        );
      });
    }
  }

  Future<void> atualizarGestoesDoDispositivo(BuildContext context) async {
    final apiService = GestoesListarComOutrosDadosHttp();

    bool isConnected = await InternetConnectivityService.isConnected();

    http.Response response = await apiService.todasAsGestoes();

    if (!isConnected) {
      Future.microtask(() {
        CustomSnackBar.showErrorSnackBar(
          context,
          'Erro ao estabelecer a conexão. Verifique sua conexão com a internet.',
        );
      });
      return;
    }

    try {
      if (response.statusCode == 200) {
        final disciplinaController = DisciplinaController();
        final horarioConfiguracaoController = HorarioConfiguracaoController();

        await disciplinaController.init();
        await horarioConfiguracaoController.init();

        await disciplinaController.clear();
        await horarioConfiguracaoController.clear();

        final Map<String, dynamic> responseJson =
            await jsonDecode(response.body);

        await horarioConfiguracaoController
            .addHorarioConfiguracoes(responseJson['horarios_configuracao']);

        final List<dynamic> gestoesAPI = responseJson['gestoes'];
        for (var gestaoList in gestoesAPI) {
          for (var item in gestaoList) {
            if (item['disciplinas'] != null) {
              for (var disciplina in item['disciplinas']) {
                final itemDisciplina = Disciplina(
                  id: disciplina['id'].toString(),
                  idtTurmaId: disciplina['idt_turma_id'].toString(),
                  descricao: disciplina['descricao'].toString(),
                  codigo: disciplina['codigo'] ?? '',
                  idt_id: disciplina['idt_id'].toString(),
                  checkbox: false,
                );
                disciplinaController.addDisciplina(itemDisciplina);
              }
            }
          }
        }

        if (gestoesAPI.isNotEmpty) {
          await salvarGestoesBox(responseJson['gestoes']);
          await MatriculasServiceAdapter().salvar(responseJson['matriculas']);
        } else {
          Future.microtask(() {
            SnackBarServiceWidget.mostrarSnackBar(context,
                mensagem: 'Nenhuma gestão foi encontrada',
                backgroundColor: AppTema.primaryAmarelo,
                icon: Icons.error_outline,
                iconColor: Colors.white);
          });
        }
      } else if (response.statusCode == 401) {
        removerDadosAuth();
        Future.microtask(() {
          CustomSnackBar.showErrorSnackBar(context, 'Conexão expirada');
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        });
        return;
      }
    } catch (error) {
      Future.microtask(() {
        CustomSnackBar.showErrorSnackBar(
          context,
          error.toString(),
        );
      });
    }
  }

  Future<void> salvarGestoesBox(List<dynamic> gestoes) async {
    var gestoesBox = Hive.box('gestoes');

    var storedGestoes = gestoesBox.get('gestoes');

    if (storedGestoes != null && storedGestoes.length > 0) {
      await gestoesBox.clear();
    }

    await gestoesBox.put('gestoes', gestoes);
  }

  void removerDadosAuth() {
    Box authBox = Hive.box('auth');
    authBox.clear();
  }

  List<dynamic> listar() {
    var gestoesBox = Hive.box('gestoes');
    List<dynamic> gestoesData = gestoesBox.get('gestoes');
    return gestoesData;
  }

  Future<void> atualizarGestoesDispositivo() async {
    final apiService = GestoesListarComOutrosDadosHttp();

    try {
      http.Response response = await apiService.todasAsGestoes();

      if (response.statusCode == 200) {
        final disciplinaController = DisciplinaController();

        await disciplinaController.init();
        await disciplinaController.clear();

        final Map<String, dynamic> responseJson =
            await jsonDecode(response.body);

        final List<dynamic> gestoesAPI = responseJson['gestoes'];
        for (var gestaoList in gestoesAPI) {
          for (var item in gestaoList) {
            if (item['disciplinas'] != null) {
              for (var disciplina in item['disciplinas']) {
                final itemDisciplina = Disciplina(
                  id: disciplina['id'].toString(),
                  idtTurmaId: disciplina['idt_turma_id'].toString(),
                  descricao: disciplina['descricao'].toString(),
                  codigo: disciplina['codigo'] ?? '',
                  idt_id: disciplina['idt_id'].toString(),
                  checkbox: false,
                );
                disciplinaController.addDisciplina(itemDisciplina);
              }
            }
          }
        }
      }
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'auth-repository-login',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return;
    }
  }
}
