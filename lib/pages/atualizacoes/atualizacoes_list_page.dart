import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../componentes/global/user_info_componente.dart';
import '../../data/atualizacoes_data.dart';

class AtualizacoesListPage extends StatefulWidget {
  const AtualizacoesListPage({super.key});

  @override
  State<AtualizacoesListPage> createState() => _AtualizacoesListPageState();
}

class _AtualizacoesListPageState extends State<AtualizacoesListPage> {
  final SobreApp sobreApp = SobreApp();
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await dotenv.load(fileName: ".env");
    await sobreApp.carregarInformacoesDoApp();
    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Versões'),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UserInfoComponente(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sobreApp.listaAtualizacoes.length,
                    itemBuilder: (context, index) {
                      final atualizacao = sobreApp.listaAtualizacoes[index];
                      return ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              atualizacao.versao,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  atualizacao.titulo,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(atualizacao.descricao),
                                const SizedBox(height: 4),
                                Text(
                                  'Data: ${atualizacao.data}',
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
