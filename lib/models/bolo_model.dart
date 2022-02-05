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
