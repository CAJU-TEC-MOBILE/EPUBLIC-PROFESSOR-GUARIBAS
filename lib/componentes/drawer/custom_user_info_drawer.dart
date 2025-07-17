import 'dart:io';
import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/models/auth_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/auth_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';
import '../../services/camera/camera_controller.dart';
import '../../services/controller/auth_controller.dart';
import '../../services/directories/directories_controller.dart';
import 'connection_indicator.dart';

class CustomUserInfoDrawer extends StatefulWidget {
  const CustomUserInfoDrawer({super.key});

  @override
  State<CustomUserInfoDrawer> createState() => _CustomUserInfoDrawerState();
}

class _CustomUserInfoDrawerState extends State<CustomUserInfoDrawer> {
  final authController = AuthController();
  AuthModel? authModel;
  GestaoAtiva? gestaoAtivaModel;
  double fontText = 16.0;
  bool isLoading = true;
  double heightCard = 200.0;
  double edgeInsetCard = 24.0;
  bool isLoadingImage = false;

  File? _image;
  final CameraController _cameraController = CameraController();

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
    await authController.init();
    authModel = await authController.authFirst();
    gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
    await getUserImage();
    if (gestaoAtivaModel != null) {
      setState(() {
        heightCard = 300.0;
        edgeInsetCard = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 92.0,
                height: 92.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTema.backgroundColorApp,
                    width: 3.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 52.0,
                  backgroundImage: !isLoadingImage && _image != null
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
          const ConnectionIndicator(),
        ],
      ),
    );
  }
}
