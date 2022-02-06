import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestao_bali/models/bolo_model.dart';
import 'package:gestao_bali/net/firebase_connection.dart';
import 'package:gestao_bali/net/google_signin.dart';
import 'package:gestao_bali/theme/routes.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
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

class _HomeScreenState extends State<HomeScreen> {
  Future<bool> finalizarVenda() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Local e Cliente da Venda',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        content: SizedBox(
          height: 100,
          child: Column(
            children: [
              DropdownButtonFormField(
                hint: const Text('Local'),
                items: _setores.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _setorFinal = value.toString();
                  });
                },
              ),
              DropdownButtonFormField(
                hint: const Text('Cliente'),
                items: _clientes.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (value) {
                  _clienteFinal = value.toString();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              child: const Text("Voltar", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.pop(context, false);
              }),
          TextButton(
              child: const Text("Finalizar",
                  style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.pop(context, true);
              })
        ],
      ),
    );
  }

  List<BoloModel> estoque = [];
  List<BoloModel> carrinho = [];
  String _setorFinal = '';
  String _clienteFinal = '';
  late List<String> _sabores = [];
  late List<String> _clientes = [];
  late List<String> _setores = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Estoque'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => _onSelect(context, item),
            itemBuilder: (context) => opcoesMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  estoque = await verCooler();
                  _setores = await buscarSetores();
                  _clientes = await buscarClientes();
                  setState(() {});
                },
                child: Text('Buscar Dados'),
              ),
              carrinho.isEmpty
                  ? Container()
                  : ElevatedButton(
                      onPressed: () async {
                        if (await finalizarVenda()) {
                          if (_clienteFinal.isEmpty) {
                            _clienteFinal = 'Cliente';
                          }
                          if (_setorFinal.isEmpty) {
                            _setorFinal = 'Outros';
                          }
                          await addVenda(carrinho, _setorFinal, _clienteFinal);
                          await updateEstoque(estoque);
                          carrinho.clear();
                          _clienteFinal = '';
                          _setorFinal = '';
                          setState(() {});
                        }
                      },
                      child: const Text('Finalizar Venda'),
                    ),
            ],
          ),
          estoque.isEmpty
              ? Container()
              : Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          estoque[index].sabor,
                        ),
                        trailing: Text(estoque[index].qtd.toString()),
                        onTap: () {
                          estoque[index].subtrair();
                          if (carrinho.isEmpty) {
                            carrinho.add(BoloModel(estoque[index].sabor, 1));
                            setState(() {});
                          } else {
                            for (var i = 0; i < carrinho.length; i++) {
                              if (carrinho[i].sabor == estoque[index].sabor) {
                                carrinho[i].qtd++;
                                setState(() {});
                                return;
                              }
                            }
                            carrinho.add(BoloModel(estoque[index].sabor, 1));
                            if (estoque[index].qtd <= 1) {}
                            setState(() {});
                          }
                        },
                        enabled: estoque[index].qtd > 0 ? true : false,
                        tileColor: estoque[index].qtd > 0
                            ? Colors.white
                            : Colors.redAccent.withOpacity(0.6),
                        textColor:
                            estoque[index].qtd > 0 ? Colors.blue : Colors.black,
                      );
                    },
                    itemCount: estoque.length,
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                ),
          carrinho.isEmpty
              ? Container()
              : Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          carrinho[index].sabor,
                        ),
                        trailing: Text(carrinho[index].qtd.toString()),
                        onTap: () {
                          carrinho[index].subtrair();
                          for (var i = 0; i < estoque.length; i++) {
                            if (carrinho[index].sabor == estoque[i].sabor) {
                              estoque[i].qtd++;
                              setState(() {});
                              return;
                            } else if (i == estoque.length - 1) {
                              carrinho.add(BoloModel(estoque[index].sabor, 1));
                            }
                          }
                          if (carrinho[index].qtd <= 0) {}
                          setState(() {});
                        },
                        enabled: carrinho[index].qtd > 0 ? true : false,
                        tileColor: carrinho[index].qtd > 0
                            ? Colors.white
                            : Colors.redAccent.withOpacity(0.6),
                        textColor: carrinho[index].qtd > 0
                            ? Colors.blue
                            : Colors.black,
                      );
                    },
                    itemCount: carrinho.length,
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                )
        ],
      ),

      // body: FutureBuilder(
      //     future: verCooler(),
      //     builder:
      //         (BuildContext context, AsyncSnapshot<List<BoloModel>> snapshot) {
      //       if (snapshot.connectionState == ConnectionState.done) {
      //         for (var element in snapshot.data!) {
      //           estoque.add(element);
      //         }
      //         return ListView.separated(
      //           itemBuilder: (context, index) {
      //             return ListTile(
      //               title: Text(
      //                 estoque[index].sabor,
      //                 style: TextStyle(color: Colors.red),
      //               ),
      //               trailing: Text(estoque[index].qtd.toString()),
      //               onTap: () {
      //                 print(index);
      //                 textcolor:
      //                 Colors.blueGrey;
      //                 setState(() {
      //                   reassemble();
      //                 });
      //               },
      //             );
      //           },
      //           itemCount: estoque.length,
      //           separatorBuilder: (context, index) {
      //             return Divider();
      //           },
      //         );
      //       } else {
      //         return const CircularProgressIndicator();
      //       }
      //     }),
    );
  }
}
