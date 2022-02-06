import 'package:flutter/material.dart';
import 'package:gestao_bali/models/bolo_model.dart';
import 'package:gestao_bali/net/firebase_connection.dart';
import 'package:gestao_bali/net/google_signin.dart';
import 'package:gestao_bali/theme/routes.dart';
import 'package:provider/provider.dart';

class GestaoScreen extends StatefulWidget {
  const GestaoScreen({Key? key}) : super(key: key);

  @override
  _GestaoScreenState createState() => _GestaoScreenState();
}

//region Cores
const corBtnMenuAppBar = Colors.black;
const corBtnMenuAppBarlogout = Colors.red;
//endregion

void _onSelect(BuildContext context, int item) {
  switch (item) {
    case 0:
      Navigator.of(context).pushNamed(AppRoutes.home);
      break;

    case 1:
      Navigator.of(context).pushNamed(AppRoutes.gestao);
      break;

    case 2:
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      provider.logout();
      break;
  }
}

//region Opções do Menu no Appbar
final opcoesMenu = [
  PopupMenuItem<int>(
    value: 0,
    child: Row(
      children: const [
        Icon(
          Icons.monetization_on,
          color: corBtnMenuAppBar,
        ),
        Text('Vender'),
      ],
    ),
  ),
  PopupMenuItem<int>(
    value: 1,
    child: Row(
      children: const [
        Icon(
          Icons.wallet_travel,
          color: corBtnMenuAppBar,
        ),
        Text('Gestão'),
      ],
    ),
  ),
  PopupMenuItem<int>(
    value: 2,
    child: Row(
      children: const [
        Icon(
          Icons.logout,
          color: corBtnMenuAppBarlogout,
        ),
        Text(
          'Sair',
          style: TextStyle(color: corBtnMenuAppBarlogout),
        ),
      ],
    ),
  )
];
//endregion

class _GestaoScreenState extends State<GestaoScreen> {
  List<VendaModel> historicoVendas = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Gestão'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => _onSelect(context, item),
            itemBuilder: (context) => opcoesMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                final data = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2017, 1),
                    lastDate: DateTime(2030, 12),
                    helpText: 'Escolha data desejada');
                historicoVendas = await buscarVendas(data!);
                setState(() {});
              },
              child: Text('Escolher Data')),
          historicoVendas.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma Venda nesta Data',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(historicoVendas[index].hora),
                          subtitle: Text(historicoVendas[index].cliente),
                          leading: Text(historicoVendas[index].setor),
                          // trailing: Text(historicoVendas[index]
                          //     .venda[index]
                          //     .qtd
                          //     .toString()),
                          onTap: () {},
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount: historicoVendas.length))
        ],
      ),
    );
  }
}
