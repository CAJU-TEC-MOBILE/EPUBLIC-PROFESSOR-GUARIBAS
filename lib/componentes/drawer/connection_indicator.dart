import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import '../../services/connectivity/connectivity_service.dart';

class ConnectionIndicator extends StatefulWidget {
  const ConnectionIndicator({super.key});

  @override
  State<ConnectionIndicator> createState() => _ConnectionIndicatorState();
}

class _ConnectionIndicatorState extends State<ConnectionIndicator>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(true);
  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    _connectivityService = ConnectivityService();

    _connectivityService.checkInitialConnectivity();

    _connectivityService.connectivityStream.listen((connected) {
      setState(() {
        isConnectedNotifier.value = connected;
      });
    });
  }

  @override
  void dispose() {
    isConnectedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      right: 6.0,
      child: Container(
        width: 21.0,
        height: 21.0,
        decoration: const BoxDecoration(
          color: AppTema.backgroundColorApp,
          shape: BoxShape.circle,
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: isConnectedNotifier,
          builder: (context, isConnected, _) {
            return Icon(
              Icons.circle,
              color: isConnected ? AppTema.success : AppTema.error,
              size: 20.0,
            );
          },
        ),
      ),
    );
  }
}
