import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/emojis.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';

class SemRelacaoDiaHorarioParaCriar extends StatelessWidget {
  final GestaoAtiva? gestaoAtivaModel =
      GestaoAtivaServiceAdapter().exibirGestaoAtiva();
  SemRelacaoDiaHorarioParaCriar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gestaoAtivaModel!.turma_sistema_bncc_id != ''
            ? 'Criar Aula Infantil'
            : 'Criar Aula'),
      ),
      body: Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Criação de aula indisponível ${Emojis.noEntrySign}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Infelizmente não há horário(s) e dia(s) vinculado(s) a sua gestão. Por favor, entre em contato com a coordenação.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          )),
    );
  }
}
