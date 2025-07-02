import 'package:flutter/material.dart';
import '../../constants/app_tema.dart';
import '../../models/aula_model.dart';
import 'custom_circle_sync.dart';

class CustomFundamentalCard extends StatefulWidget {
  final Aula paginatedItems;
  final Future<void> Function() onSync;
  final Future<void> Function() onFrequencia;
  final Future<void> Function() onEdit;
  const CustomFundamentalCard({
    super.key,
    required this.paginatedItems,
    required this.onSync,
    required this.onFrequencia,
    required this.onEdit,
  });
  @override
  _CustomFundamentalCardState createState() => _CustomFundamentalCardState();
}

class _CustomFundamentalCardState extends State<CustomFundamentalCard> {
  @override
  Widget build(BuildContext context) {
    final aula = widget.paginatedItems;
    return Card(
      color: AppTema.primaryWhite,
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(right: BorderSide(color: aula.corSituacao, width: 15.0)),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(13.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(aula),
              if (aula.is_polivalencia != 1)
                _buildDisciplina(aula)
              else
                _buildDisciplinas(aula),
              _buildInfoRow('Tipo:', aula.tipoDeAula.toString()),
              _buildInfoRow('Situação:', aula.situacao.toString()),
              if (aula.is_polivalencia != 1)
                _buildHorario(aula)
              else
                _buildHorarios(aula),
              _buildActionButtons(aula),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Aula aula) {
    return Row(
      children: [
        const Icon(Icons.calendar_month_sharp,
            color: AppTema.primaryDarkBlue, size: 16.0),
        const SizedBox(width: 4.0),
        Text(aula.data, style: const TextStyle(color: AppTema.primaryDarkBlue)),
        const Spacer(),
        aula.id.isEmpty
            ? CustomCircleSync(aula: aula)
            : Row(
                children: [
                  const Text('#',
                      style: TextStyle(color: AppTema.primaryDarkBlue)),
                  const SizedBox(width: 4.0),
                  Text(aula.id.toString(),
                      style: const TextStyle(color: AppTema.primaryDarkBlue)),
                  CustomCircleSync(aula: aula),
                ],
              ),
      ],
    );
  }

  Widget _buildDisciplina(Aula aula) {
    return FutureBuilder<String>(
      future: aula.descricaoDisciplinaId,
      builder: (context, snapshot) {
        return _buildInfoRow('Disciplina:', snapshot.data ?? 'Sem descrição');
      },
    );
  }

  Widget _buildDisciplinas(Aula aula) {
    return FutureBuilder<String>(
      future: aula.id.isEmpty
          ? aula.disciplinasAulaLocal()
          : Future.value(aula.disciplinas_formatted),
      builder: (context, snapshot) {
        return _buildInfoRow(
            'Disciplinas:', snapshot.data ?? 'Sem disciplinas');
      },
    );
  }

  Widget _buildHorario(Aula aula) {
    return FutureBuilder<String>(
      future: aula.getDescricaoHorario(),
      builder: (context, snapshot) {
        return _buildInfoRow('Horário:', snapshot.data ?? '- - -');
      },
    );
  }

  Widget _buildHorarios(Aula aula) {
    return FutureBuilder<String>(
      future: aula.id.isEmpty
          ? aula.getHorariosAula()
          : Future.value(aula.horarios_formatted),
      builder: (context, snapshot) {
        return _buildInfoRow('Horários:', snapshot.data ?? 'Sem horários');
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTema.primaryDarkBlue, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: AppTema.primaryDarkBlue),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Aula aula) {
    return Row(
      children: [
        if (aula.id.isEmpty)
          _buildButton('Sincronizar', widget.onSync, Colors.grey[400]),
        const SizedBox(width: 8.0),
        if (aula.id.isEmpty)
          _buildButton(
              'Frequência', widget.onFrequencia, AppTema.primaryAmarelo),
        if (aula.id.isEmpty) ...[
          const SizedBox(width: 8.0),
          SizedBox(
            width: 88.0,
            child:
                _buildButton('Editar', widget.onEdit, AppTema.primaryDarkBlue),
          ),
        ],
      ],
    );
  }

  Widget _buildButton(
      String text, Future<void> Function() onPressed, Color? color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: color,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(text,
            style: const TextStyle(fontSize: 14, color: Colors.white)),
      ),
    );
  }
}
