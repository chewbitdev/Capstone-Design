import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'core/config/app_config.dart';
import 'core/notifications/fcm_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  try {
    KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);
  } catch (_) {}
  try {
    await FcmService.init();
  } catch (_) {}
  runApp(const ProviderScope(child: IKongApp()));
}
