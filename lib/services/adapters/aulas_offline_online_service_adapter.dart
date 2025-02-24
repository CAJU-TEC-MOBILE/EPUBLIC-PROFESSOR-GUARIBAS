import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/componentes/global/preloader.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/verificar_conexao_com_internet.dart';
import 'package:professor_acesso_notifiq/functions/filtrar_aulas_por_gestao_ativa.dart';
import 'package:professor_acesso_notifiq/models/aula_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/models/disciplina_model.dart';
import 'package:professor_acesso_notifiq/models/serie_aula_model.dart';
import 'package:professor_acesso_notifiq/pages/login_page.dart';
import 'package:professor_acesso_notifiq/services/http/aulas/aulas_listar_todas_http.dart';
import 'package:professor_acesso_notifiq/services/widgets/snackbar_service_widget.dart';

import '../../help/console_log.dart';
import '../../models/disciplina_aula_model.dart';
import '../../models/serie_model.dart';
import '../controller/aula_controller.dart';
import '../controller/disciplina_aula_controller.dart';
import '../controller/serie_aula_controller.dart';

class AulasOfflineOnlineServiceAdapter {
  Future<List<Aula>> todasAsAulas(BuildContext context) async {
    try {
      Box<Aula> caixaAulas = Hive.box<Aula>('aulas_offlines');
      Box gestaoAtivaBox = Hive.box('gestao_ativa');
      Map<dynamic, dynamic>? gestao_ativa_data;
      gestao_ativa_data = await gestaoAtivaBox.get('gestao_ativa');

      // !! Aulas Off-line !!

      List<Aula> aulas = caixaAulas.values
          .map((valor) => Aula(
                id: valor.id,
                instrutor_id: valor.instrutor_id,
                disciplina_id: valor.disciplina_id,
                turma_id: valor.turma_id,
                tipoDeAula: valor.tipoDeAula,
                dataDaAula: valor.dataDaAula,
                disciplinas_formatted: valor.disciplinas_formatted,
                horarioID: valor.horarioID,
                horarios_infantis: [],
                horarios_formatted: valor.horarios_formatted,
                conteudo: valor.conteudo,
                metodologia: valor.metodologia,
                saberes_conhecimentos: valor.saberes_conhecimentos,
                dia_da_semana: valor.dia_da_semana,
                situacao: valor.situacao,
                is_polivalencia: valor.is_polivalencia,
                criadaPeloCelular: valor.criadaPeloCelular,
                etapa_id: valor.etapa_id,
                instrutorDisciplinaTurma_id: valor.instrutorDisciplinaTurma_id,
                eixos: valor.eixos,
                estrategias: valor.estrategias,
                recursos: valor.recursos,
                atividade_casa: valor.atividade_casa,
                atividade_classe: valor.atividade_classe,
                observacoes: valor.observacoes,
                e_aula_infantil: valor.e_aula_infantil,
                disciplinas: valor.disciplinas ?? [],
                horarios_extras_formatted:
                    valor.horarios_extras_formatted ?? [],
                campos_de_experiencias: valor.campos_de_experiencias.toString(),
                experiencias: [],
              ))
          .toList();

      showLoading(context);

      /*print('==================================');
    print('idt_instrutor_id: ${gestao_ativa_data?['idt_instrutor_id'].toString()}');
    print('idt_disciplina_id: ${gestao_ativa_data?['idt_disciplina_id'].toString()}');
    print('idt_turma_id: ${gestao_ativa_data?['idt_turma_id'].toString()}');
    print('instrutorDisciplinaTurma_id: ${gestao_ativa_data?['idt_id'].toString()}');
    print('==================================');*/

      List<Aula> aulasFiltradasPorGestaoAtiva =
          await filtrarAulasPorGestaoAtivaInstrutorDisciplinaTurmaId(
        lista_de_objetos: aulas,
        instrutorID: gestao_ativa_data?['idt_instrutor_id'].toString(),
        instrutorDisciplinaTurmaId: gestao_ativa_data?['idt_id'].toString(),
        turmaID: gestao_ativa_data?['idt_turma_id'].toString(),
      );

      dynamic isConnected = await checkInternetConnection();
      if (isConnected) {
        // !! Aulas On-line !!
        AulasListarTodasHttp apiService = AulasListarTodasHttp();
        http.Response response = await apiService.executar();
        //print('response: ${response.body.toString()}');
        if (response.statusCode == 200) {
          dynamic data = jsonDecode(response.body);
          if (data['aulas'] != null) {
            List<dynamic> horariosInfantisConvertidos = [];
            List<int> horariosInfantisConvertidosParaInteiro = [];
            List<dynamic> aulas = data['aulas'];

            for (var aula in aulas) {
              var horariosInfantisConvertidosParaInteiro = <int>[];

              // Check if 'horarios_infantis' exists and is a valid string
              if (aula['horarios_infantis'] != null &&
                  aula['horarios_infantis'].isNotEmpty) {
                try {
                  var horariosInfantisString = aula['horarios_infantis'] ?? [];
                  var horariosInfantisConvertidos =
                      List<dynamic>.from(jsonDecode(horariosInfantisString));

                  horariosInfantisConvertidosParaInteiro =
                      horariosInfantisConvertidos
                          .map((e) => int.parse(e.toString()))
                          .toList();

                  print(horariosInfantisConvertidosParaInteiro);
                } catch (e) {
                  print('Error parsing horarios_infantis: $e');
                }
              }
              //print('horariosInfantisConvertidosParaInteiro: $horariosInfantisConvertidosParaInteiro');
              // Add converted data to 'aulasFiltradasPorGestaoAtiva'
          
              aulasFiltradasPorGestaoAtiva.add(
                Aula(
                  id: aula['id'].toString(),
                  instrutor_id: aula['instrutor_id'].toString(),
                  disciplina_id: aula['disciplina_id'].toString(),
                  turma_id: aula['turma_id'].toString(),
                  tipoDeAula: aula['tipo_de_aula'].toString(),
                  is_polivalencia: aula['is_polivalencia'] ?? 0,
                  dataDaAula: aula['data'].toString(),
                  disciplinas_formatted: aula['disciplinas_formatted'].toString(),
                  horarios_formatted: aula['horarios_formatted'].toString(),
                  horarios_infantis:
                      horariosInfantisConvertidosParaInteiro.isNotEmpty
                          ? horariosInfantisConvertidosParaInteiro
                          : <int>[],
                  horarioID: aula['horario_id'].toString(),
                  conteudo: aula['conteudo'].toString(),
                  metodologia: aula['metodologia'].toString(),
                  saberes_conhecimentos:
                      aula['saberes_conhecimentos'].toString(),
                  dia_da_semana: aula['dia_da_semana']?.toString() ?? '',
                  situacao: aula['situacao']?.toString() ?? '',
                  criadaPeloCelular: '',
                  etapa_id: aula['etapa_id'].toString(),
                  instrutorDisciplinaTurma_id:
                      aula['instrutorDisciplinaTurma_id'].toString(),
                  eixos: aula['eixos'].toString(),
                  estrategias: aula['estrategias'].toString(),
                  recursos: aula['recursos'].toString(),
                  atividade_casa: aula['atividade_casa'].toString(),
                  atividade_classe: aula['atividade_classe'].toString(),
                  observacoes: aula['observacoes'].toString(),
                  e_aula_infantil: aula['e_aula_infantil'],
                  disciplinas: aula['disciplinas'],
                  horarios_extras_formatted: aula['horarios_extras_formatted'],
                  campos_de_experiencias:
                      aula['campos_de_experiencias'].toString(),
                  experiencias: [],
                ),
              );
            }
            aulasFiltradasPorGestaoAtiva
                .sort((a, b) => b.dataDaAula.compareTo(a.dataDaAula));
          } else {
            print('Resposta inválida: dados ausentes');
          }
        } else if (response.statusCode == 401) {
          hideLoading(context);
          removerDadosAuth();
          Future.microtask(() {
            SnackBarServiceWidget.mostrarSnackBar(context,
                mensagem: 'Conexão expirada',
                backgroundColor: Colors.red,
                icon: Icons.error_outline,
                iconColor: Colors.white);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
          });
        } else {
          print('Erro na requisição: ${response.statusCode}');
          print('Erro => ' + response.body);
        }
      } else {
        // ignore: use_build_context_synchronously
        hideLoading(context);
        aulasFiltradasPorGestaoAtiva
            .sort((a, b) => b.dataDaAula.compareTo(a.dataDaAula));
        return aulasFiltradasPorGestaoAtiva;
      }
      // ignore: use_build_context_synchronously
      hideLoading(context);

      aulasFiltradasPorGestaoAtiva
          .sort((a, b) => b.dataDaAula.compareTo(a.dataDaAula));
      return aulasFiltradasPorGestaoAtiva;
    } catch (e) {
      debugPrint('error-todas-aulas: $e');
      return [];
    }
  }

