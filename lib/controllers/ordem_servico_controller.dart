import 'package:flutter/foundation.dart';
import 'package:ordem_servico/database/database_service.dart';
import '../core/states/ordem_servico_state_factory.dart';
import '../models/ordem_servico.dart';
import '../repositories/ordem_servico_repository.dart';

class OrdemServicoController extends ChangeNotifier {
  OrdemServicoController({OrdemServicoRepository? ordemServicoRepository})
    : _repository =
          ordemServicoRepository ??
          OrdemServicoRepository(DatabaseService.instance);

  final OrdemServicoRepository _repository;

  List<OrdemServico> _ordensServico = [];

  bool _carregando = false;

  String? _errorMessage;

  List<OrdemServico> get ordensServico => List.unmodifiable(_ordensServico);

  bool get carregando => _carregando;

  String? get errorMessage => _errorMessage;

  int get quantidadeOrdens => _ordensServico.length;

  List<OrdemServico> get ordensAbertas {
    return _ordensServico
        .where(
          (os) =>
              os.status != StatusOrdemServico.concluida &&
              os.status != StatusOrdemServico.cancelada,
        )
        .toList();
  }

  List<OrdemServico> porStatus(StatusOrdemServico status) {
    return _ordensServico.where((os) => os.status == status).toList();
  }

  List<OrdemServico> porPrioridade(Prioridade prioridade) {
    return _ordensServico.where((os) => os.prioridade == prioridade).toList();
  }

  List<OrdemServico> porTecnico(int tecnicoId) {
    return _ordensServico.where((os) => os.tecnicoId == tecnicoId).toList();
  }

  Future<void> carregarOrdensServico() async {
    _carregando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ordensServico = await _repository.listar();
    } catch (e) {
      _errorMessage = 'Não foi possível carregar as ordens de serviço.';

      if (kDebugMode) {
        debugPrint('Erro ao carregar ordens de serviço: $e');
      }
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> salvarOrdemServico(OrdemServico ordemServico) async {
    _errorMessage = null;
    notifyListeners();

    try {
      if (ordemServico.id == null) {
        await _repository.inserir(ordemServico);
      } else {
        await _repository.atualizar(ordemServico);
      }

      await carregarOrdensServico();

      return true;
    } catch (e) {
      _errorMessage = ordemServico.id == null
          ? 'Não foi possível cadastrar a ordem de serviço.'
          : 'Não foi possível atualizar a ordem de serviço.';

      if (kDebugMode) {
        debugPrint('Erro ao salvar ordem de serviço: $e');
      }

      notifyListeners();

      return false;
    }
  }

  Future<bool> excluirOrdemServico(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.excluir(id);

      await carregarOrdensServico();

      return true;
    } catch (e) {
      _errorMessage = 'Não foi possível excluir a ordem de serviço.';

      if (kDebugMode) {
        debugPrint('Erro ao excluir ordem de serviço $id: $e');
      }

      notifyListeners();

      return false;
    }
  }

  Future<void> alterarStatus(
    OrdemServico ordemServico,
    StatusOrdemServico novoStatus,
  ) async {
    if (ordemServico.status == novoStatus) return;

    final stateAtual = OrdemServicoStateFactory.criar(ordemServico.status);
    final erroValidacao = stateAtual.validarTransicao(ordemServico, novoStatus);

    if (erroValidacao != null) {
      throw Exception(erroValidacao);
    }

    await salvarOrdemServico(ordemServico.copyWith(status: novoStatus));
  }

  Future<OrdemServico?> buscarOrdemServicoPorId(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.buscarPorId(id);
    } catch (e) {
      _errorMessage = 'Não foi possível encontrar a ordem de serviço.';

      if (kDebugMode) {
        debugPrint('Erro ao buscar ordem de serviço $id: $e');
      }

      notifyListeners();

      return null;
    }
  }

  Future<OrdemServico?> buscarOrdemServicoPorNumero(String numero) async {
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.buscarPorNumero(numero);
    } catch (e) {
      _errorMessage = 'Não foi possível encontrar a ordem de serviço.';

      if (kDebugMode) {
        debugPrint('Erro ao buscar ordem de serviço $numero: $e');
      }

      notifyListeners();

      return null;
    }
  }

  void limparErro() {
    _errorMessage = null;
    notifyListeners();
  }
}
