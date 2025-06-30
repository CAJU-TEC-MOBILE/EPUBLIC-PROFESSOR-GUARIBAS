import 'package:flutter/material.dart';
import '../models/etapa_model.dart';

class CustomPeriodoCard extends StatefulWidget {
  final Etapa etapa;
  final bool isBloqueada;
  final VoidCallback onPressed;

  const CustomPeriodoCard({
    super.key,
    required this.etapa,
    this.isBloqueada = false,
    required this.onPressed,
  });

  @override
  State<CustomPeriodoCard> createState() => _CustomPeriodoCardState();
}

class _CustomPeriodoCardState extends State<CustomPeriodoCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.etapa.descricao,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Início: ${widget.etapa.ptBrInicio}'),
                    Text('Fim: ${widget.etapa.ptBrFim}'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        if (widget.isBloqueada) _buildAvisoBloqueio(),
      ],
    );
  }

  Widget _buildAvisoBloqueio() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.black54,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Atenção! Essa etapa está bloqueada. Para lançar aulas, você deve solicitar uma autorização clicando no botão abaixo.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black54,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
              ),
              child: const Text(
                'Solicitar Autorização',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