  Future<bool> salvar(
      {required Aula novaAula,
      List<Disciplina>? disciplina,
      int? multi_etapa,
      isPolivalencia}) async {
    try {
      var aulaBox = Hive.box<Aula>('aulas_offlines');

      AulaController aulaController = AulaController();
      DisciplinaAulaController disciplinaAulaController =
          DisciplinaAulaController();
      SerieAulaController serieAulaController = SerieAulaController();

      await aulaController.init();
      await disciplinaAulaController.init();
      await serieAulaController.init();

      var result = aulaBox.values.toList().indexWhere((item) {
        bool isEqual = item.horarioID == novaAula.horarioID &&
            item.turma_id == novaAula.turma_id &&
            item.dataDaAula == novaAula.dataDaAula;
        return isEqual;
      });

      if (result != -1 && novaAula.tipoDeAula != 'Aula Remota') {
        return false;
      }

      await aulaController.addAula(novaAula);

      if (isPolivalencia == 1 && disciplina != null) {
        for (var disc in disciplina) {
          if (disc == null) {
            print('Disciplina is null');
            continue;
          }

          if (disc.data == null) {
            print('Data is null for this disciplina');
            continue;
          }

          var disciplinaAula = DisciplinaAula(
            id: disc.id,
            checkbox: disc.checkbox,
            codigo: disc.codigo,
            descricao: disc.descricao,
            idtTurmaId: disc.idtTurmaId,
            idt_id: disc.idt_id,
            criadaPeloCelular: novaAula.criadaPeloCelular,
            data: disc.data!.isNotEmpty ? disc.data! : [],
          );
          await disciplinaAulaController.addDisciplinaAula(disciplinaAula);

          if (novaAula.multi_etapa == 1) {
            for (var item in disc.data!) {
              if (item is Map && item.containsKey('series')) {
                for (var itemSerie in item['series']) {
                  if (itemSerie is Serie) {
                    var serie = SerieAula(
                      aulaId: novaAula.criadaPeloCelular,
                      disciplinaId: disc.id,
                      descricao: itemSerie.descricao.toString(),
                      serieId: itemSerie.serieId.toString(),
                      turmaId: novaAula.turma_id,
                      anoId: itemSerie.anoId.toString(),
                      cursoId: itemSerie.cursoId.toString(),
                      historico: itemSerie.historico.toString(),
                      situacao: itemSerie.situacao.toString(),
                    );

                    await serieAulaController.addSerie(serie);
                  } else {
                    print("itemSerie is not a Serie: $itemSerie");
                  }
                }
              } else {
                print("item is not a Map or doesn't have 'series': $item");
              }
            }
          }
        }

        List<DisciplinaAula> data = disciplinaAulaController.getAllAulas();
        print('Aula polivalencia criada com sucesso.');
      }

      print('Aula criada com sucesso [ok]');
      return true;
    } catch (e) {
      print('error-criar-aula: $e');
      return false;
    }
  }

