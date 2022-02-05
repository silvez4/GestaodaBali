import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestao_bali/net/google_signin.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen();
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  ProfileScreenState();

  final appBarBg = Colors.black;
  final appBarTxt = Colors.orange;

  final corBtnAppBar = ElevatedButton.styleFrom(
    primary: Colors.orange,
    onPrimary: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: appBarBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Perfil',
          style: TextStyle(color: appBarTxt),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Olá, ' + user!.displayName!,
              style: TextStyle(color: appBarTxt, fontSize: 32),
            ),
            Text(
              user.email!,
              style: TextStyle(color: appBarTxt, fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                radius: 60,
                backgroundImage: NetworkImage(user.photoURL!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  final provider =
                      Provider.of<GoogleSignInProvider>(context, listen: false);
                  provider.logout();
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18),
                ),
                style: corBtnAppBar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
