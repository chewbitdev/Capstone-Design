import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'app.dart';

void main() {
  KakaoSdk.init(nativeAppKey: '82fab0c036b8b8bd58dc8d9f1a593728');
  runApp(const IKongApp());
}
