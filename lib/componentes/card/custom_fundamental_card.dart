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
  // ignore: library_private_types_in_public_api
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
          border: Border(
              right: BorderSide(
            color: aula.corSituacao,
            width: 15.0,
          )),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(13.0),
          ),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_sharp,
                            color: AppTema.primaryDarkBlue,
                            size: 16.0,
                          ),
                          const SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            aula.dataDaAulaPtBr,
                            style:
                                const TextStyle(color: AppTema.primaryDarkBlue),
                          ),
                        ],
                      ),
                      const Spacer(),
                      aula.id.isEmpty
                          ? CustomCircleSync(
                              aula: aula,
                            )
                          : Row(
                              children: [
                                const Text(
                                  '#',
                                  style:
                                      TextStyle(color: AppTema.primaryDarkBlue),
                                ),
                                const SizedBox(
                                  width: 0.0,
                                ),
                                Text(
                                  aula.id.toString(),
                                  style: const TextStyle(
                                      color: AppTema.primaryDarkBlue),
                                ),
                                CustomCircleSync(
                                  aula: aula,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                aula.is_polivalencia != 1
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Text(
                              'Disciplina:',
                              style: TextStyle(
                                color: AppTema.primaryDarkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            FutureBuilder<String>(
                              future: aula.descricaoDisciplinaId,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return const Text(
                                    'Erro ao carregar a descrição',
                                    style: TextStyle(
                                      color: AppTema.primaryDarkBlue,
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data ?? 'Sem descrição',
                                    style: const TextStyle(
                                      color: AppTema.primaryDarkBlue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                } else {
                                  return const Text(
                                    'Sem descrição',
                                    style: TextStyle(
                                      color: AppTema.primaryDarkBlue,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
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
                              aula.id.toString().isEmpty
                                  ? Expanded(
                                      child: FutureBuilder<String>(
                                        future: aula.disciplinasAulaLocal(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
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
                                      aula.disciplinas_formatted.toString(),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Tipo:',
                        style: TextStyle(
                          color: AppTema.primaryDarkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        aula.tipoDeAula.toString(),
                        style: const TextStyle(
                          color: AppTema.primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Situação:',
                        style: TextStyle(
                          color: AppTema.primaryDarkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        aula.situacao.toString(),
                        style: const TextStyle(
                          color: AppTema.primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: aula.is_polivalencia != 1
                      ? Row(
                          children: [
                            const Text(
                              'Horário:',
                              style: TextStyle(
                                color: AppTema.primaryDarkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            FutureBuilder<String>(
                              future: aula.descricaoHorarioPeloIdHorario,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Erro: ${snapshot.error}');
                                } else if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data!,
                                    style: const TextStyle(
                                      color: AppTema.primaryDarkBlue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                } else {
                                  return const Text(
                                    'Sem Horário',
                                    style: TextStyle(
                                      color: AppTema.primaryDarkBlue,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Text(
                              'Horários:',
                              style: TextStyle(
                                color: AppTema.primaryDarkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            aula.id.toString().isEmpty
                                ? FutureBuilder<String>(
                                    future: aula.getHorariosAula(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Erro: ${snapshot.error}');
                                      } else if (snapshot.hasData) {
                                        return Text(
                                          snapshot.data!,
                                          style: const TextStyle(
                                            color: AppTema.primaryDarkBlue,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        );
                                      } else {
                                        return const Text(
                                          'Sem Horários',
                                          style: TextStyle(
                                              color: AppTema.primaryDarkBlue),
                                        );
                                      }
                                    },
                                  )
                                : Text(
                                    aula.horarios_formatted.toString(),
                                    style: const TextStyle(
                                      color: AppTema.primaryDarkBlue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                          ],
                        ),
                ),
                Row(
                  children: [
                    aula.id.toString() == ''
                        ? ElevatedButton(
                            onPressed: widget.onSync,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.grey[400],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sincronizar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                    Padding(
                      padding: aula.id.toString().isEmpty
                          ? const EdgeInsets.only(left: 8.0)
                          : const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: widget.onFrequencia,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(5.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: AppTema.primaryAmarelo,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Frequência',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    aula.id.toString().isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 90.0,
                              child: ElevatedButton(
                                onPressed: widget.onEdit,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: AppTema.primaryDarkBlue,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Editar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
