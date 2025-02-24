import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';

import '../../models/aula_model.dart';

// ignore: must_be_immutable
class DadosDaGestaoCardComponente extends StatelessWidget {
  final String? selecionandoId;
  final String? dataDaAula;
  final Aula? aula;
  DadosDaGestaoCardComponente(
      {super.key, this.selecionandoId, this.dataDaAula, this.aula});
  GestaoAtiva? gestaoAtivaModel =
      GestaoAtivaServiceAdapter().exibirGestaoAtiva();
  double cardFont = 12.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 3.0),
      child: Card(
        elevation: 1.0,
        borderOnForeground: true,
        color: AppTema.primaryWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.calendar_month_sharp,
                              color: AppTema.primaryDarkBlue,
                              size: 17.0,
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                aula!.dataDaAulaPtBr.toString(),
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: AppTema.primaryDarkBlue,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (selecionandoId != null)
                              Text(
                                '#${selecionandoId!.toString()}',
                                style: TextStyle(
                                  fontSize: cardFont,
                                  color: AppTema.primaryDarkBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: Row(
                            children: [
                              const Text(
                                'Escola: ',
                                style: TextStyle(
                                  color: AppTema.primaryDarkBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  gestaoAtivaModel!.configuracao_descricao
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: cardFont,
                                    color: AppTema.primaryDarkBlue,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: Row(
                            children: [
                              const Text(
                                'Professor:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTema.primaryDarkBlue,
                                ),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Expanded(
                                child: Text(
                                  gestaoAtivaModel!.instrutor_nome.toString(),
                                  style: TextStyle(
                                    color: AppTema.primaryDarkBlue,
                                    fontSize: cardFont,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Row(
                  children: [
                    const Text(
                      'Turma: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTema.primaryDarkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      child: gestaoAtivaModel!.turma_descricao.length > 35
                          ? Tooltip(
                              message:
                                  gestaoAtivaModel!.turma_descricao.toString(),
                              child: Text(
                                '${gestaoAtivaModel!.turma_descricao.toString().substring(0, 35)}...',
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  color: AppTema.primaryDarkBlue,
                                ),
                              ),
                            )
                          : Text(
                              gestaoAtivaModel!.turma_descricao.toString(),
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: AppTema.primaryDarkBlue,
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              aula!.is_polivalencia != 1
                  ? Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Row(
                        children: [
                          const Text(
                            'Disciplina: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTema.primaryDarkBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            child:
                                gestaoAtivaModel!.disciplina_descricao.length >
                                        35
                                    ? Tooltip(
                                        message: gestaoAtivaModel!
                                            .disciplina_descricao
                                            .toString(),
                                        child: Text(
                                          '${gestaoAtivaModel!.disciplina_descricao.toString().substring(0, 35)}...',
                                          style: const TextStyle(fontSize: 13),
                                        ))
                                    : Text(
                                        gestaoAtivaModel!.disciplina_descricao
                                            .toString(),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            const Text(
                              'Disciplinas:',
                              style: TextStyle(
                                color: AppTema.primaryDarkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            aula!.id.toString().isEmpty
                                ? Expanded(
                                    child: FutureBuilder<String>(
                                      future: aula!.disciplinasAulaLocal(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox();
                                        }
                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }
                                        if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return const Text(
                                              'No disciplines available.');
                                        }
                                        return Text(
                                          snapshot.data!.toString(),
                                          style: const TextStyle(
                                            color: AppTema.primaryDarkBlue,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        );
                                      },
                                    ),
                                  )
                                : Text(
                                    aula!.disciplinas_formatted.toString(),
                                    style: const TextStyle(
                                      color: AppTema.primaryDarkBlue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                          ],
                        ),
                      ),
                    ),
              // if (selecionandoId != null)
              //   Row(
              //     children: [
              //       const Text(
              //         'Data da aula: ',
              //         style:
              //             TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              //       ),
              //       Text(
              //         dataDaAula.toString(),
              //         style: const TextStyle(),
              //       ),
              //     ],
              //   ),
              // const SizedBox(
              //   height: 10,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
