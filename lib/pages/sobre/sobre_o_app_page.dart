import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/data/retornar_data_ano_atual.dart';

class SobreAppPage extends StatefulWidget {
  const SobreAppPage({super.key});

  @override
  State<SobreAppPage> createState() => _SobreAppPageState();
}

class _SobreAppPageState extends State<SobreAppPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 10),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/logo_caju.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Esse aplicativo é usado juntamente com o sistema de gestão escolar E-Public, ' +
                    'incluindo diversas tecnologias e recursos que facilitam o registro de aulas, frequência e outros recursos de forma online e offline.' +
                    '',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 150,
              ),
              Text('\u{00A9} Caju Tecnologia' + ' ' + retornarDataAnoAtual())
            ],
          ),
        ),
      ),
    );
  }
}
