import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/chart_data_model.dart';
import '../../models/gestao_ativa_model.dart';
import '../../models/gestao_disciplina_model.dart';
import '../../services/adapters/gestao_ativa_service_adapter.dart';
import '../../services/controller/gestao_disciplina_controller.dart';
import 'package:professor_acesso_notifiq/functions/textos/extrair_apenas_texto_antes_dos_parenteses.dart';

import '../defaulde/custom_defaulde_grafico.dart';

class DoughnutGraficoDisciplinasPorGestaoComponente extends StatefulWidget {
  const DoughnutGraficoDisciplinasPorGestaoComponente({super.key});

  @override
  State<DoughnutGraficoDisciplinasPorGestaoComponente> createState() =>
      _DoughnutGraficoDisciplinasPorGestaoComponenteState();
}

class _DoughnutGraficoDisciplinasPorGestaoComponenteState
    extends State<DoughnutGraficoDisciplinasPorGestaoComponente> {
  final List<ChartData> data = [];
  GestaoAtiva? gestaoAtivaModel;
  bool load = false;

  @override
  void initState() {
    super.initState();
    gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() => load = true);
    final gestaoDisciplinaController = GestaoDisciplinaController();
    await gestaoDisciplinaController.init();

    final lista = await gestaoDisciplinaController.getFranquiaPeloId(
        id: gestaoAtivaModel!.configuracao_id.toString());

    if (lista == null) {
      setState(() => load = false);
      return;
    }

    int i = 0;
    data.clear();

    for (var item in lista) {
      if (item is GestaoDisciplina) {
        for (var disciplina in item.disciplinas) {
          data.add(ChartData(
            extrairApenasTextoAntesParenteses(
                disciplina['descricao'].toString().toUpperCase()),
            disciplina['quantidade']?.toDouble() ?? 0.0,
            AppTema.coresParaGraficos[i % AppTema.coresParaGraficos.length],
          ));
          i++;
        }
      }
    }

    setState(() => load = false);
  }

  @override
  Widget build(BuildContext context) {
    return load
        ? const Center(
            child: CircularProgressIndicator(
              color: AppTema.primaryAmarelo,
            ),
          )
        : data.isNotEmpty
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    child: Column(
                      children: [
                        const SizedBox(height: 24.0),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: data.map((ChartData chartData) {
                                return PieChartSectionData(
                                  value: chartData.value,
                                  color: chartData.color,
                                  title: '${chartData.value.toInt()}',
                                  radius: 32,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                );
                              }).toList(),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 0,
                              centerSpaceRadius: 42,
                            ),
                          ),
                        ),
                        // Legend Section
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.only(top: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: data.map((ChartData chartData) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      color: chartData.color,
                                    ),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 0.0),
                                      child: Text(
                                        chartData.category,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : const Padding(
                padding: EdgeInsets.only(top: 32.0),
                child: CustomDefauldeGrafico(),
              );
  }
}
