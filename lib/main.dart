import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:gestao_bali/views/opening_screen.dart';
import 'package:gestao_bali/theme/routes.dart';
import 'package:gestao_bali/net/google_signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: MaterialApp(
          title: 'Gestão Bali',
          routes: AppRoutes.define(),
          home: OpeningView(),
        ),
      );
}
