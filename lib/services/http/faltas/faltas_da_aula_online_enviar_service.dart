import 'package:professor_acesso_notifiq/models/matricula_model.dart';
import 'package:professor_acesso_notifiq/models/models_online/falta_model_online.dart';
import 'dart:async';

import 'package:professor_acesso_notifiq/services/http/faltas/faltas_da_aula_online_enviar_http.dart';

class FaltasDaAulaOnlineEnviarService {
  Future<void> setExecutar({
    required List<dynamic>? dataFrequencias,
    required String aulaId,
  }) async {
    FaltasDaAulaOnlineEnviarHttp apiService = FaltasDaAulaOnlineEnviarHttp();
    await apiService.executarApi(
        dataFrequencias: dataFrequencias, aulaID: aulaId);
  }

  Future<void> executar({
    required String aula_id,
    required List<Matricula> matriculasDaTurmaAtiva,
    required List<FaltaModelOnline> faltasOnlines,
    required List<bool?> isLiked,
    required List<dynamic> justificavasDaMatricula,
  }) async {
    //print('-------------------SALVANDO FREQUẼNCIA ONLINE---------------');
    List<dynamic>? listFaltasSemJustificavasDaMatricula = [];
    bool addItem = true;
    for (var element in isLiked) {
      if (element == false) {
        addItem = false;
      }
    }
    if (addItem || faltasOnlines.isEmpty) {
      faltasOnlines.add(
        FaltaModelOnline(
          id: '',
          justificativa_id: '25',
          matricula_id: '',
          aula_id: aula_id,
          status: true,
        ),
      );
    }

    matriculasDaTurmaAtiva.asMap().forEach((index, matricula) {
      bool salvar = true;
      bool atualizarJustificativa = false;
      String faltaIdAula = '';
      bool deletarFalta = false;
      int indexFalta = 0;
      listFaltasSemJustificavasDaMatricula.clear();
      faltasOnlines.asMap().forEach((indexFaltaAtual, falta) {
        if (falta.justificativa_id.toString() == 'null') {
          listFaltasSemJustificavasDaMatricula.add({
            'justificativa_id': null,
            'matricula_id': falta.matricula_id,
            'aula_id': falta.aula_id,
            'status': 'SEM JUSTIFICATIVA'
          });
        }
        if (falta.matricula_id.toString() == matricula.matricula_id &&
            falta.aula_id.toString() == aula_id.toString()) {
          salvar = false;
          indexFalta = indexFaltaAtual;
          faltaIdAula = falta.aula_id;
          deletarFalta = true;

          if (falta.justificativa_id.toString() !=
              justificavasDaMatricula[index].toString()) {
            // ignore: prefer_interpolation_to_compose_strings, avoid_print
            print('diferente justificativa');
            atualizarJustificativa = true;
            deletarFalta = false;
          }
        }
      });
      //print('listFaltasSemJustificavasDaMatricula: ${listFaltasSemJustificavasDaMatricula}');
      if (faltasOnlines[indexFalta].aula_id.toString() == aula_id.toString() &&
          salvar == false &&
          deletarFalta == false &&
          atualizarJustificativa == true) {
        // ignore: prefer_interpolation_to_compose_strings, avoid_print
        // print('Atualizando ' +
        //     matriculasDaTurmaAtiva[index].aluno_nome.toString());
        // // ignore: prefer_interpolation_to_compose_strings, avoid_print
        // print('antes => ' +
        //     faltasOnlines[indexFalta].justificativa_id.toString());

        faltasOnlines[indexFalta].justificativa_id =
            justificavasDaMatricula[index].toString();
        // ignore: prefer_interpolation_to_compose_strings, avoid_print
        // print('depois => ' +
        //     faltasOnlines[indexFalta].justificativa_id.toString());
      } else if (faltaIdAula.toString() == aula_id.toString() &&
          salvar == false &&
          deletarFalta == true &&
          atualizarJustificativa == false &&
          isLiked[index] != false) {
        // ignore: prefer_interpolation_to_compose_strings, avoid_print
        // print('Deletando ' +
        //     matriculasDaTurmaAtiva[index].aluno_nome.toString() +
        //     '--' +
        //     faltasOnlines[indexFalta].matricula_id);
        // // ignore: prefer_interpolation_to_compose_strings, avoid_print
        // print('indexFalta: $indexFalta');
        // // ignore: prefer_interpolation_to_compose_strings, avoid_print
        // print('faltasOnlines.length: ${faltasOnlines.length}');
        // // ignore: prefer_interpolation_to_compose_strings, avoid_print
        // print(
        //     'faltasOnlines[indexFalta].matricula_id: ${faltasOnlines[indexFalta].matricula_id}');
        faltasOnlines.removeAt(indexFalta);
      } else {
        if (isLiked[index] == false && salvar == true) {
          // ignore: prefer_interpolation_to_compose_strings, avoid_print
          // print('criando ' + matricula.aluno_nome.toString());
          faltasOnlines.add(FaltaModelOnline(
            id: 'nova_aula',
            justificativa_id: justificavasDaMatricula[index].toString(),
            matricula_id: matricula.matricula_id,
            aula_id: aula_id,
            status: true,
          ));
        }
      }
    });
    FaltasDaAulaOnlineEnviarHttp apiService = FaltasDaAulaOnlineEnviarHttp();
    await apiService.executar(
      faltasOnlines: faltasOnlines,
      aulaID: aula_id,
      listaFaltasSemJustificavasDaMatricula:
          listFaltasSemJustificavasDaMatricula,
    );
    // ignore: prefer_interpolation_to_compose_strings, avoid_print
    // print('---------------FINAL----------------');

    if (faltasOnlines.isNotEmpty) {
      // ignore: prefer_interpolation_to_compose_strings, avoid_print
      // print('faltasOnlines.length: ${faltasOnlines.length}');
      faltasOnlines.asMap().forEach((index, element) {
        // ignore: prefer_interpolation_to_compose_strings, avoid_print
        print('index: ' +
            index.toString() +
            '° - matricula_id: ' +
            element.matricula_id);
      });
    }
    faltasOnlines.clear();
  }
}
