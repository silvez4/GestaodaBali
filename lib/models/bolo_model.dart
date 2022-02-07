class BoloModel {
  late String sabor;
  late int qtd;

  BoloModel(String sabor, int qtd) {
    this.sabor = sabor;
    this.qtd = qtd;
  }

  void subtrair() {
    this.qtd--;
  }
}

class VendaModel {
  late String setor;
  late String cliente;
  late String vendedor;
  late List<BoloModel> venda = [];
  late String hora;

  VendaModel(String setor, String cliente, String vendedor,
      List<BoloModel> venda, String hora) {
    this.setor = setor;
    this.cliente = cliente;
    this.vendedor = vendedor;
    this.venda = venda;
    this.hora = hora;
  }
}
