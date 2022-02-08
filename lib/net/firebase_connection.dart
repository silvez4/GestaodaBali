import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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

Future<void> updateCooler(List<BoloModel> bolos) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? uid = auth.currentUser!.email;

  if (bolos.isNotEmpty) {
    final cooler = await FirebaseFirestore.instance
        .collection('bolos')
        .doc('vendedor')
        .collection(uid!)
        .doc('cooler');

    cooler.set({bolos.first.sabor: bolos.first.qtd});
    bolos.forEach((element) {
      if (element.qtd > 0) {
        cooler.update({element.sabor: element.qtd});
      }
    });
    return;
  }
  return;
}

Future<void> addVenda(
    List<BoloModel> pedido, String local, String cliente) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? uid = auth.currentUser!.displayName;

  var now = new DateTime.now();
  var dataFormat = new DateFormat('yyyy-MM/dd');
  String data = dataFormat.format(now);
  var horaFormat = new DateFormat('HH:mm:ss');
  String hora = horaFormat.format(now);

  var time = (data + '/' + hora);

  //region Set de Venda no Banco
  // final venda = await FirebaseFirestore.instance
  //     .collection('vendas')
  //     .doc(ano)
  //     .collection(mes)
  //     .doc(time);

  final venda = FirebaseFirestore.instance.collection('vendas').doc(time);

  venda
      .set({'vendedor': uid, 'local': local, 'cliente': cliente, 'hora': hora});
  // await venda.set({'data': time});
  pedido.forEach((element) async {
    if (element.qtd > 0) {
      await venda.update({element.sabor: element.qtd});
    }
  });
  //endregion
  return;
}

Future<List<VendaModel>> buscarVendas(DateTime data) async {
  // FirebaseAuth auth = FirebaseAuth.instance;
  // String? uid = auth.currentUser!.displayName;

  List<VendaModel> venda = <VendaModel>[];
  List<BoloModel> bolos = <BoloModel>[];

  String local = '';
  String cliente = '';
  String vendedor = '';
  String horario = '';

  var anoMesFormat = new DateFormat('yyyy-MM');
  var diaFormat = new DateFormat('dd');

  var anoMes = anoMesFormat.format(data);
  var dia = diaFormat.format(data);

  final vendasBanco = await FirebaseFirestore.instance
      .collection('vendas')
      .doc(anoMes)
      .collection(dia)
      .get();

  vendasBanco.docs.forEach((element) {
    element.data().forEach((key, value) {
      if (key == 'vendedor') {
        vendedor = value;
      } else if (key == 'local') {
        local = value;
      } else if (key == 'cliente') {
        cliente = value;
      } else if (key == 'hora') {
        horario = value;
      } else {
        bolos.add(BoloModel(key, value));
      }
    });
    venda.add(VendaModel(local, cliente, vendedor, bolos, horario));
    bolos = <BoloModel>[];
  });

  return venda;
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

Future<List<String>> buscarSabores() async {
  List<String> sabores = [];

  final saboresBanco =
      await FirebaseFirestore.instance.collection('bolos').doc('sabores').get();

  saboresBanco.data()!.forEach((key, value) {
    sabores.add(value);
  });

  return sabores;
}

Future<List<String>> buscarClientes() async {
  List<String> clientes = [];

  final saboresBanco =
      await FirebaseFirestore.instance.collection('clientes').doc('nome').get();

  saboresBanco.data()!.forEach((key, value) {
    clientes.add(value);
  });

  return clientes;
}

Future<List<String>> buscarSetores() async {
  List<String> setores = [];

  final saboresBanco =
      await FirebaseFirestore.instance.collection('setores').doc('nome').get();

  saboresBanco.data()!.forEach((key, value) {
    setores.add(value);
  });

  return setores;
}
