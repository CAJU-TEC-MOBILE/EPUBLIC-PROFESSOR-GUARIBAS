import 'package:url_launcher/url_launcher.dart';

class LauncherController {
  Future<void> openWhatsApp(
      {required String numero, required String message}) async {
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri url =
        Uri.parse('whatsapp://send?phone=$numero&text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Não foi possível abrir o WhatsApp.';
    }
  }
}
