import 'package:ordem_servico/core/states/aberta_state.dart';
import 'package:ordem_servico/core/states/cancelada_state.dart';
import 'package:ordem_servico/core/states/concluida_state.dart';
import 'package:ordem_servico/core/states/em_atendimento_state.dart';
import 'package:ordem_servico/core/states/ordem_servico_state.dart';
import 'package:ordem_servico/models/ordem_servico.dart';

class OrdemServicoStateFactory {
  static OrdemServicoState criar(StatusOrdemServico status) {
    switch (status) {
      case StatusOrdemServico.aberta:
        return AbertaState();

      case StatusOrdemServico.emAtendimento:
        return EmAtendimentoState();

      case StatusOrdemServico.concluida:
        return ConcluidaState();

      case StatusOrdemServico.cancelada:
        return CanceladaState();
    }
  }
}
