import 'package:flutter/material.dart';
import '../../componentes/dialogs/custom_snackbar.dart';
import '../../constants/app_tema.dart';
import '../../functions/boxs/horarios/remover_horarios_repetidos.dart';
import '../../models/disciplina_model.dart';
import '../../models/relacao_dia_horario_model.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../utils/paleta_cor.dart';

class CustomConteudoPolivalencia extends StatefulWidget {
  final BuildContext context;
  final List<Disciplina> items;
  final List<RelacaoDiaHorario> relacaoDiaHorario;
  const CustomConteudoPolivalencia({
    super.key,
    required this.context,
    required this.items,
    required this.relacaoDiaHorario,
  });
  @override
  State<CustomConteudoPolivalencia> createState() =>
      _CustomConteudoPolivalenciaState();
}

class _CustomConteudoPolivalenciaState
    extends State<CustomConteudoPolivalencia> {
  List<TextEditingController> controllers = [];
  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    controllers = widget.items.map((disciplina) {
      final initialText = (disciplina.data!.isNotEmpty &&
              disciplina.data!.first['conteudo'] != null)
          ? disciplina.data!.first['conteudo']
          : '';
      return TextEditingController(text: initialText);
    }).toList();
  }

  @override
  void didUpdateWidget(covariant CustomConteudoPolivalencia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      for (final controller in controllers) {
        controller.dispose();
      }
      _initControllers();
    }
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Nenhuma disciplina encontrada."),
        ),
      );
    }
    if (controllers.length != widget.items.length) {
      return const Center(child: Text("Erro interno: dados inconsistentes."));
    }
    return Card(
      color: AppTema.backgroundColorApp,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final disciplina = entry.value;
            final controller = controllers[index];
            if (disciplina.data!.isEmpty) {
              disciplina.data!
                  .add({'conteudo': '', 'metodologia': '', 'horarios': []});
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      disciplina.descricao,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                TextField(
                  controller: controller,
                  maxLines: 8,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    if (disciplina.data != null &&
                        disciplina.data!.isNotEmpty &&
                        disciplina.data!.first is Map<String, dynamic>) {
                      disciplina.data!.first['conteudo'] = value;
                    }
                  },
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Horários',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                _buildHorarioSelection(index: index, disciplina: disciplina),
                const SizedBox(
                  height: 4.0,
                ),
                const Divider(color: Colors.grey),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHorarioSelection({
    required int index,
    required Disciplina disciplina,
  }) {
    final itemData =
        disciplina.data!.isNotEmpty ? disciplina.data!.first : null;
    if (itemData == null) {
      return const Text('Sem dados de horário');
    }
    final initialValue =
        itemData['horarios'] != null && itemData['horarios'] is List<int>
            ? List<int>.from(itemData['horarios'])
            : <int>[];
    return widget.relacaoDiaHorario.isNotEmpty
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey, width: 1.0),
            ),
            child: MultiSelectDialogField<int>(
              items: removeHorariosRepetidos(
                      listaOriginal: widget.relacaoDiaHorario)!
                  .map((objeto) => MultiSelectItem<int>(
                        int.parse(objeto.horario.id),
                        objeto.horario.descricao,
                      ))
                  .toList(),
              initialValue: initialValue,
              listType: MultiSelectListType.CHIP,
              title: const Text('Horários'),
              separateSelectedItems: true,
              searchHint: 'Pesquisar',
              cancelText: Text(
                'Cancelar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: PaletaCor.grey,
                ),
              ),
              confirmText: const Text(
                'Confirmar ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTema.primaryAmarelo,
                ),
              ),
              buttonText: const Text('Selecione'),
              buttonIcon: const Icon(Icons.arrow_drop_down),
              selectedColor: AppTema.primaryAmarelo,
              selectedItemsTextStyle: const TextStyle(
                color: Colors.white,
              ),
              onSelectionChanged: (p0) {
                setState(() => initialValue);
              },
              onConfirm: (selected) {
                bool temConflito = false;
                Set selectedSet = Set.from(selected);
                for (var disciplina in widget.items) {
                  if (disciplina.checkbox == true) {
                    for (var item in disciplina.data!) {
                      List horarios = item['horarios'];
                      if (horarios.isEmpty || selectedSet.isEmpty) continue;
                      Set horariosSet = Set.from(horarios);
                      if (horariosSet.intersection(selectedSet).isNotEmpty) {
                        temConflito = true;
                        break;
                      }
                    }
                  }
                  if (temConflito) break;
                }
                if (temConflito) {
                  CustomSnackBar.showInfoSnackBar(
                    context,
                    'Esse horário está sendo usado, escolha outro!',
                  );
                  return;
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    itemData['horarios'] = selected;
                  });
                });
              },
              validator: (selected) {
                if (selected == null || selected.isEmpty) {
                  return 'Por favor, selecione ao menos um horário';
                }
                return null;
              },
            ),
          )
        : const SizedBox();
  }
}
