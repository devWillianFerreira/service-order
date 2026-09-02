import '../../../models/ordem_servico.dart';
import 'ordem_servico_state.dart';

class AbertaState implements OrdemServicoState {
  @override
  StatusOrdemServico get status => StatusOrdemServico.aberta;

  @override
  bool podeTransicionarPara(StatusOrdemServico novoStatus) {
    return novoStatus == StatusOrdemServico.aberta ||
        novoStatus == StatusOrdemServico.emAtendimento ||
        novoStatus == StatusOrdemServico.cancelada;
  }

  @override
  String? validarTransicao(
    OrdemServico ordemServico,
    StatusOrdemServico novoStatus,
  ) {
    if (!podeTransicionarPara(novoStatus)) {
      return 'Uma ordem aberta só pode ser iniciada ou cancelada.';
    }

    if (novoStatus == StatusOrdemServico.emAtendimento &&
        ordemServico.tecnicoId == null) {
      return 'É necessário vincular um técnico para iniciar o atendimento.';
    }

    return null;
  }
}
