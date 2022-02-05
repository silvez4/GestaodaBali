import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:gestao_bali/models/bolo_model.dart';

//Criar uma collection no Firebase com o uid do usuario e o campo nome e uid
Future<void> userSetup(String? displayName) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? uid = auth.currentUser!.email;
  final exist =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (!exist.exists) {
    //VERIFICANDO SE ESSE USUARIO NÃO EXISTE
    final users = FirebaseFirestore.instance.collection('users').doc(uid);

    users.set({
      'uid': uid,
      'displayName': displayName,
      'dataCriação': DateTime.now()
    });
  }
  return;
}

Future<List<BoloModel>> verCooler() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? uid = auth.currentUser!.email;

  List<BoloModel> bolos = <BoloModel>[];

  final cooler = await FirebaseFirestore.instance
      .collection('bolos')
      .doc('vendedor')
      .collection(uid!)
      .doc('cooler')
      .get();

  cooler.data()?.forEach((key, value) {
    bolos.add(BoloModel(key, value));
  });

  return bolos;
}

Future<void> addVenda(List<BoloModel> pedido) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? uid = auth.currentUser!.displayName;

  // Intl.defaultLocale = 'pt_BR';
  var now = new DateTime.now();
  var anoFormat = new DateFormat('yyyy');
  var mesFormat = new DateFormat('MM');
  var diaFormat = new DateFormat('dd');
  String ano = anoFormat.format(now);
  String mes = mesFormat.format(now);
  String dia = diaFormat.format(now);
  var time = (dia +
      '-' +
      now.hour.toString() +
      ':' +
      now.minute.toString() +
      ':' +
      now.second.toString());

  //region Set de Venda no Banco
  final venda = await FirebaseFirestore.instance
      .collection('vendas')
      .doc(ano)
      .collection(mes)
      .doc(time);

  await venda.set({'vendedor': uid});
  pedido.forEach((element) async {
    if (element.qtd > 0) {
      await venda.update({element.sabor: element.qtd});
    }
  });
  //endregion
}

Future<void> updateEstoque(List<BoloModel> remessa) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? uid = auth.currentUser!.email;

  // Intl.defaultLocale = 'pt_BR';

  // var now = new DateTime.now();
  // var formatdata = new DateFormat('yyyy-MM-dd hh:mm');
  // var data = formatdata.format(now);

  // var now = new DateTime.now();
  // var diaFormat = new DateFormat('dd');
  // String dia = diaFormat.format(now);
  // var time = (dia +
  //     '-' +
  //     now.hour.toString() +
  //     ':' +
  //     now.minute.toString() +
  //     ':' +
  //     now.second.toString());
  final cooler = await FirebaseFirestore.instance
      .collection('bolos')
      .doc('vendedor')
      .collection(uid!)
      .doc('cooler');

  remessa.forEach((element) {
    cooler.update({element.sabor: element.qtd});
  });
}
