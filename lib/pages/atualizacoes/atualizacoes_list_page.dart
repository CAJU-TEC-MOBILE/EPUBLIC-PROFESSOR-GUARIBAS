import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/componentes/global/user_info_componente.dart';
import 'package:professor_acesso_notifiq/data/atualizacoes_data.dart';

class AtualizacoesListPage extends StatelessWidget {
  const AtualizacoesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Versões'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserInfoComponente(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: itensListAtualizacoes.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /*Text(
                        itensListAtualizacoes[index].titulo,
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w500),
                      ),*/
                      Text(
                        itensListAtualizacoes[index].versao,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  children: <Widget>[
                    ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            itensListAtualizacoes[index].descricao,
                            // style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
