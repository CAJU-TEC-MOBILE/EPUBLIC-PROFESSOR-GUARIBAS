// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../models/autorizacao_model.dart';

class CustomPedidoCard extends StatefulWidget {
  AutorizacaoModel item;
  CustomPedidoCard({
    super.key,
    required this.item,
  });

  @override
  State<CustomPedidoCard> createState() => _CustomPedidoCardState();
}

class _CustomPedidoCardState extends State<CustomPedidoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: widget.item.corSituacao,
              width: 15.0,
            ),
          ),
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
              Row(
                children: [
                  widget.item.id.isNotEmpty
                      ? Row(
                          children: [
                            const Text(
                              '#',
                              style: TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            const SizedBox(
                              width: 2.0,
                            ),
                            Text(
                              widget.item.id,
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  const Spacer(),
                  widget.item.data.isNotEmpty
                      ? Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 14.0,
                            ),
                            const SizedBox(
                              width: 2.0,
                            ),
                            Text(
                              widget.item.dataBr,
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
              Row(
                children: [
                  const Text('Descrição:'),
                  const SizedBox(
                    width: 4.0,
                  ),
                  FutureBuilder<String>(
                    future: widget.item.descricaoTipo,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Carregando...');
                      } else if (snapshot.hasError) {
                        return const Text('Erro ao carregar');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Descrição não encontrada');
                      }
                      return Text(snapshot.data!);
                    },
                  ),
                ],
              ),
              // Row(
              //   children: [
              //     const Text('Solicitante:'),
              //     const SizedBox(
              //       width: 4.0,
              //     ),
              //     FutureBuilder<String>(
              //       future: widget.item.solicitante,
              //       builder: (context, snapshot) {
              //         if (snapshot.connectionState == ConnectionState.waiting) {
              //           return const Text('Carregando...');
              //         } else if (snapshot.hasError) {
              //           return const Text('Erro ao carregar');
              //         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //           return const Text('---');
              //         }
              //         return Text(snapshot.data!);
              //       },
              //     ),
              //   ],
              // ),
              Row(
                children: [
                  const Text('Avaliador:'),
                  const SizedBox(
                    width: 4.0,
                  ),
                  FutureBuilder<String>(
                    future: widget.item.avaliador,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Carregando...');
                      } else if (snapshot.hasError) {
                        return const Text('Erro ao carregar');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('---');
                      }
                      return Text(snapshot.data!);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Etapa:'),
                  const SizedBox(
                    width: 4.0,
                  ),
                  FutureBuilder<String?>(
                    future: widget.item.etapa,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Carregando...');
                      } else if (snapshot.hasError) {
                        return const Text('Erro ao carregar');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('---');
                      }
                      return Text(snapshot.data.toString());
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Situação:'),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Text(widget.item.status.toString())
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
