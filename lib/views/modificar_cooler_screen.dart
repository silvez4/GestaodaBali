import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter/services.dart';
import 'package:gestao_bali/models/bolo_model.dart';
import 'package:gestao_bali/net/firebase_connection.dart';

class AtualizarCooler extends StatefulWidget {
  const AtualizarCooler({Key? key}) : super(key: key);

  @override
  _AtualizarCoolerState createState() => _AtualizarCoolerState();
}

class _AtualizarCoolerState extends State<AtualizarCooler> {
  List<BoloModel> bolos = [];

  @override
  void initState() {
    super.initState();
    initCooler();
  }

  void initCooler() async {
    bolos = await verCooler();
    bolos.sort((a, b) => a.sabor.compareTo(b.sabor));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    BoloModel novoBolo = BoloModel('', 0);

    Future<BoloModel> addBolo() async {
      List<String> _sabores = await buscarSabores();
      _sabores.sort((a, b) => a.compareTo(b));
      String _saborFinal = '';
      final _qtdFinal = TextEditingController();

      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Adicionar Novo Item'),
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                DropdownButtonFormField(
                    items: _sabores.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _saborFinal = value.toString();
                      });
                    }),
                TextField(
                  controller: _qtdFinal,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
                child:
                    const Text("Voltar", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.pop(context, false);
                }),
            TextButton(
                child: const Text("Finalizar",
                    style: TextStyle(color: Colors.green)),
                onPressed: () {
                  novoBolo = BoloModel(_saborFinal, int.parse(_qtdFinal.text));
                  Navigator.pop(context, novoBolo);
                })
          ],
        ),
      );
    }

    Future<int> modificarQtd() async {
      final _qtdNova = TextEditingController();

      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Modificar Quantidade'),
          content: TextField(
            controller: _qtdNova,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: [
            TextButton(
                child:
                    const Text("Voltar", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.pop(context, false);
                }),
            TextButton(
                child: const Text("Modificar",
                    style: TextStyle(color: Colors.green)),
                onPressed: () {
                  int _qtd = int.parse(_qtdNova.text);
                  if (_qtd >= 0) {
                    Navigator.pop(context, _qtd);
                  }
                })
          ],
        ),
      );
    }

    const tamanhoBtn = 32.0;
    //region Cores
    final corBtnAppBar = ElevatedButton.styleFrom(
      primary: Colors.pinkAccent.shade400,
      elevation: 12,
      // onPrimary: Colors.orange,
    );
    //endregion
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('Atualizar Cooler'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              style: corBtnAppBar,
              onPressed: () async {
                bolos.add(await addBolo());
                setState(() {});
              },
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: tamanhoBtn,
              ),
            ),
          ),
          ElevatedButton(
            style: corBtnAppBar,
            onPressed: () async {
              await updateCooler(bolos);
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.check,
              color: Colors.green,
              size: tamanhoBtn,
            ),
          ),
        ],
      ),
      body: bolos.isEmpty
          ? const Text(
              'Cooler Está Vazio',
              style: TextStyle(color: Colors.pinkAccent, fontSize: 18),
            )
          : ListView.builder(
              itemBuilder: (BuildContext context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  // only allows the user swipe from right to left
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    setState(() {
                      bolos.removeAt(index);
                    });
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(bolos[index].sabor),
                      trailing: Text(bolos[index].qtd.toString()),
                      onTap: () async {
                        bolos[index].qtd = await modificarQtd();
                        setState(() {});
                      },
                    ),
                  ),
                  background: Container(
                    color: Colors.red,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    alignment: Alignment.centerRight,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                );
              },
              itemCount: bolos.length,
            ),
    );
  }
}
