import '../../../models/ordem_servico.dart';
import 'ordem_servico_state.dart';

class EmAtendimentoState implements OrdemServicoState {
  @override
  StatusOrdemServico get status => StatusOrdemServico.emAtendimento;

  @override
  bool podeTransicionarPara(StatusOrdemServico novoStatus) {
    return novoStatus == StatusOrdemServico.concluida ||
        novoStatus == StatusOrdemServico.cancelada;
  }

  @override
  String? validarTransicao(
    OrdemServico ordemServico,
    StatusOrdemServico novoStatus,
  ) {
    if (!podeTransicionarPara(novoStatus)) {
      return 'Uma ordem em atendimento só pode ser concluída ou cancelada.';
    }

    return null;
  }
}
