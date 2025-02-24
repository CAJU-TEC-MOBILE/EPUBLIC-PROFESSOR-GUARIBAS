import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/faltas_model.dart';
import 'package:professor_acesso_notifiq/models/matricula_model.dart';

class FaltasOfflinesServiceAdapter {
  Future<void> salvar(
      {required String criadaPeloCelular,
      required List<Matricula> matriculasDaTurmaAtiva,
      required List<bool?> isLiked,
      required List<dynamic> justificavasDaMatricula}) async {
    Box<Falta> _faltasBox = Hive.box<Falta>('faltas');

    matriculasDaTurmaAtiva.asMap().forEach((index, matricula) {
      bool salvar = true;
      bool atualizar_justificativa = false;
      String falta_id_aula = '';
      bool deletar_falta = false;
      int index_falta = 0;

      List<Falta> _faltasData = _faltasBox.values.toList();

      _faltasData.asMap().forEach((index_falta_atual, falta) {
        if (falta.matricula_id.toString() == matricula.matricula_id &&
            falta.aula_id.toString() == criadaPeloCelular.toString()) {
          salvar = false;
          index_falta = index_falta_atual;
          falta_id_aula = falta.aula_id;
          deletar_falta = true;
          // JUSTIFICATIVA DIFERENTE
          if (falta.justificativa_id.toString() !=
              justificavasDaMatricula[index].toString()) {
            atualizar_justificativa = true;
            deletar_falta = false;
          }
        }
      });
      // ATUALIZANDO
      if (falta_id_aula.toString() == criadaPeloCelular.toString() &&
          salvar == false &&
          deletar_falta == false &&
          atualizar_justificativa == true) {
        _faltasBox.putAt(
            index_falta,
            Falta(
                aula_id: criadaPeloCelular.toString(),
                matricula_id:
                    matriculasDaTurmaAtiva[index].matricula_id.toString(),
                justificativa_id: justificavasDaMatricula[index].toString(),
                aluno_nome: matriculasDaTurmaAtiva[index].aluno_nome.toString(),
                observacao: '',
                document: ''));
      }
      // DELETANDO
      else if (falta_id_aula.toString() == criadaPeloCelular.toString() &&
          salvar == false &&
          deletar_falta == true &&
          atualizar_justificativa == false &&
          isLiked[index] != false) {
        _faltasBox.deleteAt(index_falta);
      } else {
        // CRIANDO
        if (isLiked[index] == false && salvar == true) {
          _faltasBox.add(Falta(
              aula_id: criadaPeloCelular.toString(),
              matricula_id:
                  matriculasDaTurmaAtiva[index].matricula_id.toString(),
              justificativa_id: justificavasDaMatricula[index].toString(),
              aluno_nome: matriculasDaTurmaAtiva[index].aluno_nome.toString(),
              observacao: '',
              document: ''));
        }
      }
    });

    print("-----------------TOTAL DE FALTAS DO BOX---------------------");
    print(_faltasBox.values.toList().length);
    List<Falta> _faltasData = _faltasBox.values.toList();
  }

  Future<List<Falta>> listar() async {
    Box<Falta> _faltasBox = Hive.box<Falta>('Faltas');
    List<Falta> _faltasData = _faltasBox.values.toList();
    return _faltasData;
  }

  Future<List<Falta>> listarFaltasDeAulaEspecifica(
      {required String criadaPeloCelular}) async {
    Box<Falta> _faltasBox = Hive.box<Falta>('Faltas');
    List<Falta> _faltasData = _faltasBox.values.toList();
    List<Falta> _faltasDataFiltro = _faltasData
        .where(
            (falta) => falta.aula_id.toString() == criadaPeloCelular.toString())
        .toList();
    return _faltasDataFiltro;
  }

  Future<void> removerFaltasSincronizadas(List<Falta> faltas) async {
    Box<Falta> faltasBox = Hive.box<Falta>('Faltas');
    List<Falta> faltasData = faltasBox.values.toList();
    List<int> indexDeFaltasAseremRemovidasAposSincronizacao = [];

    faltasData.asMap().forEach((indexFalta, falta) {
      faltas.forEach((faltaDaAula) {
        if (falta.aula_id.toString() == faltaDaAula.aula_id.toString() &&
            falta.matricula_id.toString() ==
                faltaDaAula.matricula_id.toString()) {
          indexDeFaltasAseremRemovidasAposSincronizacao.add(indexFalta);
        }
      });
    });

    indexDeFaltasAseremRemovidasAposSincronizacao
        .sort((a, b) => b.compareTo(a));

    for (int index in indexDeFaltasAseremRemovidasAposSincronizacao) {
      faltasBox.deleteAt(index);
    }
  }
}
