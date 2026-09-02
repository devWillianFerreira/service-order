import 'package:ordem_servico/models/ordem_servico.dart';

abstract class OrdemServicoState {
  StatusOrdemServico get status;

  bool podeTransicionarPara(StatusOrdemServico novoStatus);

  String? validarTransicao(
    OrdemServico ordemServico,
    StatusOrdemServico novoStatus,
  );
}
