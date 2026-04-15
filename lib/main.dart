import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'core/config/app_config.dart';
import 'app.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);
  runApp(const ProviderScope(child: IKongApp()));
}
