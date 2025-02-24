import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:professor_acesso_notifiq/models/matricula_model.dart';
import '../../constants/app_tema.dart';
import '../../functions/aplicativo/gerar_uuid_identificador.dart';
import '../../models/anexo_model.dart';
import '../../models/justificativa_model.dart';
import '../../services/controller/anexo_controller.dart';
import '../../services/controller/historico_requencia_controller.dart';
import '../../services/directories/directories_controller.dart';
import '../../services/http/faltas/faltas_da_aula_online_enviar_http.dart';
import 'custom_dialogs.dart';

class JustificativaOfflineDialog {
  static const double botaoLarguraPadrao = 30.0;

  static get alunoId => null;

  static void fecharDialogo(
    BuildContext context,
  ) {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  static Future<bool?> exibirDialogoJustificativa(
    BuildContext context, {
    required String mensagem,
    required bool statusFalta,
    required List<Justificativa> justificativas,
    required Matricula matricula,
    required String selecionandoId,
    required Justificativa? justificativaSelecionada,
    required String? criadaPeloCelular,
    required ValueChanged<String?> onFileSelecionado,
    required ValueChanged<Justificativa?> onSustificativaSelecionado,
    required ValueChanged<String?> onArquivoSelecionado,
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
              child: _buildForm(
                context,
                mensagem: mensagem,
                criadaPeloCelular: criadaPeloCelular,
                statusFalta: statusFalta,
                justificativas: justificativas,
                onArquivoSelecionado: onArquivoSelecionado,
                onFileSelecionado: onFileSelecionado,
                onSustificativaSelecionado: onSustificativaSelecionado,
                matricula: matricula,
                selecionandoId: selecionandoId,
                justificativaSelecionada: justificativaSelecionada,
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<String?> anexoLocal({
    required String? criadaPeloCelular,
    required Matricula matricula,
    required String selecionandoId,
  }) async {
    final directoriesController = DirectoriesController();
    await directoriesController.createAnexoLocalDirectory();

    String path = await directoriesController.obterCaminhoDoAnexoLocal();

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

    String idUnico = gerarUuidIdentification();
    String destino = '$path/${idUnico}';

    String? caminho = await directoriesController.saveFile(
      arquivoSelecionado,
      criadaPeloCelular,
      idUnico,
    );

    final historicoPresencaController = HistoricoPresencaController();
    await historicoPresencaController.init();
    await historicoPresencaController.deleteFileAulaPorAula(
      criadaPeloCelular,
      matricula.aluno_id.toString(),
    );

    await arquivoSelecionado.copy(destino);

    return caminho;
  }

  static Widget _buildForm(
    BuildContext context, {
    required String mensagem,
    required bool statusFalta,
    required String? criadaPeloCelular,
    required List<Justificativa> justificativas,
    required String selecionandoId,
    required ValueChanged<String?> onArquivoSelecionado,
    required ValueChanged<String?> onFileSelecionado,
    required ValueChanged<Justificativa?> onSustificativaSelecionado,
    required Justificativa? justificativaSelecionada,
    required matricula,
  }) {
    final _formKey = GlobalKey<FormState>();
    Justificativa? _justificativaSelecionada;
    String? _novaCategoria;
    TimeOfDay? _horarioLembrete;

    return Form(
      key: _formKey,
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
              _justificativaSelecionada = value;
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
                String? caminhoDoArquivo = await anexoLocal(
                    criadaPeloCelular: criadaPeloCelular,
                    matricula: matricula,
                    selecionandoId: selecionandoId);
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
                if (_formKey.currentState?.validate() ?? false) {
                  CustomDialogs.showLoadingDialog(context, show: true);
                  if (_justificativaSelecionada != null) {
                    onSustificativaSelecionado(_justificativaSelecionada);
                    CustomDialogs.showLoadingDialog(context, show: false);
                    Navigator.of(context).pop(true);
                    return;
                  }

                  if (justificativaSelecionada != null) {
                    _justificativaSelecionada = justificativaSelecionada;
                    onSustificativaSelecionado(justificativaSelecionada);
                    CustomDialogs.showLoadingDialog(context, show: false);
                    Navigator.of(context).pop(true);
                    return;
                  }

                  onSustificativaSelecionado(_justificativaSelecionada);

                  // bool result = await faltas.setJustificarFalta(
                  //   matriculaId: matricula['matricula_id'].toString(),
                  //   aulaId: matricula['aula_id'].toString(),
                  //   observacao: '',
                  //   justificativaId: _justificativaSelecionada!.id.toString(),
                  //   files: files,
                  // );

                  CustomDialogs.showLoadingDialog(context, show: false);
                  Navigator.of(context).pop(true);

                  return;
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
        // Text(justificativaSelecionada.toString()),
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
