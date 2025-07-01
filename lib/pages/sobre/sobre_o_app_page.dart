import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:professor_acesso_notifiq/functions/aplicativo/data/retornar_data_ano_atual.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SobreAppPage extends StatefulWidget {
  const SobreAppPage({super.key});

  @override
  State<SobreAppPage> createState() => _SobreAppPageState();
}

class _SobreAppPageState extends State<SobreAppPage> {
  String appVerso = '';
  String numeroBuild = '';
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  Future<void> configuracaoEnv() async {
    appVerso = dotenv.env['VERSAO'] ?? 'Default Verso';
    setState(() => appVerso);
  }

  @override
  void initState() {
    super.initState();
    configuracaoEnv();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    numeroBuild = info.buildNumber;
    setState(() {
      numeroBuild;
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Esse aplicativo é usado juntamente com o sistema de gestão escolar E-Public, incluindo diversas tecnologias e recursos que facilitam o registro de aulas, frequência e outros recursos de forma online e offline.',
              textAlign: TextAlign.justify,
            ),
            const SizedBox(
              height: 150,
            ),
            Text('\u{00A9} Caju Tecnologia ${retornarDataAnoAtual()}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$numeroBuild ($appVerso)",
                  style: const TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
