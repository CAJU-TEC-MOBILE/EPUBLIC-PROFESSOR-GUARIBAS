import 'package:flutter/material.dart';
import '../../constants/app_tema.dart';
import '../../models/disciplina_model.dart';
import '../../models/gestao_ativa_model.dart';
import '../../services/adapters/gestao_ativa_service_adapter.dart';
import '../../services/controller/disciplina_controller.dart';

class CustomDisciplinasDialog extends StatefulWidget {
  final List<Disciplina> selectedDisciplinas;
  final ValueChanged<List<Disciplina>> onSelectedDisciplinas;

  const CustomDisciplinasDialog({
    super.key,
    required this.selectedDisciplinas,
    required this.onSelectedDisciplinas,
  });

  @override
  State<CustomDisciplinasDialog> createState() =>
      _CustomDisciplinasDialogWidgetState();
}

class _CustomDisciplinasDialogWidgetState
    extends State<CustomDisciplinasDialog> {
  List<Disciplina> disciplinas = [];
  bool isLoading = true;
  bool statusValidate = false;

  @override
  void initState() {
    super.initState();
    _initDialog();
  }

  Future<void> _initDialog() async {
    final gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();

    if (gestaoAtivaModel != null) {
      await _loadDisciplinas(gestaoAtivaModel);
    } else {
      debugPrint('Gestão ativa não encontrada.');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadDisciplinas(GestaoAtiva model) async {
    final disciplinaController = DisciplinaController();
    await disciplinaController.init();

    final fetchedDisciplinas =
        await disciplinaController.getAllDisciplinasPeloTurmaId(
      turmaId: model.idt_turma_id.toString(),
      idtId: model.idt_id.toString(),
    );

    setState(() {
      disciplinas = fetchedDisciplinas;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTema.backgroundColorApp,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      title: const Text(
        'Selecione as disciplinas dessa aula',
        style: TextStyle(fontSize: 18.0),
      ),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDisciplinaList(),
      actions: _buildDialogActions(context),
    );
  }

  Widget _buildDisciplinaList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      width: double.maxFinite,
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 8,
        child: ListView.builder(
          itemCount: disciplinas.length,
          itemBuilder: (context, index) {
            final disciplina = disciplinas[index];
            return CheckboxListTile(
              title: Text(disciplina.descricao),
              value: disciplina.checkbox,
              activeColor: AppTema.primaryAmarelo,
              onChanged: (bool? value) {
                setState(() {
                  disciplina.checkbox = value ?? false;
                });
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildDialogActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            statusValidate
                ? const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Nenhuma disciplina foi selecionada.',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  )
                : const SizedBox(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  style: _buildButtonStyle(),
                  onPressed: () {
                    setState(() => statusValidate = false);
                    setState(() {
                      for (var d in disciplinas) {
                        d.checkbox = false;
                        d.data = [];
                        d.data.add({
                          'conteudo': '',
                          'metodologia': '',
                          'horarios': [],
                        });
                      }
                      widget.selectedDisciplinas.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                ),
                TextButton(
                  style: _buildButtonStyle(),
                  onPressed: () {
                    setState(() => statusValidate = false);
                    for (var disciplina in disciplinas) {
                      if (disciplina.checkbox == false) {
                        disciplina.data = [];
                        disciplina.data.add({
                          'conteudo': '',
                          'metodologia': '',
                          'horarios': [],
                        });
                      }
                    }
                    final selecionadas =
                        disciplinas.where((d) => d.checkbox).toList();
                    widget.onSelectedDisciplinas(selecionadas);
                    statusValidate =
                        disciplinas.every((item) => item.checkbox == false);
                    if (statusValidate) {
                      setState(() => statusValidate);
                      return;
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  ButtonStyle _buildButtonStyle() {
    return TextButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: AppTema.texto,
      side: const BorderSide(color: AppTema.texto),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
