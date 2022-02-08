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
const corBtnText = Colors.black;
final corBtn = ElevatedButton.styleFrom(
  primary: Colors.greenAccent,
  onPrimary: Colors.black,
);
//endregion
const tamTextTile = 20.0;

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
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Vender',
          ),
        ),
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
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text('Gestão'),
        ),
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
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Sair',
            style: TextStyle(color: corBtnMenuAppBarlogout),
          ),
        ),
      ],
    ),
  )
];
//endregion

class _GestaoScreenState extends State<GestaoScreen> {
  List<VendaModel> historicoVendas = [];
  int totalBolosGeral = 0;

  Future<void> detalhesVenda(List<BoloModel> _pedido) async {
    List<BoloModel> pedidoLimpo = [];

    _pedido.forEach((element) {
      if (element.sabor != 'cliente' &&
          element.sabor != 'hora' &&
          element.sabor != 'local' &&
          element.sabor != 'vendedor') {
        pedidoLimpo.add(BoloModel(element.sabor, element.qtd));
      }
    });
    pedidoLimpo.forEach((element) {
      print(element.sabor);
    });
    print(pedidoLimpo.length);
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                height: 300,
                width: 300,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: pedidoLimpo.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(pedidoLimpo[index].sabor),
                      trailing: Text(pedidoLimpo[index].qtd.toString()),
                      onTap: () {},
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                ),
              ),
              actions: [
                TextButton(
                    child:
                        const Text("Ok", style: TextStyle(color: Colors.green)),
                    onPressed: () {
                      pedidoLimpo.clear();
                      Navigator.pop(context);
                    })
              ],
            ));
    pedidoLimpo.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 12,
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Gestão',
          style: TextStyle(color: corBtnText),
        ),
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => _onSelect(context, item),
            itemBuilder: (context) => opcoesMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: corBtn,
                  onPressed: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2017, 1),
                      lastDate: DateTime(2030, 12),
                      helpText: 'Escolha data desejada',
                    );
                    historicoVendas = await buscarVendas(data!);
                    setState(() {});
                  },
                  child: const Text(
                    'Historico de Vendas',
                    style: TextStyle(color: corBtnText),
                  ),
                ),
                ElevatedButton(
                  style: corBtn,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.attcarrinho);
                  },
                  child: const Text(
                    'Atualizar Cooler',
                    style: TextStyle(color: corBtnText),
                  ),
                ),
              ],
            ),
          ),
          historicoVendas.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma Venda nesta Data',
                    style: TextStyle(fontSize: 22),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        var totalBolos = 0;
                        for (var i = 0;
                            i < historicoVendas[index].venda.length;
                            i++) {
                          totalBolos += historicoVendas[index].venda[i].qtd;
                        }
                        //TODO MOSTRAR TOTAIS DE BOLOS VENDIDOS
                        // totalBolosGeral += totalBolos;
                        // print(totalBolosGeral);

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: ListTile(
                            textColor: Colors.red,
                            leading: Text(
                              historicoVendas[index].setor,
                              style: const TextStyle(fontSize: tamTextTile),
                            ),
                            subtitle: Text(
                              totalBolos.toString(),
                              style: const TextStyle(fontSize: tamTextTile),
                            ),
                            title: Center(
                                child: Text(
                              historicoVendas[index].hora,
                              style: const TextStyle(fontSize: tamTextTile),
                            )),
                            trailing: Text(
                              historicoVendas[index].cliente,
                              style: const TextStyle(fontSize: tamTextTile),
                            ),
                            onTap: () async {
                              detalhesVenda(historicoVendas[index].venda);
                            },
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount: historicoVendas.length),
                )
        ],
      ),
    );
  }
}
