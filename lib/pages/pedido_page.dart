import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/drawer/custom_drawer.dart';
import '../constants/app_tema.dart';
import '../providers/autorizacao_provider.dart';
import '../wigets/cards/custom_pedido_card.dart';

class PedidoPage extends StatefulWidget {
  const PedidoPage({super.key});

  @override
  _PedidoPageState createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider =
            Provider.of<AutorizacaoProvider>(context, listen: false);
        provider.listarAutorizacoes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AutorizacaoProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
        title: const Text(
          'Pedidos',
          style: TextStyle(
            color: AppTema.primaryDarkBlue,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.sync,
              color: Colors.black,
              size: 25,
            ),
            onPressed: () async => await provider.secronizar(context: context),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: provider.autorizacoes.isEmpty
          ? const Center(
              child: Text('No momento, não há pedidos para exibir.'),
            )
          : ListView.builder(
              itemCount: provider.autorizacoes.length,
              itemBuilder: (context, index) {
                final item = provider.autorizacoes[index];
                return CustomPedidoCard(
                  item: item,
                );
              },
            ),
    );
  }
}
