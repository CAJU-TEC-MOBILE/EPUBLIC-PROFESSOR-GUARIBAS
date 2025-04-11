import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/models/professor_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/auth_service_adapter.dart';

import '../../help/console_log.dart';

class DadosProfessorComponente extends StatefulWidget {
  const DadosProfessorComponente({super.key});

  @override
  _DadosProfessorComponenteState createState() =>
      _DadosProfessorComponenteState();
}

class _DadosProfessorComponenteState extends State<DadosProfessorComponente> {
  Professor? professor;

  @override
  void initState() {
    super.initState();
    // carregarDados();
  }

  void carregarDados() {
    try {
      AuthServiceAdapter authService = AuthServiceAdapter();
      Professor professorData = authService.exibirProfessor();

      if (professorData.id != null) {
        setState(() {
          professor = professorData;
        });
        ConsoleLog.mensagem(
          titulo: 'Sucesso: dados do professor',
          mensagem: professor.toString(),
          tipo: 'sucesso',
        );
      } else {
        ConsoleLog.mensagem(
          titulo: 'Aviso',
          mensagem: 'Nenhum dado disponível para o professor.',
          tipo: 'aviso',
        );
      }
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'Erro ao carregar dados do professor',
        mensagem: e.toString(),
        tipo: 'erro',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return professor!.id.isNotEmpty
        ? Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Text('Matricula:'),
                        const SizedBox(width: 4.0),
                        professor?.matricula.isNotEmpty == true
                            ? Text(
                                professor!.matricula,
                                style: const TextStyle(fontSize: 15),
                              )
                            : const Text(
                                '- - -',
                                style: TextStyle(fontSize: 15),
                              ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Código: ${professor?.codigo ?? '- - -'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Vínculo: ${professor?.vinculo ?? '- - -'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'E-mail: ${professor?.email ?? '- - -'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Etnia: ${professor?.corOuRaca ?? '- - -'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Data de nascimento: ${professor?.dataNascimento ?? '- - -'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Endereço',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cep: ${professor?.cep ?? '- - -'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Município: ${professor?.municipalidade ?? '- - -'} - ${professor?.estadualidade ?? '- - -'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Zona de residência: ${professor?.zonaResidencia ?? '- - -'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Município residencia:  ${professor?.municipioResidencia ?? '- - -'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Filiação',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      professor?.filiacao1 ?? '- - -',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      professor?.filiacao2 ?? '- - -',
                      style: const TextStyle(fontSize: 14),
                    ),
                    //Text(professor?.toString() ?? '- - -'),
                  ],
                ),
              ),
            ],
          )
        : const CircularProgressIndicator();
  }
}
