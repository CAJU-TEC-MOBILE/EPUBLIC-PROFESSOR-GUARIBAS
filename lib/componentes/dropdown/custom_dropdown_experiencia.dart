import 'package:flutter/material.dart';
import '../../constants/app_tema.dart';

class CustomDropdownExperiencia extends StatefulWidget {
  final void Function(List<String>) onSelectionChanged;
  final List<String> returnoSelcionadas;

  const CustomDropdownExperiencia({
    super.key,
    required this.onSelectionChanged,
    this.returnoSelcionadas = const [],
  });

  @override
  _CustomDropdownExperienciaState createState() =>
      _CustomDropdownExperienciaState();
}

class _CustomDropdownExperienciaState extends State<CustomDropdownExperiencia> {
  List<String> experiencias = [
    "O eu, o outro e o nós",
    "Corpo, gestos e movimentos",
    "Escuta, fala, pensamento e imaginação",
    "Traços, sons, cores e formas",
    "Espaço, tempo, quantidades, relações e transformações",
  ];

  late List<String> experienciasSelecionadas;

  @override
  void initState() {
    super.initState();
    experienciasSelecionadas = List<String>.from(widget.returnoSelcionadas);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: experiencias.map((experiencia) {
        return Stack(
          children: [
            CheckboxListTile(
              hoverColor: AppTema.primaryAmarelo,
              activeColor: AppTema.primaryAmarelo,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(experiencia),
              // Verifica se a experiência está na lista selecionada
              value: experienciasSelecionadas.contains(experiencia),
              onChanged: (bool? selecionado) {
                setState(() {
                  if (selecionado == true) {
                    experienciasSelecionadas.add(experiencia);
                  } else {
                    experienciasSelecionadas.remove(experiencia);
                  }
                  widget.onSelectionChanged(
                      List<String>.from(experienciasSelecionadas));
                });
              },
            ),
          ],
        );
      }).toList(),
    );
  }
}
