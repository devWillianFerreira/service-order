import '../../models/item_ordem_servico.dart';

class OrdemServicoCalculator {
  static double calcularTotalItens(List<ItemOrdemServico> itens) {
    return itens.fold<double>(0, (total, item) => total + item.subtotal);
  }

  static double calcularValorTotal({
    required double valorMaoDeObra,
    required List<ItemOrdemServico> itens,
  }) {
    final totalItens = calcularTotalItens(itens);

    return valorMaoDeObra + totalItens;
  }
}
