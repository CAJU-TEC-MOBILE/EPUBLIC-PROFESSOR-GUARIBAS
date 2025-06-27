import 'dart:io';
import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/models/auth_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/models/professor_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/auth_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';
import '../../services/camera/camera_controller.dart';
import '../../services/connectivity/internet_connectivity_service.dart';
import '../../services/controller/auth_controller.dart';
import '../../services/controller/professor_controller.dart';
import '../../services/directories/directories_controller.dart';
import '../../services/http/auth/auth_http.dart';
import '../dialogs/custom_snackbar.dart';

class UserInfoComponente extends StatefulWidget {
  const UserInfoComponente({super.key});

  @override
  State<UserInfoComponente> createState() => _UserInfoComponenteState();
}

class _UserInfoComponenteState extends State<UserInfoComponente> {
  AuthModel? authModel;
  GestaoAtiva? gestaoAtivaModel;
  double fontText = 16.0;
  bool isLoading = true;
  double heightCard = 200.0;
  double edgeInsetCard = 24.0;
  bool isLoadingImage = false;
  Professor? professor;
  File? _image;
  final CameraController _cameraController = CameraController();
  final authController = AuthController();
  final professorController = ProfessorController();

  Future<void> _getImage() async {
    DirectoriesController directoriesController = DirectoriesController();

    await directoriesController.pickAndSaveImageUser(
      userId: authModel!.id.toString(),
    );

    setState(() => isLoadingImage = true);
    await Future.delayed(const Duration(seconds: 3));

    final image = await directoriesController.getImageUser(
      authModel!.id.toString(),
    );

    await directoriesController.getAllUserImages();

    bool isConnectedNotifier = await InternetConnectivityService.isConnected();
    if (isConnectedNotifier && image != null) {
      final authHttp = AuthHttp();
      final response = await authHttp.uploudImage(image);
      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackBar.showSuccessSnackBar(
          context,
          'Imagem salva com sucesso!',
        );
      }
    }

    setState(() {
      isLoadingImage = false;
      _image = image;
    });
  }

  Future<void> getUserImage() async {
    DirectoriesController directoriesController = DirectoriesController();
    //await directoriesController.clearImagesDirectory();
    final image =
        await directoriesController.getImageUser(authModel!.id.toString());
    // if (image == null) {
    //   setState(() => isLoadingImage = true);
    //   return;
    // }

    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    super.initState();
    getInformacoes();
  }

  Future<void> getInformacoes() async {
    await professorController.init();
    await authController.init();

    authModel = await authController.authFirst();
    professor = await professorController.getProfessor();
    gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();

    await getUserImage();
    if (gestaoAtivaModel != null) {
      setState(() {
        heightCard = 300.0;
        edgeInsetCard = 0.0;
      });
    }

    setState(() {
      professor;
      gestaoAtivaModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.0),
                  bottomRight: Radius.circular(32.0),
                ),
              ),
              margin: const EdgeInsets.all(0.0),
              color: AppTema.primaryDarkBlue,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 110.0,
                                  height: 110.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTema.primaryAmarelo,
                                      width: 3.0,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 52.0,
                                    backgroundImage:
                                        !isLoadingImage && _image != null
                                            ? FileImage(_image!)
                                            : null,
                                    backgroundColor: AppTema.backgroundColorApp,
                                    child: !isLoadingImage && _image == null
                                        ? const Icon(
                                            Icons.person,
                                            color: AppTema.primaryAmarelo,
                                            size: 82.0,
                                          )
                                        : null,
                                  ),
                                ),
                                if (isLoadingImage)
                                  const CircularProgressIndicator(
                                    color: AppTema.primaryAmarelo,
                                  ),
                              ],
                            ),
                            Positioned(
                              top: 80.0,
                              bottom: 0,
                              right: 12.0,
                              child: Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: const BoxDecoration(
                                  color: AppTema.primaryAmarelo,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: _getImage,
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AppTema.primaryWhite,
                                    size: 10.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        professor?.nome.isNotEmpty == true
                            ? professor!.nome.toUpperCase()
                            : 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
