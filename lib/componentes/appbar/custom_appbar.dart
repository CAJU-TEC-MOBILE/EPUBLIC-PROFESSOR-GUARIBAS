import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';

import '../../models/disciplina_model.dart';
import '../../models/gestao_ativa_model.dart';
import '../../services/adapters/gestao_ativa_service_adapter.dart';
import '../../services/controller/disciplina_controller.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  VoidCallback onPressedSynchronizer;

  CustomAppBar({
    super.key,
    required this.onPressedSynchronizer,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _CustomAppBarState extends State<CustomAppBar> {
  GestaoAtiva? gestaoAtivaModel;
  bool status = false;
  String descricaoString = '';
  List<Disciplina> disciplinas = [];

  @override
  void initState() {
    super.initState();
    carregarGestaoAtiva();
  }

  Future<void> carregarGestaoAtiva() async {
    setState(() => status = true);
    gestaoAtivaModel = await GestaoAtivaServiceAdapter().getExibirGestaoAtiva();
    await getDisciplinasPolivalente();
    setState(() => status = false);
  }

  Future<void> getDisciplinasPolivalente() async {
    if (gestaoAtivaModel == null || gestaoAtivaModel!.is_polivalencia != 1) {
      setState(() => disciplinas = []);
      return;
    }

    final disciplinaController = DisciplinaController();
    await disciplinaController.init();

    disciplinas = await disciplinaController.getAllDisciplinasPeloTurmaId(
      turmaId: gestaoAtivaModel!.idt_turma_id.toString(),
      idtId: gestaoAtivaModel!.idt_id.toString(),
    );

    setState(() {
      descricaoString =
          disciplinas.map((disciplina) => disciplina.descricao).join(', ');
    });
  }

  double fontText = 12.0;

  @override
  Widget build(BuildContext context) {
    return status
        ? const SizedBox()
        : Container(
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTema.primaryAmarelo, AppTema.primaryAmarelo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildInfoRows(context),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: -8.0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.sync,
                        color: Colors.black,
                        size: 25,
                      ),
                      onPressed: widget.onPressedSynchronizer,
                    ),
                  ),
                ],
              ),
            ));
  }

  List<Widget> _buildInfoRows(BuildContext context) {
    return [
      Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Distribui os elementos
        children: [
          _buildButton(context),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Turma:', gestaoAtivaModel?.turma_descricao),
                _buildInfoDisciplinaRow(
                  'Disciplina:',
                  gestaoAtivaModel?.is_polivalencia == 1
                      ? descricaoString
                      : gestaoAtivaModel?.disciplina_descricao,
                ),
                _buildInfoRow('Professor:', gestaoAtivaModel?.instrutor_nome),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildInfoRow(String label, String? value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTema.primaryDarkBlue,
            fontSize: fontText,
            fontWeight: FontWeight.bold,
          ),
        ),
        //const SizedBox(width: 4.0),
        Expanded(
          child: Text(
            value ?? '...',
            style:
                TextStyle(color: AppTema.primaryDarkBlue, fontSize: fontText),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoDisciplinaRow(String label, String? value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTema.primaryDarkBlue,
            fontSize: fontText,
            fontWeight: FontWeight.bold,
          ),
        ),
        //const SizedBox(width: 4.0),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Text(
            value ?? '...',
            style:
                TextStyle(color: AppTema.primaryDarkBlue, fontSize: fontText),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
      child: SizedBox(
        width: 30,
        height: 54,
        child: IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/todasAsGestoesDoProfessor'),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTipoRow(String label, bool? infantil) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTema.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4.0),
        Expanded(
          child: Text(
            infantil == true ? 'Infantil' : 'Fundamental',
            style: const TextStyle(color: AppTema.primaryDarkBlue),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}
