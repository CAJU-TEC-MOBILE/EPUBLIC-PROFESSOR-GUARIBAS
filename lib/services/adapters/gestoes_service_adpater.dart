import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/componentes/global/preloader.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/verificar_conexao_com_internet.dart';
import 'package:professor_acesso_notifiq/pages/login_page.dart';
import 'package:professor_acesso_notifiq/services/adapters/matriculas_service_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/http/gestoes/gestoes_listar_com_outros_dados_http.dart';
import 'dart:convert';
import 'dart:async';

import 'package:professor_acesso_notifiq/services/widgets/snackbar_service_widget.dart';

import '../../componentes/dialogs/custom_snackbar.dart';
import '../../models/disciplina_model.dart';
import '../connectivity/internet_connectivity_service.dart';
import '../controller/Instrutor_controller.dart';
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
            // ignore: use_build_context_synchronously
            SnackBarServiceWidget.mostrarSnackBar(context,
                mensagem: 'Nenhuma gestão foi encontrada',
                backgroundColor: AppTema.primaryAmarelo,
                icon: Icons.error_outline,
                iconColor: Colors.white);
          });
        }

        Future.microtask(() {
          // ignore: use_build_context_synchronously
          CustomSnackBar.showSuccessSnackBar(
              context, 'Gestões atualizadas com sucesso!');
        });
      } else if (response.statusCode == 401) {
        removerDadosAuth();
        Future.microtask(() {
          // ignore: use_build_context_synchronously
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
    showLoading(context);

    GestoesListarComOutrosDadosHttp apiService =
        GestoesListarComOutrosDadosHttp();

    bool isConnected = await InternetConnectivityService.isConnected();

    http.Response response = await apiService.todasAsGestoes();

    if (!isConnected) {
      hideLoading(context);
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
                debugPrint("-> $disciplina");
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
            // ignore: use_build_context_synchronously
            SnackBarServiceWidget.mostrarSnackBar(context,
                mensagem: 'Nenhuma gestão foi encontrada',
                backgroundColor: AppTema.primaryAmarelo,
                icon: Icons.error_outline,
                iconColor: Colors.white);
          });
        }

        print('-------------ATUALIZANDO GESTÕES E MATRÍCULAS-------------');

        hideLoading(context);
        Future.microtask(() {
          // ignore: use_build_context_synchronously
          CustomSnackBar.showSuccessSnackBar(
              context, 'Gestões atualizadas com sucesso!');
        });
      } else if (response.statusCode == 401) {
        removerDadosAuth();
        hideLoading(context);
        Future.microtask(() {
          // ignore: use_build_context_synchronously
          CustomSnackBar.showErrorSnackBar(context, 'Conexão expirada');
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        });
        return;
      }
    } catch (e) {
      hideLoading(context);
      Future.microtask(() {
        CustomSnackBar.showErrorSnackBar(
          context,
          'Erro de conexão: $e',
        );
      });
    }
  }

  Future<void> salvarGestoesBox(List<dynamic> gestoes) async {
    var gestoesBox = Hive.box('gestoes');

    // Check if the box contains 'gestoes' and ensure it's not null
    var storedGestoes = gestoesBox.get('gestoes');

    if (storedGestoes != null && storedGestoes.length > 0) {
      await gestoesBox.clear();
      print('---------------BOX GESTÕES (CLEAR)--------------');
    }

    await gestoesBox.put('gestoes', gestoes);
  }

  void removerDadosAuth() {
    Box authBox = Hive.box('auth');
    authBox.clear(); // Remove todos os dados do Box 'auth'
  }

  List<dynamic> listar() {
    var gestoesBox = Hive.box('gestoes');
    List<dynamic> gestoesData = gestoesBox.get('gestoes');
    return gestoesData;
  }

  Future<void> atualizarGestoesDispositivo() async {
    print('===== atualizarGestoesDispositivo ====');
    // dynamic isConnected = await checkInternetConnection();
    // if (isConnected == null || !isConnected) {
    //   print('Erro de conexão ou valor inválido');
    //   return;
    // }

    GestoesListarComOutrosDadosHttp apiService =
        GestoesListarComOutrosDadosHttp();

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
            //print('--> Item: ${item}');

            if (item['disciplinas'] != null) {
              for (var disciplina in item['disciplinas']) {
                // print('Disciplina ID: ${disciplina['id']}');
                // print('Descrição: ${disciplina['descricao']}');
                // print('idt_turma_id: ${disciplina['idt_turma_id']}');
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
    } catch (e) {
      print('Erro ao fazer a requisição: $e');
      return;
    }
  }
}
