import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';

import '../../models/ano_model.dart';
import '../../services/controller/ano_controller.dart';

class CustomAnoDropdown extends StatefulWidget {
  const CustomAnoDropdown({super.key});

  @override
  _CustomAnoDropdownState createState() => _CustomAnoDropdownState();
}

class _CustomAnoDropdownState extends State<CustomAnoDropdown> {
  List<Ano> anos = [];
  Ano? selectedAno;

  @override
  void initState() {
    super.initState();
    getAll();
  }

  Future<void> getAll() async {
    AnoController anoController = AnoController();

    await anoController.init();

    anos = await anoController.getAll();

    anos.sort((a, b) => b.descricao!.compareTo(a.descricao.toString()));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTema.primaryDarkBlue),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          DropdownButton2<Ano>(
            hint: const Text('Ano'),
            value: selectedAno,
            onChanged: (Ano? newValue) {
              setState(() {
                selectedAno = newValue;
              });
            },
            items: _buildDropdownItems(),
            dropdownStyleData: const DropdownStyleData(
              maxHeight: 200,
              elevation: 1,
              width: 70.0,
              offset: Offset(-4, 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<Ano>> _buildDropdownItems() {
    return anos.map<DropdownMenuItem<Ano>>((Ano ano) {
      return DropdownMenuItem<Ano>(
        value: ano,
        child: Center(
          child: Text(
            ano.descricao.toString(),
          ),
        ),
      );
    }).toList();
  }
}
