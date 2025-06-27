import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_tema.dart';
import '../../../help/format.dart';
import '../../../models/auth_model.dart';
import '../../../models/professor_model.dart';
import '../../../pages/home_page.dart';
import '../../../services/connectivity/internet_connectivity_service.dart';
import '../../../services/controller/auth_controller.dart';
import '../../button/custom_button.dart';
import '../../dialogs/custom_snackbar.dart';
import '../../textformfield/custom_textformfield.dart';
import '../../../services/adapters/auth_service_adapter.dart';
import '../../../services/adapters/gestao_ativa_service_adapter.dart';
import '../preloader.dart';
import 'custom_card_perfil_controller.dart';

class CustomCardPerfil extends StatefulWidget {
  const CustomCardPerfil({super.key});

  @override
  State<CustomCardPerfil> createState() => _CustomCardPerfilState();
}

class _CustomCardPerfilState extends State<CustomCardPerfil> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numeroCpfController = TextEditingController();
  final TextEditingController _inepController = TextEditingController();
  final TextEditingController _dataNascimentoController =
      TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final CustomCardPerfilController _controller = CustomCardPerfilController(
    authServiceAdapter: AuthServiceAdapter(),
    gestaoAtivaServiceAdapter: GestaoAtivaServiceAdapter(),
  );

  double SizedBoxHeight = 18.0;

  bool _loading = false;
  bool _loadingButton = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _loading = true);

      await _controller.getProfessor();

      if (_controller.professor != null) {
        _updateTextControllers(_controller.professor);
      } else {
        debugPrint('Erro: Professor não encontrado.');
      }
    } catch (e) {
      debugPrint('Erro ao carregar informações: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _updateTextControllers(Professor? model) {
    FormatHelp formatHelp = FormatHelp();
    if (model != null) {
      _idController.text = model.id ?? '';
      _nameController.text = model.nome.toUpperCase() ?? '';
      _emailController.text = model.email ?? '';
      _numeroCpfController.text =
          model.cpf.isNotEmpty ? formatHelp.cpfMask(model.cpf) : '';
      _inepController.text = model.codigo ?? '';
      _dataNascimentoController.text = model.dataDaAulaPtBr ?? '';
      _matriculaController.text = model.matricula ?? '';
    }
  }

  Future<void> _fetchAtualizar(BuildContext context) async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      showLoading(context);
      setState(() => _loadingButton = true);
      if (_dataNascimentoController.text.isEmpty) {
        hideLoading(context);
        setState(() => _loadingButton = false);

        CustomSnackBar.showErrorSnackBar(
          context,
          'Data de nascimento obrigatório.',
        );
        return;
      }

      if (_numeroCpfController.text.isEmpty) {
        hideLoading(context);
        setState(() => _loadingButton = false);

        CustomSnackBar.showErrorSnackBar(
          context,
          'CPF obrigatório.',
        );
        return;
      }
      String numeroCpf =
          _numeroCpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (numeroCpf.length != 11) {
        hideLoading(context);
        setState(() => _loadingButton = false);

        CustomSnackBar.showErrorSnackBar(
          context,
          'CPF deve conter 11 caracteres.',
        );

        return;
      }
      // print(
      //     "_dataNascimentoController: ${_dataNascimentoController.text.toString()}");
      // print(dataDaAulaPadrao(_dataNascimentoController));
      var data = {
        'nome': _nameController.text,
        'email': _emailController.text,
        'cpf': numeroCpf,
        'codigo': _inepController.text,
        'data_nascimento': dataDaAulaPadrao(_dataNascimentoController),
        'matricula': _matriculaController.text,
      };
      bool isConnectedNotifier =
          await InternetConnectivityService.isConnected();

      if (!isConnectedNotifier) {
        hideLoading(context);
        setState(() => _loadingButton = false);

        CustomSnackBar.showErrorSnackBar(
          context,
          'Você está offline no momento. Verifique sua conexão com a internet.',
        );
        return;
      }

      var status =
          await _controller.fetchAtualizar(data, _idController.text, context);

      if (status) {
        setState(() => _loadingButton = false);
        await _fetchData();
        hideLoading(context);
        await Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
      setState(() => _loadingButton = false);
      hideLoading(context);
    } catch (e) {
      setState(() => _loadingButton = false);
      hideLoading(context);
    }
  }

  String? _validateData(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data é obrigatória';
    }
    final dateFormat = DateFormat('dd/MM/yyyy');
    try {
      dateFormat.parseStrict(value);
      return null;
    } catch (e) {
      return 'Data inválida. Use o formato dd/MM/yyyy';
    }
  }

  String? dataDaAulaPadrao(TextEditingController controller) {
    final value = controller.text;

    if (value.isEmpty) {
      return '';
    }

    try {
      final inputFormat = DateFormat('dd/MM/yyyy');
      final outputFormat = DateFormat('yyyy-MM-dd');

      final parsedDate = inputFormat.parseStrict(value);

      return outputFormat.format(parsedDate);
    } catch (e) {
      print('Erro ao analisar a data: $e');
      return 'Data inválida';
    }
  }

  bool _isDateValid(String date) {
    final inputFormat = DateFormat('dd/MM/yyyy');

    try {
      final parsedDate = inputFormat.parseStrict(date);

      if (parsedDate.month < 1 || parsedDate.month > 12) {
        return false;
      }

      final lastDayOfMonth =
          DateTime(parsedDate.year, parsedDate.month + 1, 0).day;
      if (parsedDate.day < 1 || parsedDate.day > lastDayOfMonth) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //height: MediaQuery.of(context).size.height * 0.68,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Card(
          color: AppTema.primaryWhite,
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: !_loading
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          SizedBox(height: SizedBoxHeight),
                          CustomTextFormField(
                            controller: _nameController,
                            borderColor: AppTema.primaryAmarelo,
                            labelColor: AppTema.primaryDarkBlue,
                            cursorColor: AppTema.primaryDarkBlue,
                            labelText: 'Nome Completo',
                            hintText: 'Informe seu nome completo',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'O nome é obrigatório.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: SizedBoxHeight),
                          CustomTextFormField(
                            controller: _emailController,
                            borderColor: AppTema.primaryAmarelo,
                            labelColor: AppTema.primaryDarkBlue,
                            cursorColor: AppTema.primaryDarkBlue,
                            labelText: 'E-mail',
                            hintText: 'Informe seu e-mail',
                          ),
                          SizedBox(height: SizedBoxHeight),
                          CustomTextFormField(
                            controller: _numeroCpfController,
                            borderColor: AppTema.primaryAmarelo,
                            labelColor: AppTema.primaryDarkBlue,
                            cursorColor: AppTema.primaryDarkBlue,
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                            labelText: 'Número do CPF',
                            hintText: 'Informe seu CPF',
                            mask: '###.###.###-##',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'CPF é obrigatório.';
                              }
                              if (value.length < 14) {
                                return 'CPF deve conter 11 caracteres.';
                              }
                              return null;
                              // if (_isDateValid(value) == false) {
                              //   return 'Data inválida.';
                              // }
                            },
                          ),
                          SizedBox(height: SizedBoxHeight),
                          CustomTextFormField(
                            controller: _inepController,
                            borderColor: AppTema.primaryAmarelo,
                            labelColor: AppTema.primaryDarkBlue,
                            cursorColor: AppTema.primaryDarkBlue,
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                            labelText: 'Identificação única(INEP)',
                            hintText: 'Informe seu INEP',
                          ),
                          SizedBox(height: SizedBoxHeight),
                          CustomTextFormField(
                            controller: _dataNascimentoController,
                            borderColor: AppTema.primaryAmarelo,
                            labelColor: AppTema.primaryDarkBlue,
                            cursorColor: AppTema.primaryDarkBlue,
                            keyboardType: TextInputType.number,
                            mask: '##/##/####',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Data é obrigatória.';
                              }
                              if (value.length < 10) {
                                return 'Data deve conter 8 caracteres.';
                              }
                              if (_isDateValid(value) == false) {
                                return 'Data inválida.';
                              }
                              return null;
                            },
                            labelText: 'Data de nascimento',
                            hintText: 'Informe data de nascimento',
                          ),
                          SizedBox(height: SizedBoxHeight),
                          CustomTextFormField(
                            controller: _matriculaController,
                            borderColor: AppTema.primaryAmarelo,
                            labelColor: AppTema.primaryDarkBlue,
                            cursorColor: AppTema.primaryDarkBlue,
                            labelText: 'Matrícula',
                            hintText: 'Informe sua matrícula',
                          ),
                          SizedBox(height: SizedBoxHeight),
                          CustomButton(
                            label: _loading ? 'Carregando...' : 'Confirmar',
                            backgroundColor: AppTema.primaryAmarelo,
                            loading: _loadingButton,
                            onPressed: () async =>
                                await _fetchAtualizar(context),
                          ),
                          SizedBox(height: SizedBoxHeight),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppTema.primaryDarkBlue,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
