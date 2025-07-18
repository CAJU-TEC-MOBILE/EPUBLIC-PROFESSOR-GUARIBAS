import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';
import '../../models/aula_model.dart';

class DadosDaGestaoCardComponente extends StatelessWidget {
  final String? selecionandoId;
  final String? dataDaAula;
  final Aula? aula;

  DadosDaGestaoCardComponente({
    super.key,
    this.selecionandoId,
    this.dataDaAula,
    this.aula,
  });

  GestaoAtiva? gestaoAtivaModel =
      GestaoAtivaServiceAdapter().exibirGestaoAtiva();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Data da Aula
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_sharp,
                    color: AppTema.primaryDarkBlue,
                    size: 18.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    aula!.dataDaAulaPtBr.toString(),
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppTema.primaryDarkBlue,
                    ),
                  ),
                ],
              ),

              // Escola
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Text(
                    'Escola: ',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: AppTema.primaryDarkBlue,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      gestaoAtivaModel!.configuracao_descricao.toString(),
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: AppTema.primaryDarkBlue,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Professor
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Text(
                    'Professor: ',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: AppTema.primaryDarkBlue,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      gestaoAtivaModel!.instrutor_nome.toString(),
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: AppTema.primaryDarkBlue,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Turma
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Text(
                    'Turma: ',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: AppTema.primaryDarkBlue,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      gestaoAtivaModel!.turma_descricao.toString(),
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: AppTema.primaryDarkBlue,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Disciplina
              // const SizedBox(height: 8.0),
              // Row(
              //   children: [
              //     const Text(
              //       'Disciplina: ',
              //       style: TextStyle(
              //         fontSize: 14.0,
              //         fontWeight: FontWeight.bold,
              //         color: AppTema.primaryDarkBlue,
              //       ),
              //     ),
              //     Expanded(
              //       child: Text(
              //         gestaoAtivaModel!.disciplina_descricao.toString(),
              //         style: const TextStyle(
              //           fontSize: 14.0,
              //           color: AppTema.primaryDarkBlue,
              //         ),
              //         softWrap: true,
              //         overflow: TextOverflow.ellipsis,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