  void removerDadosAuth() {
    Box _authBox = Hive.box('auth');
    _authBox.clear(); // Remove todos os dados do Box 'auth'
  }

  Future<void> remover(Aula aula) async {
    Box<Aula> aulasOfflinesBox = Hive.box<Aula>('aulas_offlines');

    int index = aulasOfflinesBox.values
        .toList()
        .indexWhere((item) => item.criadaPeloCelular == aula.criadaPeloCelular);

    if (index >= 0) {
      aulasOfflinesBox.deleteAt(index);
      print('Aula removida');
    } else {
      print('Aula não encontrada');
    }
  }

  Future<bool> atualizar(
      {required Aula aula,
      List<Disciplina>? disciplina,
      isPolivalencia}) async {
    try {
      AulaController aulaController = AulaController();
      DisciplinaAulaController disciplinaAulaController = DisciplinaAulaController();
      SerieAulaController serieAulaController = SerieAulaController();

      await aulaController.init();
      await disciplinaAulaController.init();
      await serieAulaController.init();

      print('Criada Pelo Celular: ${aula.criadaPeloCelular}');

      bool statusAula = await aulaController.updateAulaCriadaPeloCelular(
          aulaAtualizada: aula,
          criadaPeloCelular: aula.criadaPeloCelular.toString());

      if (statusAula != true) {
        ConsoleLog.mensagem(
            tipo: 'erro',
            mensagem: 'Aula não atualizada com sucesso.',
            titulo: 'updateAulaCriadaPeloCelular');
        return false;
      }

      ConsoleLog.mensagem(
        titulo: 'updateAulaCriadaPeloCelular',
        mensagem: 'Aula atualizada com sucesso',
        tipo: 'sucesso',
      );

      if (isPolivalencia == 1) {
        disciplinaAulaController.removerAulasPeloCriadaPeloCelular(
            criadaPeloCelular: aula.criadaPeloCelular);
      }

      if(aula.multi_etapa == 1) {
        serieAulaController.deleteSeriePeloId(criadaPeloCelularId: aula.criadaPeloCelular);
      }

      if (isPolivalencia == 1 && disciplina != null) {
        for (var disc in disciplina) {
          if (disc.data == null) {
            print('Data is null for this disciplina');
            continue;
          }

          var disciplinaAula = DisciplinaAula(
            id: disc.id,
            checkbox: disc.checkbox,
            codigo: disc.codigo,
            descricao: disc.descricao,
            idtTurmaId: disc.idtTurmaId,
            idt_id: disc.idt_id,
            criadaPeloCelular: aula.criadaPeloCelular,
            data: disc.data!.isNotEmpty ? disc.data! : [],
          );

          await disciplinaAulaController.addDisciplinaAula(disciplinaAula);

          if (aula.multi_etapa == 1) {
            for (var item in disc.data!) {
              if (item is Map && item.containsKey('series')) {
                for (var itemSerie in item['series']) {
                  if (itemSerie is Serie) {
                    var serie = SerieAula(
                      aulaId: aula.criadaPeloCelular,
                      disciplinaId: disc.id,
                      descricao: itemSerie.descricao.toString(),
                      serieId: itemSerie.serieId.toString(),
                      turmaId: aula.turma_id,
                      anoId: itemSerie.anoId.toString(),
                      cursoId: itemSerie.cursoId.toString(),
                      historico: itemSerie.historico.toString(),
                      situacao: itemSerie.situacao.toString(),
                    );

                    await serieAulaController.addSerie(serie);
                  } else {
                    print("itemSerie is not a Serie: $itemSerie");
                  }
                }
              } else {
                print("item is not a Map or doesn't have 'series': $item");
              }
            }
          }
        }
        print('Disciplinas polivalência atualizadas com sucesso.');
      }

      return true;
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'atualização da aula',
        mensagem: '$e',
        tipo: 'erro',
      );
      return false;
    }
  }
}