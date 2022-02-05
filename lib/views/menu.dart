import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestao_bali/views/home.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: null,
      body: DefaultTabController(
        initialIndex: 0,
        length: 1,
        child: Stack(
          children: <Widget>[
            const SizedBox(
              height: double.infinity,
              width: double.infinity,
            ),
            Scaffold(
              backgroundColor: Colors.black,
              bottomNavigationBar: const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TabBar(
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(Icons.dynamic_feed),
                    ),
                  ],
                  // labelColor: corIconAtivo,
                  // unselectedLabelColor: corIcon,
                  // indicator: UnderlineTabIndicator(
                  //     borderSide: BorderSide(width: 2, color: corIconAtivo),
                  //     insets: EdgeInsets.only(bottom: 44)),
                ),
              ),
              body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                dragStartBehavior: DragStartBehavior.start,
                children: <Widget>[HomeScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
