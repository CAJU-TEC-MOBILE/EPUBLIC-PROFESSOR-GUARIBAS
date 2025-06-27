import 'package:professor_acesso_notifiq/models/etapa_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';

List<Etapa> filtrarEtapasPorGestaoAtiva() {
  List<Etapa> etapas = [];
  GestaoAtiva? gestaoAtivaModel =
      GestaoAtivaServiceAdapter().exibirGestaoAtiva();
  if (gestaoAtivaModel!.circuito.etapas.isNotEmpty) {
    etapas = gestaoAtivaModel.circuito.etapas;
    return etapas;
  }
  return etapas;
}
