import 'package:professor_acesso_notifiq/models/etapa_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';

List<Etapa> filtrarEtapasPorGestaoAtiva() {
  List<Etapa> etapas = [];
  GestaoAtiva? _gestaoAtivaModel =
      GestaoAtivaServiceAdapter().exibirGestaoAtiva();
  if (_gestaoAtivaModel!.circuito.etapas.isNotEmpty) {
    etapas = _gestaoAtivaModel.circuito.etapas;
    return etapas;
  }
  return etapas;
}
