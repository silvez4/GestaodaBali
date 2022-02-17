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

final corBtn = ElevatedButton.styleFrom(
  primary: Colors.pinkAccent,
  onPrimary: Colors.white,
);

final corBtnDisable = ElevatedButton.styleFrom(
  primary: Colors.black38,
  onPrimary: Colors.white,
);
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
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Vender',
            style: TextStyle(fontSize: 20),
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
          child: Text(
            'Gestão',
            style: TextStyle(fontSize: 20),
          ),
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
            style: TextStyle(fontSize: 20, color: corBtnMenuAppBarlogout),
          ),
        ),
      ],
    ),
  )
];
//endregion

class _HomeScreenState extends State<HomeScreen> {
  List<BoloModel> estoque = [];
  List<BoloModel> carrinho = [];
  String _setorFinal = '';
  String _clienteFinal = '';
  late List<String> _clientes = [];
  late List<String> _setores = [];
  static const double fontSize = 20.0;

  @override
  void initState() {
    super.initState();
    initCooler();
  }

  void initCooler() async {
    estoque = await verCooler();
    estoque.sort((a, b) => a.sabor.compareTo(b.sabor));

    _setores = await buscarSetores();
    _setores.sort((a, b) => a.compareTo(b));

    _clientes = await buscarClientes();
    _clientes.sort((a, b) => a.compareTo(b));
    setState(() {});
  }

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

