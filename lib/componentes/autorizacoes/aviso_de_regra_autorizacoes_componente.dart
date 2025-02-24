import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/data/converter_data_americana_para_brasileira.dart';
import 'package:professor_acesso_notifiq/models/autorizacao_model.dart';
import 'package:professor_acesso_notifiq/models/etapa_model.dart';
import 'package:professor_acesso_notifiq/pages/autorizacoes/criar_autorizacao_page.dart';

class AvisoDeRegraAutorizacoesComponente extends StatefulWidget {
  final Etapa? etapa_selecionada_objeto;
  final Autorizacao? autorizacaoSelecionada;
  final String? statusDaAutorizacao;
  final bool dataLogicaExpiracao;
  final bool dataEtapaValida;

  const AvisoDeRegraAutorizacoesComponente(
      {super.key,
      required this.etapa_selecionada_objeto,
      required this.autorizacaoSelecionada,
      required this.statusDaAutorizacao,
      required this.dataLogicaExpiracao,
      required this.dataEtapaValida});
  @override
  State<AvisoDeRegraAutorizacoesComponente> createState() =>
      _AvisoDeRegraAutorizacoesComponenteState();
}

class _AvisoDeRegraAutorizacoesComponenteState
    extends State<AvisoDeRegraAutorizacoesComponente> {
  @override
  Widget build(BuildContext context) {
    Widget layout = Container();
    if (!widget.dataEtapaValida &&
        (widget.statusDaAutorizacao == 'INICIO' ||
            widget.statusDaAutorizacao == 'SEM RETORNO')) {
      layout = Container(
        margin: const EdgeInsets.only(
          bottom: 8.0,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: Center(
              child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppTema.error,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Aviso',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ('Etapa bloqueada. Para lançar uma aula você deve solicitar uma autorização.'),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: AppTema.primaryDarkBlue,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CriarAutorizacaoPage(
                            etapa: widget.etapa_selecionada_objeto,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Solicitar autorização',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          )),
        ),
      );
    }
    if (widget.statusDaAutorizacao == 'APROVADO') {
      layout = Container(
        margin: const EdgeInsets.only(bottom: 8.0, top: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    color: AppTema.primaryAzul,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Aviso',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ('O pedido para esta etapa foi aceito. Crie a aula até ${converterDataAmericaParaBrasil(dataString: widget.autorizacaoSelecionada!.dataExpiracao.toString())}.'),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (widget.statusDaAutorizacao == 'PENDENTE') {
      layout = Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    color: AppTema.error,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Aviso',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ('A autorização para esta etapa foi enviada. Aguarde o retorno.'),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (widget.statusDaAutorizacao == 'CANCELADO') {
      layout = Container(
        margin: const EdgeInsets.only(
          bottom: 8.0,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    color: AppTema.error,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Aviso',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ('Sua última autorização para esta etapa foi negada. Solicite outro pedido abaixo se necessário.'),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppTema.primaryDarkBlue,  
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CriarAutorizacaoPage(
                          etapa: widget.etapa_selecionada_objeto,
                        ),
                      ),
                    );
                  },
                  child: const Text('Solicitar autorização'),
                )
              ],
            ),
          ),
        ),
      );
    }
    return layout;
  }
}
