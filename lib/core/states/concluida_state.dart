import 'package:ordem_servico/core/states/ordem_servico_state.dart';
import 'package:ordem_servico/models/ordem_servico.dart';

class ConcluidaState extends OrdemServicoState {
  @override
  StatusOrdemServico get status => StatusOrdemServico.concluida;

  @override
  bool podeTransicionarPara(StatusOrdemServico novoStatus) {
    return false;
  }

  @override
  String? validarTransicao(
    OrdemServico ordemServico,
    StatusOrdemServico novoStatus,
  ) {
    return "Ordens concluídas  não podem ser alteradas.";
  }
}