  @override
  Widget build(BuildContext context) {
    const corTxtTile = Colors.pinkAccent;

    //region ScaffoldMesseger
    ScaffoldFeatureController<SnackBar, SnackBarClosedReason> enviarMensagem(
            BuildContext context, String texto) =>
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              texto,
              style: const TextStyle(
                color: Colors.pinkAccent,
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.black,
          ),
        );
    //endregion

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false,
        title: const Text('Controle de Vendas'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                Navigator.of(context).pushNamed(AppRoutes.home);
              });
            },
            icon: const Icon(
              Icons.refresh,
              size: 32,
            ),
          ),
          PopupMenuButton<int>(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 32,
            ),
            onSelected: (item) => _onSelect(context, item),
            itemBuilder: (context) => opcoesMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // Center(
          //   child: ElevatedButton(
          //     style: carrinho.isEmpty ? corBtnDisable : corBtn,
          //     onPressed: () async {
          //       if (carrinho.isEmpty) {
          //         enviarMensagem(context, 'Insira Produtos Para Efetuar Venda');
          //       } else {
          //         if (await finalizarVenda()) {
          //           if (_clienteFinal.isEmpty) {
          //             _clienteFinal = 'Cliente';
          //           }
          //           if (_setorFinal.isEmpty) {
          //             _setorFinal = 'Outros';
          //           }
          //           await addVenda(carrinho, _setorFinal, _clienteFinal);
          //           updateEstoque(estoque);
          //           carrinho.clear();
          //           _clienteFinal = '';
          //           _setorFinal = '';
          //           setState(() {});
          //           enviarMensagem(context, 'Venda Finalizada');
          //         }
          //       }
          //     },
          //     child: const Text('Finalizar Venda'),
          //   ),
          // ),
          estoque.isEmpty
              ? const Center(
                  child: Text('Nenhum Produto Para Venda'),
                )
              : Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        selectedTileColor: Colors.green,
                        title: Text(
                          estoque[index].sabor,
                          style: const TextStyle(fontSize: fontSize),
                        ),
                        trailing: Text(
                          estoque[index].qtd.toString(),
                          style: const TextStyle(fontSize: fontSize),
                        ),
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
                        tileColor:
                            estoque[index].qtd > 0 ? Colors.white : Colors.red,
                        textColor:
                            estoque[index].qtd > 0 ? corTxtTile : Colors.black,
                      );
                    },
                    itemCount: estoque.length,
                    separatorBuilder: (context, index) {
                      return const Divider(
                        thickness: 2,
                        color: Colors.pinkAccent,
                      );
                    },
                  ),
                ),
          carrinho.isEmpty
              ? Container()
              : Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            border: Border.all(color: Colors.black, width: 2)),
                        child: ListTile(
                          title: Text(
                            carrinho[index].sabor,
                            style: const TextStyle(
                                color: Colors.black, fontSize: fontSize),
                          ),
                          trailing: Text(
                            carrinho[index].qtd.toString(),
                            style: const TextStyle(
                                color: Colors.black, fontSize: fontSize),
                          ),
                          onTap: () {
                            carrinho[index].subtrair();
                            for (var i = 0; i < estoque.length; i++) {
                              if (carrinho[index].sabor == estoque[i].sabor) {
                                estoque[i].qtd++;
                                setState(() {});
                                break;
                              } else if (i == estoque.length - 1) {
                                carrinho
                                    .add(BoloModel(estoque[index].sabor, 1));
                              }
                            }
                            if (carrinho[index].qtd <= 0) {
                              carrinho.removeAt(index);
                            }
                            setState(() {});
                          },
                          enabled: carrinho[index].qtd > 0 ? true : false,
                          tileColor: carrinho[index].qtd > 0
                              ? Colors.white
                              : Colors.redAccent.withOpacity(0.6),
                          textColor: carrinho[index].qtd > 0
                              ? Colors.blue
                              : Colors.black,
                        ),
                      );
                    },
                    itemCount: carrinho.length,
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                ),
          Center(
            child: ElevatedButton(
              style: carrinho.isEmpty ? corBtnDisable : corBtn,
              // style: ButtonStyle(
              //   shape: MaterialStateProperty.all(
              //     RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(32),
              //         side: BorderSide(
              //           color: Colors.red,
              //         )),
              //   ),
              // ),
              onPressed: () async {
                if (carrinho.isEmpty) {
                  enviarMensagem(context, 'Insira Produtos Para Efetuar Venda');
                } else {
                  if (await finalizarVenda()) {
                    if (_clienteFinal.isEmpty) {
                      _clienteFinal = 'Cliente';
                    }
                    if (_setorFinal.isEmpty) {
                      _setorFinal = 'Outros';
                    }
                    await addVenda(carrinho, _setorFinal, _clienteFinal);
                    updateCooler(estoque);
                    carrinho.clear();
                    _clienteFinal = '';
                    _setorFinal = '';
                    setState(() {});
                    enviarMensagem(context, 'Venda Finalizada');
                  }
                }
              },
              child: const Text(
                'Finalizar Venda',
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ),
        ],
      ),
      // ******** Dinamico
      // body: Column(
      //   children: [
      //     SizedBox(
      //       height: MediaQuery.of(context).size.height / 3,
      //       child: FutureBuilder(
      //           future: verCooler(),
      //           builder: (BuildContext context,
      //               AsyncSnapshot<List<BoloModel>> snapshot) {
      //             if (snapshot.connectionState == ConnectionState.done) {
      //               // for (var element in snapshot.data!) {
      //               //   estoque.add(element);
      //               // }
      //               return ListView.separated(
      //                 itemBuilder: (context, index) {
      //                   //             estoque.sort((a, b) => a.sabor.compareTo(b.sabor));
      //
      //                   snapshot.data
      //                       ?.sort((a, b) => a.sabor.compareTo(b.sabor));
      //                   return ListTile(
      //                     title: Text(
      //                       snapshot.data![index].sabor,
      //                       style: TextStyle(color: Colors.red),
      //                     ),
      //                     trailing: Text(snapshot.data![index].qtd.toString()),
      //                     onTap: () {
      //                       snapshot.data![index].subtrair();
      //                       if (carrinho.isEmpty) {
      //                         carrinho.add(
      //                             BoloModel(snapshot.data![index].sabor, 1));
      //                         setState(() {});
      //                       } else {
      //                         for (var i = 0; i < carrinho.length; i++) {
      //                           if (carrinho[i].sabor ==
      //                               snapshot.data![index].sabor) {
      //                             carrinho[i].qtd++;
      //                             setState(() {});
      //                             return;
      //                           }
      //                         }
      //                         carrinho.add(BoloModel(estoque[index].sabor, 1));
      //                         if (estoque[index].qtd <= 1) {}
      //                         setState(() {});
      //                       }
      //                     },
      //                   );
      //                 },
      //                 itemCount: snapshot.data!.length,
      //                 separatorBuilder: (context, index) {
      //                   return Divider();
      //                 },
      //               );
      //             } else {
      //               return const CircularProgressIndicator();
      //             }
      //           }),
      //     ),
      //     carrinho.isEmpty
      //         ? Container()
      //         : Expanded(
      //             child: ListView.separated(
      //             itemBuilder: (context, index) {
      //               return Container(
      //                 decoration: BoxDecoration(color: Colors.black12),
      //                 child: ListTile(
      //                   title: Text(
      //                     carrinho[index].sabor,
      //                     style: TextStyle(color: Colors.black),
      //                   ),
      //                   trailing: Text(
      //                     carrinho[index].qtd.toString(),
      //                     style: TextStyle(color: Colors.red),
      //                   ),
      //                   onTap: () {
      //                     carrinho[index].subtrair();
      //                     for (var i = 0; i < estoque.length; i++) {
      //                       if (carrinho[index].sabor == estoque[i].sabor) {
      //                         estoque[i].qtd++;
      //                         setState(() {});
      //                         return;
      //                       } else if (i == estoque.length - 1) {
      //                         carrinho.add(BoloModel(estoque[index].sabor, 1));
      //                       }
      //                     }
      //                     if (carrinho[index].qtd <= 0) {}
      //                     setState(() {});
      //                   },
      //                   enabled: carrinho[index].qtd > 0 ? true : false,
      //                   tileColor: carrinho[index].qtd > 0
      //                       ? Colors.white
      //                       : Colors.redAccent.withOpacity(0.6),
      //                   textColor: carrinho[index].qtd > 0
      //                       ? Colors.blue
      //                       : Colors.black,
      //                 ),
      //               );
      //             },
      //             itemCount: carrinho.length,
      //             separatorBuilder: (context, index) {
      //               return Divider();
      //             },
      //           ))
      //   ],
      // ),
    );
  }
}
