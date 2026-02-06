import 'package:get/get.dart';
import 'package:qlickcare/Utils/safe_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppLauncherController extends GetxController {
  Future<void> openWhatsApp(String phoneNumber, {String message = ""}) async {
    final String formattedNumber = phoneNumber.replaceAll(" ", "");

    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      showSnackbarSafe("Error", "WhatsApp is not installed!");
    }
  }
}
