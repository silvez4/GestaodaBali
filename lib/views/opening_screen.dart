import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestao_bali/net/google_signin.dart';
import 'package:gestao_bali/views/home.dart';
import 'package:provider/provider.dart';

class OpeningView extends StatefulWidget {
  @override
  OpeningViewState createState() => OpeningViewState();
}

class OpeningViewState extends State<OpeningView> {
  OpeningViewState();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final corFundoBtn = Colors.pinkAccent.withOpacity(0.3);
    final corTextoBtn = Colors.black.withOpacity(0.5);

    final logo = Image.asset(
      'resources/bdbali.png',
      height: mq.size.height / 3,
    );

    //region Opção Login com email e senha cadastrado no app
    // final loginBtn = Material(
    //   elevation: 3.0,
    //   borderRadius: BorderRadius.circular(25.0),
    //   color: corFundoBtn,
    //   child: MaterialButton(
    //     minWidth: mq.size.width / 1.2,
    //     padding: EdgeInsets.all(15.0),
    //     child: Text(
    //       'Entrar',
    //       textAlign: TextAlign.center,
    //       style: TextStyle(
    //         fontSize: 20.0,
    //         color: corTextoBtn,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     onPressed: () {
    //       Navigator.of(context).pushNamed(AppRoutes.authLogin);
    //     },
    //   ),
    // );
    //endregion

    //region Opção cadastro com email e senha
    // final cadastroBtn = Material(
    //   elevation: 5.0,
    //   borderRadius: BorderRadius.circular(25.0),
    //   color: corFundoBtn,
    //   child: MaterialButton(
    //     minWidth: mq.size.width / 1.2,
    //     padding: EdgeInsets.all(15.0),
    //     child: Text(
    //       'Cadastrar-se',
    //       textAlign: TextAlign.center,
    //       style: TextStyle(
    //         fontSize: 20.0,
    //         color: corTextoBtn,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     onPressed: () {
    //       Navigator.of(context).pushNamed(AppRoutes.authRegister);
    //     },
    //   ),
    // );
    //endregion

    final loginBtnGoogle = Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(25.0),
      color: corFundoBtn,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SizedBox(
          //   height: 28,
          //   child: Image.asset(
          //     'images/google_logo.webp',
          //     fit: BoxFit.contain,
          //   ),
          // ),
          MaterialButton(
            // minWidth: mq.size.width / 1.2,
            // padding: const EdgeInsets.all(15.0),
            child: Text(
              'Entrar com Google',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                color: corTextoBtn,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.googleLogin();
            },
          ),
        ],
      ),
    );

    final buttons = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // loginBtn,
        loginBtnGoogle,
        // Padding(
        //   padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        //   child: cadastroBtn,
        // ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Houve Algum Erro'),
            );
          } else if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            // Caso não tem dado de usuario
            return Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  logo,
                  buttons,
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
