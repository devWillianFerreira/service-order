import 'package:ordem_servico/core/states/ordem_servico_state.dart';
import 'package:ordem_servico/models/ordem_servico.dart';

class CanceladaState extends OrdemServicoState {
  @override
  StatusOrdemServico get status => StatusOrdemServico.cancelada;

  @override
  bool podeTransicionarPara(StatusOrdemServico novoStatus) {
    return false;
  }

  @override
  String? validarTransicao(
    OrdemServico ordemServico,
    StatusOrdemServico novoStatus,
  ) {
    return "Ordens canceladas não podem ser alteradas.";
  }
}
