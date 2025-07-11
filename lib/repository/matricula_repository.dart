import '../models/faltas_model.dart';
import '../models/matricula_model.dart';
import '../services/controller/falta_controller.dart';
import '../services/controller/historico_requencia_controller.dart';
import '../services/controller/matricula_turma_ativa_controller.dart';

class MatriculaRepository {
  Future<void> removeArquivoDaFrequencia({
    required String? criadaPeloCelular,
  }) async {
    final controller = MatriculaTurmaAtivaController();
    final historicoPresenca = HistoricoPresencaController();
    final faltaController = FaltaController();

    await controller.init();
    await historicoPresenca.init();
    await faltaController.init();

    List<Matricula> matriculas = await controller.all();

    for (int i = 0; i < matriculas.length; i++) {
      Matricula item = matriculas[i];
      item.existe_anexo = false;
      await historicoPresenca.deletarAnexoPorAula(
        criadaPeloCelular,
        item.aluno_id,
      );
      await controller.updateAl(i, item);
    }

    await faltaController.deletaFaltPeloAulaId(aulaId: criadaPeloCelular);
  }
}
