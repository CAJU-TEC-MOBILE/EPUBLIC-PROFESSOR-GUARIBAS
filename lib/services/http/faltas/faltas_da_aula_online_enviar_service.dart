import 'dart:ffi';
import 'package:professor_acesso_notifiq/models/matricula_model.dart';
import 'package:professor_acesso_notifiq/models/models_online/falta_model_online.dart';
import 'dart:async';
import 'package:professor_acesso_notifiq/services/http/faltas/faltas_da_aula_online_enviar_http.dart';
import '../../shared_preference_service.dart';

class FaltasDaAulaOnlineEnviarService {
  final preference = SharedPreferenceService();
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
            print('diferente justificativa');
            atualizarJustificativa = true;
            deletarFalta = false;
          }
        }
      });
      if (faltasOnlines[indexFalta].aula_id.toString() == aula_id.toString() &&
          salvar == false &&
          deletarFalta == false &&
          atualizarJustificativa == true) {
        faltasOnlines[indexFalta].justificativa_id =
            justificavasDaMatricula[index].toString();
      } else if (faltaIdAula.toString() == aula_id.toString() &&
          salvar == false &&
          deletarFalta == true &&
          atualizarJustificativa == false &&
          isLiked[index] != false) {
        faltasOnlines.removeAt(indexFalta);
      } else {
        if (isLiked[index] == false && salvar == true) {
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
    if (faltasOnlines.isNotEmpty) {
      faltasOnlines.asMap().forEach((index, element) {
        print('index: ' +
            index.toString() +
            '° - matricula_id: ' +
            element.matricula_id);
      });
    }
    faltasOnlines.clear();
  }
}
