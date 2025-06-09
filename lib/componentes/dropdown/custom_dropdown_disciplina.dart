import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/models/disciplina_model.dart';

class CustomMultiSelectDropdown extends StatefulWidget {
  final List<Disciplina> data;
  final ValueChanged<List<Disciplina>> onConfirm;

  const CustomMultiSelectDropdown({
    super.key,
    required this.data,
    required this.onConfirm,
  });

  @override
  _CustomMultiSelectDropdownState createState() =>
      _CustomMultiSelectDropdownState();
}

class _CustomMultiSelectDropdownState extends State<CustomMultiSelectDropdown> {
  final List<Disciplina> _selectedDisciplinas = [];
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();
    _selectedDisciplinas.clear();
    _isSelected = List.generate(widget.data.length, (index) => false);
  }

  void addDisciplina(Disciplina item) {
    _selectedDisciplinas.add(item);
  }

  void removeDisciplina(Disciplina item) {
    _selectedDisciplinas.remove(item);
  }

  void clearSelectedDisciplinas() {
    setState(() {
      _selectedDisciplinas.clear();
      _isSelected.fillRange(0, _isSelected.length, false);

      for (var disciplina in widget.data) {
        disciplina.checkbox = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTitle(),
        _buildDropdownButton(),
      ],
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: const Text(
        'Selecione as Disciplinas',
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  Widget _buildDropdownButton() {
    return ElevatedButton(
      onPressed:
          widget.data.isEmpty ? null : () => _showMultiSelectDialog(context),
      child: const Text('Selecione as Disciplinas dessa Aula:'),
    );
  }

  void _showMultiSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            elevation: 0.0,
            title: const Text('Selecione as Disciplinas'),
            content: SingleChildScrollView(
              child: ListBody(
                children: List.generate(widget.data.length, (index) {
                  return CheckboxListTile(
                    activeColor: AppTema.primaryAmarelo,
                    title: Text(widget.data[index].descricao),
                    value: _isSelected[index],
                    onChanged: (bool? selected) {
                      setState(() {
                        _isSelected[index] = selected ?? false;
                        widget.data[index].checkbox = _isSelected[index];

                        if (widget.data[index].data == null) {
                          widget.data[index].data = [];
                        }

                        if (_isSelected[index]) {
                          widget.data[index].data!.add({
                            'conteudo': '',
                            'metodologia': '',
                            'horarios': []
                          });
                          addDisciplina(widget.data[index]);
                        } else {
                          removeDisciplina(widget.data[index]);
                        }
                      });
                    },
                  );
                }),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  widget.onConfirm([]);
                  clearSelectedDisciplinas();
                  Navigator.of(context).pop(true);
                },
                child: const Text('Limpar Seleções'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  widget.onConfirm(_selectedDisciplinas);
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
