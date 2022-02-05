import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestao_bali/models/bolo_model.dart';
import 'package:gestao_bali/net/firebase_connection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BoloModel> estoque = [];
  List<BoloModel> carrinho = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estoque'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  estoque = await verCooler();
                  setState(() {});
                },
                child: Text('Buscar Dados'),
              ),
              carrinho.isEmpty
                  ? Container()
                  : ElevatedButton(
                      onPressed: () async {
                        await addVenda(carrinho);
                        await updateEstoque(estoque);
                        carrinho.clear();
                        setState(() {});
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
