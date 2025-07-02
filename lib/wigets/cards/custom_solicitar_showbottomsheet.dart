import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_tema.dart';
import '../../models/avaliador_model.dart';
import '../../models/etapa_model.dart';
import '../../models/gestao_ativa_model.dart';
import '../../models/solicitacao_model.dart';
import '../../providers/autorizacao_provider.dart';
import '../../utils/validador.dart';

class CustomSolicitarShowBottomSheet {
  static void show(
    BuildContext context, {
    required GestaoAtiva gestaoAtiva,
    required Etapa etapa,
    required List<AvaliadorModel> avaliadores,
    required List<SolicitacaoModel> solicitacoes,
    AvaliadorModel? avaliador,
    SolicitacaoModel? solicitacao,
  }) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController obsController = TextEditingController();
    SolicitacaoModel? solicitacaoSelecionada = solicitacao;
    AvaliadorModel? avaliadorSelecionado = avaliador;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final providerAutorizacao = Provider.of<AutorizacaoProvider>(context);
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido de Autorização',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              etapa.descricao,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Início: ${etapa.ptBrInicio}'),
                                Text('Fim: ${etapa.ptBrFim}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Solicitação',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<SolicitacaoModel>(
                      validator: (value) => Validador.validarObjectObrigatorio(
                        value,
                        nomeCampo: 'Solicitação',
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            width: 1,
                          ),
                        ),
                      ),
                      value: solicitacaoSelecionada,
                      items: solicitacoes.map((SolicitacaoModel model) {
                        return DropdownMenuItem<SolicitacaoModel>(
                          value: model,
                          child: Text(
                            model.descricao.toString().toUpperCase(),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        solicitacaoSelecionada = value;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Avaliador(a)',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<AvaliadorModel>(
                      validator: (value) => Validador.validarObjectObrigatorio(
                        value,
                        nomeCampo: 'Avaliador(a)',
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            width: 1,
                          ),
                        ),
                      ),
                      value: avaliadorSelecionado,
                      items: avaliadores.map((AvaliadorModel model) {
                        return DropdownMenuItem<AvaliadorModel>(
                          value: model,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 100,
                            child: Text(
                              model.name.toString().toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        avaliadorSelecionado = value;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Observações',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: obsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide: BorderSide(
                              color: AppTema.primaryDarkBlue, width: 1.0),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide: BorderSide(
                              color: AppTema.primaryDarkBlue, width: 1.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.trim().isNotEmpty &&
                            value.length > 100) {
                          return 'Máximo de 100 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: Navigator.of(context).pop,
                          child: const Text("Cancelar"),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState?.validate() ?? false) {
                              bool status = await providerAutorizacao.solicitar(
                                context: context,
                                etapaId: etapa.id,
                                pedidoId: solicitacaoSelecionada!.id.toString(),
                                instrutorDisciplinaTurmaId: gestaoAtiva
                                    .instrutorDisciplinaTurma_id
                                    .toString(),
                                observacoes: obsController.text,
                                userAprovador:
                                    avaliadorSelecionado!.id.toString(),
                              );
                              if (status) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text("Enviar"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
