import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: AppTema.primaryDarkBlue),
      ),
      backgroundColor: AppTema.primaryAmarelo,
      iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
      centerTitle: true,
      elevation: 2,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
