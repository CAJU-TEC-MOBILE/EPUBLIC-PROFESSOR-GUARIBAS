import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/functions/boxs/gestoes/filtrar_quantidade_de_disciplinas_por_turma_da_fraquia_selecionada.dart';
import 'package:professor_acesso_notifiq/functions/textos/extrair_apenas_texto_antes_dos_parenteses.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/gestao_disciplina_model.dart';
import '../../services/controller/gestao_disciplina_controller.dart';

class StackedBarGraficoDisciplinasPorGestao extends StatefulWidget {
  final bool todasAsFranquias;

  const StackedBarGraficoDisciplinasPorGestao({
    super.key,
    required this.todasAsFranquias,
  });

  @override
  State<StackedBarGraficoDisciplinasPorGestao> createState() =>
      _StackedBarGraficoDisciplinasPorGestaoState();
}

class _StackedBarGraficoDisciplinasPorGestaoState
    extends State<StackedBarGraficoDisciplinasPorGestao> {
  final List<ChartData> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      setState(() => isLoading = true);
      GestaoDisciplinaController controller = GestaoDisciplinaController();
      await controller.init();

      List<dynamic> lista = await controller.getFranquias();
      data.clear();

      if (lista.isNotEmpty) {
        _organizarDados(lista);
      }
    } catch (error) {
      debugPrint('Erro ao carregar dados: $error');
      _mostrarMensagemErro();
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _organizarDados(List<dynamic> lista) {
    for (int i = 0; i < lista.length; i++) {
      if (lista[i] is Map<String, dynamic>) {
        final item = lista[i];
        data.add(
          ChartData(
            extrairApenasTextoAntesParenteses(item['descricao'].toString()),
            (item['quantidade'] ?? 0).toDouble(),
            AppTema.coresParaGraficos[i % AppTema.coresParaGraficos.length],
          ),
        );
      }
    }
  }

  void _mostrarMensagemErro() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao carregar os dados das franquias.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(color: AppTema.primaryAmarelo),
          )
        : data.isEmpty
            ? const Center(
                child: Text('Nenhuma franquia disponível no momento'),
              )
            : _buildGrafico();
  }

  Widget _buildGrafico() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: true),
                // titlesData: _buildTitlesData(),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1),
                ),
                barGroups: _buildBarGroups(),
                alignment: BarChartAlignment.spaceEvenly,
              ),
            ),
          ),
          _buildLegenda(),
        ],
      ),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: true),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            return Text(
              data[index].category,
              style: const TextStyle(fontSize: 12),
            );
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      ChartData chartData = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: chartData.value,
            color: chartData.color,
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildLegenda() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: data.map((chartData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  color: chartData.color,
                ),
                const SizedBox(width: 8),
                Text(chartData.category),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}
