import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/componentes/graficos/doughnut_grafico_disciplinas_por_gestao_componente.dart';
//import 'package:professor_acesso_notifiq/componentes/graficos/stacked_bar_grafico_disciplinas_por_gestao_componente.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import '../../models/chart_data_model.dart';

import '../componentes/dialogs/custom_dialogs.dart';
import '../componentes/graficos/stacked_bar_grafico_disciplinas_por_gestao_componente.dart';
import '../functions/textos/extrair_apenas_texto_antes_dos_parenteses.dart';
import '../models/gestao_ativa_model.dart';
import '../models/gestao_disciplina_model.dart';
import '../services/adapters/gestao_ativa_service_adapter.dart';
import '../services/controller/gestao_disciplina_controller.dart';
import '../services/http/gestoes/gestoes_disciplinas_http.dart';
import '../componentes/drawer/custom_drawer.dart';

class GraficosPage extends StatefulWidget {
  const GraficosPage({super.key});

  @override
  State<GraficosPage> createState() => _GraficosPageState();
}

class _GraficosPageState extends State<GraficosPage> {
  GestaoAtiva? gestaoAtivaModel;
  double heightCardAtual = 300.0;
  double heightCardTotal = 00.0;

  @override
  void initState() {
    super.initState();
    getFranquiasTotal();
    getFranquiaAtual();
  }

  Future<void> start() async {
    try {
      CustomDialogs.showLoadingDialog(context,
          show: true, message: 'Aguardando...');
      GestaoDisciplinaHttp gestaoDisciplinaHttp = GestaoDisciplinaHttp();
      await gestaoDisciplinaHttp.getGestaoDisciplinas();
      await getFranquiaAtual();
      CustomDialogs.showLoadingDialog(context, show: false);
    } catch (e) {
      CustomDialogs.showLoadingDialog(context, show: false);
    }
  }

  Future<void> getFranquiaAtual() async {
    GestaoDisciplinaController gestaoDisciplinaController =
        GestaoDisciplinaController();
    await gestaoDisciplinaController.init();
    gestaoAtivaModel = await GestaoAtivaServiceAdapter().getExibirGestaoAtiva();
    //await Future.delayed(const Duration(seconds: 1));
    setState(() {});
    List<dynamic>? lista = await gestaoDisciplinaController.getFranquiaPeloId(
        id: gestaoAtivaModel!.configuracao_id.toString());

    if (lista == null) {
      return;
    }

    int i = 0;
    double newHeight = heightCardAtual; // Temporarily store the current height
    for (var item in lista) {
      if (item is GestaoDisciplina) {
        for (var disciplina in item.disciplinas) {
          newHeight += 20.0;
        }
      }
    }

    setState(() {
      heightCardAtual = newHeight;
    });
  }

  Future<void> getFranquiasTotal() async {
    try {
      GestaoDisciplinaController gestaoDisciplinaController =
          GestaoDisciplinaController();
      await gestaoDisciplinaController.init();
      //await Future.delayed(const Duration(seconds: 3));

      List<dynamic> lista = await gestaoDisciplinaController.getFranquias();

      int i = 0;

      if (lista.isNotEmpty) {
        for (var item in lista) {
          if (item is Map<String, dynamic>) {
            heightCardTotal += 80.0;
          }
        }
      }

      setState(() => heightCardTotal);
    } catch (e) {
      print('error-todas-as-franquias: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Gráficos de vínculos'),
        actions: [
          TextButton(
            onPressed: () async => await start(),
            child: const Icon(
              Icons.autorenew,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              // Text('heightCardAtual: $heightCardAtual'),
              Container(
                padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                height: heightCardAtual,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: const Color.fromARGB(255, 228, 225, 225),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 128, 118, 88),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Disciplinas por gestão',
                                style: TextStyle(
                                    color: AppTema.primaryAmarelo,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Franquia atual',
                                style: TextStyle(
                                    color: AppTema.primaryAmarelo,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                        child: DoughnutGraficoDisciplinasPorGestaoComponente(),
                      ),
                    ],
                  ),
                ),
              ),
              // Text('heightCardTotal: $heightCardTotal'),
              Container(
                padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                height: heightCardTotal,
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: const Color.fromARGB(255, 228, 225, 225),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 217, 168, 6),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Disciplinas por gestão',
                                  style: TextStyle(
                                    color: AppTema.primaryAmarelo,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Todas as franquias',
                                  style: TextStyle(
                                    color: AppTema.primaryAmarelo,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Expanded(
                          child: StackedBarGraficoDisciplinasPorGestao(
                            todasAsFranquias: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
