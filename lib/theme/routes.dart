import 'package:flutter/material.dart';
import 'package:gestao_bali/views/home.dart';

class AppRoutes {
  AppRoutes._();

  static const String authLogin = '/auth-login';
  static const String authRegister = '/auth-register';
  static const String home = '/home';
  static const String ambiente = '/ambientes';

  static Map<String, WidgetBuilder> define() {
    return {
      // authLogin: (context) => Login(),
      // authRegister: (context) => Registro(),
      home: (context) => HomeScreen(),
      // ambiente: (context) => AmbienteScreen(),
    };
  }
}
