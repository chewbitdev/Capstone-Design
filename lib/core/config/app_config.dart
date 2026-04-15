import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl => dotenv.env['BASE_URL']!;
  static String get kakaoNativeAppKey => dotenv.env['KAKAO_NATIVE_APP_KEY']!;
}
