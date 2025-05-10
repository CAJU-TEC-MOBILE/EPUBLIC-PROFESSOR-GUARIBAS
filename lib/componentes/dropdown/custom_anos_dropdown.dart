import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/models/auth_model.dart';
import '../../models/ano_model.dart';
import '../../pages/home_page.dart';
import '../../services/adapters/gestao_ativa_service_adapter.dart';
import '../../services/adapters/gestoes_service_adpater.dart';
import '../../services/connectivity/connectivity_service.dart';
import '../../services/connectivity/internet_connectivity_service.dart';
import '../../services/controller/ano_controller.dart';
import '../../services/controller/ano_selecionado_controller.dart';
import '../../services/controller/auth_controller.dart';
import '../../services/http/gestoes/gestoes_disciplinas_http.dart';
import '../dialogs/custom_snackbar.dart';
import '../global/preloader.dart';

class CustomAnosDropdown extends StatefulWidget {
  const CustomAnosDropdown({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomAnosDropdownState createState() => _CustomAnosDropdownState();
}

class _CustomAnosDropdownState extends State<CustomAnosDropdown>
    with SingleTickerProviderStateMixin {
  List<Ano> anos = [];
  Ano? selectedAno;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    getAll();
    getUserAno();
  }

  @override
  Future<void> getAll() async {
    AnoController anoController = AnoController();
    await anoController.init();
    anos = await anoController.getAll();

    anos.sort((a, b) => b.descricao.compareTo(a.descricao));

    setState(() {});
  }

  Future<void> getUserAno() async {
    final authController = AuthController();
    final anoSelecionadoController = AnoSelecionadoController();

    await anoSelecionadoController.init();
    await authController.init();

    Auth? auth = await authController.getAuth();

    int authId = int.parse(auth!.id.toString());
    int anoId = int.parse(auth.anoId.toString());

    await anoSelecionadoController.setAnoPorAuth(anoId: anoId);

    Ano ano = await anoSelecionadoController.getAnoSelecionado();

    setState(() => selectedAno = ano);
  }

  Future<void> setSelectedAno(
      {required Ano ano, required BuildContext context}) async {
    showLoading(context);
    setState(() => loading = true);

    final anoSelecionadoController = AnoSelecionadoController();
    bool isConnectedNotifier = await InternetConnectivityService.isConnected();

    if (!isConnectedNotifier) {
      hideLoading(context);
      setState(() => loading = false);
      CustomSnackBar.showErrorSnackBar(
        context,
        'Você está offline no momento. Verifique sua conexão com a internet.',
      );

      await Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
      return;
    }

    final authController = AuthController();

    await anoSelecionadoController.init();

    await authController.init();

    //Auth? auth = await authController.getAuth();

    // int authId = int.parse(auth!.id.toString());

    int anoId = int.parse(ano.id.toString());

    await anoSelecionadoController.setAnoSelecionado(ano);

    ano = await anoSelecionadoController.getAnoSelecionado();

    await authController.updateAnoId(anoId: anoId);

    await recarregarPageParaObterNovasGestoes();

    await getFranquiaAtualHttp();

    setState(() => selectedAno = ano);

    await Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
    setState(() => loading = false);
    hideLoading(context);
  }

  Future<void> recarregarPageParaObterNovasGestoes() async {
    await GestoesService().atualizarGestoes(context);
  }

  Future<void> getFranquiaAtualHttp() async {
    GestaoDisciplinaHttp gestaoDisciplinaHttp = GestaoDisciplinaHttp();
    await gestaoDisciplinaHttp.getGestaoDisciplinas();
  }

  @override
  Widget build(BuildContext context) {
    return loading != true
        ? PopupMenuButton<Ano>(
            onSelected: (Ano ano) {
              setSelectedAno(ano: ano, context: context);
            },
            itemBuilder: (context) => [
              ...anos.map(
                (ano) => PopupMenuItem<Ano>(
                  value: ano,
                  child: ListTile(
                    title: Center(
                      child: Text(
                        ano.descricao,
                        style: const TextStyle(fontSize: 12.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            constraints: const BoxConstraints(
              minWidth: 80.0,
              maxWidth: 100.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Container(
              width: 66.0,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(color: AppTema.primaryDarkBlue),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      selectedAno?.descricao ?? 'Ano',
                      style: const TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTema.primaryDarkBlue),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      padding: const EdgeInsets.all(2.0),
                      child: const Icon(
                        Icons.edit,
                        size: 12.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : Container(
            width: 66.0,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: AppTema.primaryDarkBlue),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: LoadingAnimationWidget.waveDots(
                color: AppTema.primaryDarkBlue,
                size: 24.0,
              ),
            ),
          );
  }
}
