// Run this once to get your app signature
import 'package:sms_autofill/sms_autofill.dart';

Future<void> getAppSignature() async {
  final signature = await SmsAutoFill().getAppSignature;
  print("📱 APP SIGNATURE: $signature");
  // Share this signature with your SMS provider (SMS Country)
}