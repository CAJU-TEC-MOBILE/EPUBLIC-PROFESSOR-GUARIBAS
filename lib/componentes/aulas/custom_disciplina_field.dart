import 'package:flutter/material.dart';

import '../../models/disciplina_model.dart';

class DisciplinaField extends StatefulWidget {
  final Disciplina item;
  final Map<String, dynamic> elemente;
  final String returnAndovalor;

  const DisciplinaField({
    super.key,
    required this.item,
    required this.elemente,
    required this.returnAndovalor,
  });

  @override
  _DisciplinaFieldState createState() => _DisciplinaFieldState();
}

class _DisciplinaFieldState extends State<DisciplinaField> {
  late TextEditingController conteudoController;

  @override
  void initState() {
    super.initState();
    // Inicializa o controlador com o valor atual de 'conteudo'
    conteudoController =
        TextEditingController(text: widget.elemente['conteudo'] ?? '');
  }

  @override
  void dispose() {
    conteudoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLabel('${widget.item.descricao}:'),
        _buildTextField(conteudoController, 'Por favor, preencha o conteúdo'),
        // Exibir o valor retornado
        Text('Valor retornado: ${widget.returnAndovalor}'),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String validationMessage) {
    return Column(
      children: [
        TextFormField(
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
            print('value: $value');
            widget.elemente['conteudo'] = value;
            setState(() {});
          },
          validator: (value) {
            if (value!.isEmpty) {
              return validationMessage;
            }
            return null;
          },
        ),
      ],
    );
  }
}
