import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  Future<void> requestPermissions() async {
    var locationPermission = await Permission.location.request();
    if (locationPermission.isGranted) {
      print('Permissão de localização concedida');
    } else {
      print('Permissão de localização negada');
    }
  }

  Future<void> requestPhonePermission() async {
    var phonePermission = await Permission.phone.request();
    if (phonePermission.isGranted) {
      print('Permissão de localização concedida');
    } else {
      print('Permissão de localização negada');
    }
  }
}
