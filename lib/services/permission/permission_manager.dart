import 'package:permission_handler/permission_handler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PermissionManager {
  Future<void> requestPermissions() async {
    var locationPermission = await Permission.location.request();
    if (locationPermission.isGranted) {
      print('Permissão de localização concedida');
    } else {
      print('Permissão de localização negada');
    }

    // var storagePermission = await Permission.storage.request();
    // if (storagePermission.isGranted) {
    //   print('Permissão de armazenamento concedida');
    // } else {
    //   print('Permissão de armazenamento negada');
    // }
  }

  Future<void> requestPhonePermission() async {
    var phonePermission = await Permission.phone.request();

    if (phonePermission.isGranted) {
      print('Permissão de localização concedida');
    } else {
      print('Permissão de localização negada');
    }
  }

  Future<void> checkAdIdPermission() async {
    final info = await MobileAds.instance.getRequestConfiguration();
    if (info != null) {
      print("A permissão AD_ID está disponível.");
    } else {
      print("A permissão AD_ID não está disponível.");
    }
  }
}
