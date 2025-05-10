import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/app_tema.dart';
import '../../models/anexo_model.dart';
import '../../models/justificativa_model.dart';
import '../../services/controller/anexo_controller.dart';
import '../../services/directories/directories_controller.dart';
import '../../services/http/faltas/faltas_da_aula_online_enviar_http.dart';
import 'custom_dialogs.dart';

class JustificativaDialog {
  static const double botaoLarguraPadrao = 30.0;

  static get alunoId => null;

  static Future<bool?> exibirDialogoJustificativa(
    BuildContext context, {
    required String mensagem,
    required bool statusFalta,
    required List<Justificativa> justificativas,
    required matricula,
    required String selecionandoId,
    required ValueChanged<String?> onArquivoSelecionado,
    required Justificativa? justificativaSelecionada,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppTema.primaryWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildForm(context,
                  mensagem: mensagem,
                  statusFalta: statusFalta,
                  justificativas: justificativas,
                  onArquivoSelecionado: onArquivoSelecionado,
                  matricula: matricula,
                  justificativaSelecionada: justificativaSelecionada,
                  selecionandoId: selecionandoId),
            ),
          ),
        );
      },
    );
  }

  static Future<String?> anexo(
      {required matricula, required String selecionandoId}) async {
    final directoriesController = DirectoriesController();
    await directoriesController.createAnexoDirectory();
    final anexoController = AnexoController();
    await directoriesController.excluirTudoAnexos();

    String path = await directoriesController.obterCaminhoDoAnexo();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null) {
      debugPrint("No result: $result");
      return null;
    }

    String? caminhoDoArquivo = result.files.single.path;

    if (caminhoDoArquivo == null) {
      debugPrint("No caminhoDoArquivo: $caminhoDoArquivo");
      return null;
    }

    File arquivoSelecionado = File(caminhoDoArquivo);

    String destino = '$path/${result.files.single.name}';

    await arquivoSelecionado.copy(destino);

    await anexoController.init();

    final model = Anexo(
      id: 0,
      aluno_id: matricula['aula_id'].toString(),
      turma_id: selecionandoId,
      franquia_id: '',
      anexo_nome: result.files.single.name,
      online: false,
    );

    await anexoController.create(model);

    return destino;
  }

  static Widget _buildForm(
    BuildContext context, {
    required String mensagem,
    required bool statusFalta,
    required List<Justificativa> justificativas,
    required String selecionandoId,
    required ValueChanged<String?> onArquivoSelecionado,
    required Justificativa? justificativaSelecionada,
    required matricula,
  }) {
    final formKey = GlobalKey<FormState>();
    Justificativa? justificativaSelecionada0;
    String? novaCategoria;
    TimeOfDay? horarioLembrete;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // const Align(
          //   alignment: Alignment.topRight,
          //   child: CloseButton(),
          // ),
          // const SizedBox(height: 16),
          _buildDropdownJustificativa(
            context: context,
            justificativas: justificativas,
            justificativaSelecionada: justificativaSelecionada,
            onChanged: (value) {
              justificativaSelecionada0 = value;
            },
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTema.primaryAmarelo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              onPressed: () async {
                String? caminhoDoArquivo = await anexo(
                    matricula: matricula, selecionandoId: selecionandoId);
                onArquivoSelecionado(caminhoDoArquivo);
              },
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.attach_file,
                      color: AppTema.primaryDarkBlue,
                      size: 18.0,
                    ),
                    SizedBox(width: 2.0),
                    Text(
                      "Anexe um arquivo",
                      style: TextStyle(
                        color: AppTema.primaryDarkBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  CustomDialogs.showLoadingDialog(context, show: true);

                  final directorie = DirectoriesController();
                  final faltas = FaltasDaAulaOnlineEnviarHttp();

                  // await faltas.setFrequencia(
                  //   matriculaId: matricula['matricula_id'],
                  //   aulaId: matricula['aula_id'].toString(),
                  //   presente: 0,
                  // );

                  List<File> files = await directorie.getodosArquivosAnexos();

                  bool result = await faltas.setJustificarFalta(
                    context: context,
                    matriculaId: matricula['matricula_id'].toString(),
                    aulaId: matricula['aula_id'].toString(),
                    observacao: '',
                    justificativaId: justificativaSelecionada0!.id.toString(),
                    files: files,
                  );

                  CustomDialogs.showLoadingDialog(context, show: false);
                  Navigator.of(context).pop(false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTema.primaryDarkBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(color: AppTema.primaryWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDropdownJustificativa({
    required List<Justificativa> justificativas,
    required ValueChanged<Justificativa?> onChanged,
    required Justificativa? justificativaSelecionada,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Justificar falta",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            CloseButton()
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Justificativa>(
          hint: const Text('Selecione uma opção'),
          isExpanded: true,
          elevation: 1,
          value: justificativaSelecionada,
          dropdownColor: AppTema.backgroundColorApp,
          menuMaxHeight: 124.0,
          items: justificativas.map((justificativa) {
            return DropdownMenuItem<Justificativa>(
              value: justificativa,
              child: Text(
                justificativa.descricao.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            constraints:
                BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
            fillColor: AppTema.backgroundColorApp,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              borderSide:
                  BorderSide(color: AppTema.primaryDarkBlue, width: 1.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              borderSide:
                  BorderSide(color: AppTema.primaryDarkBlue, width: 1.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          validator: (value) =>
              value == null ? 'Por favor, selecione uma justificativa' : null,
        )
      ],
    );
  }
}
