import 'package:flutter/foundation.dart';
import 'package:ordem_servico/database/database_service.dart';
import 'package:ordem_servico/repositories/item_ordem_servico_repository.dart';
import '../core/states/ordem_servico_state_factory.dart';
import '../models/ordem_servico.dart';
import '../repositories/ordem_servico_repository.dart';
import '../models/tecnico.dart';
import '../repositories/equipamento_repository.dart';
import '../repositories/tecnico_repository.dart';
import '../core/utils/ordem_servico_calculator.dart';

class OrdemServicoController extends ChangeNotifier {
  OrdemServicoController({
    OrdemServicoRepository? ordemServicoRepository,
    EquipamentoRepository? equipamentoRepository,
    TecnicoRepository? tecnicoRepository,
    ItemOrdemServicoRepository? itemOrdemServicoRepository,
  }) : _repository =
           ordemServicoRepository ??
           OrdemServicoRepository(DatabaseService.instance),
       _equipamentoRepository =
           equipamentoRepository ??
           EquipamentoRepository(DatabaseService.instance),
       _tecnicoRepository =
           tecnicoRepository ?? TecnicoRepository(DatabaseService.instance),
       _itemOrdemServicoRepository =
           itemOrdemServicoRepository ??
           ItemOrdemServicoRepository(DatabaseService.instance);

  final OrdemServicoRepository _repository;
  final EquipamentoRepository _equipamentoRepository;
  final TecnicoRepository _tecnicoRepository;
  final ItemOrdemServicoRepository _itemOrdemServicoRepository;

  List<OrdemServico> _ordensServico = [];

  bool _carregando = false;

  String? _errorMessage;

  List<OrdemServico> get ordensServico => List.unmodifiable(_ordensServico);

  bool get carregando => _carregando;

  String? get errorMessage => _errorMessage;

  int get quantidadeOrdens => _ordensServico.length;

  int get quantidadeEmAtendimento {
    return _ordensServico
        .where((os) => os.status == StatusOrdemServico.emAtendimento)
        .length;
  }

  int get quantidadeConcluidas {
    return _ordensServico
        .where((os) => os.status == StatusOrdemServico.concluida)
        .length;
  }

  int get quantidadeCanceladas {
    return _ordensServico
        .where((os) => os.status == StatusOrdemServico.cancelada)
        .length;
  }

  int get quantidadeAbertas {
    return _ordensServico
        .where((os) => os.status == StatusOrdemServico.aberta)
        .length;
  }

  int get quantidadeUrgentes {
    return _ordensServico.where((os) => os.ordemUrgente).length;
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

  int get quantidadeAtrasadas {
    return _ordensServico.where((os) => os.ordemAtrasada).length;
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
      final erroRelacionamentos = await validarRelacionamentos(ordemServico);

      if (erroRelacionamentos != null) {
        _errorMessage = erroRelacionamentos;
        notifyListeners();

        return false;
      }

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

      notifyListeners();

      return false;
    }
  }

  Future<List<OrdemServico>> buscarOrdensPorCliente(int clienteId) async {
    _errorMessage = null;

    try {
      return await _repository.listarPorCliente(clienteId);
    } catch (e) {
      _errorMessage = 'Não foi possível buscar as ordens do cliente.';

      notifyListeners();

      return [];
    }
  }

  Future<List<OrdemServico>> buscarOrdensPorEquipamento(
    int equipamentoId,
  ) async {
    _errorMessage = null;

    try {
      return await _repository.listarPorEquipamento(equipamentoId);
    } catch (e) {
      _errorMessage = 'Não foi possível buscar as ordens do equipamento.';

      notifyListeners();

      return [];
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

      notifyListeners();

      return false;
    }
  }

  Future<bool> alterarStatus(
    OrdemServico ordemServico,
    StatusOrdemServico novoStatus,
  ) async {
    if (ordemServico.status == novoStatus) {
      return true;
    }

    final stateAtual = OrdemServicoStateFactory.criar(ordemServico.status);

    final erroValidacao = stateAtual.validarTransicao(ordemServico, novoStatus);

    if (erroValidacao != null) {
      _errorMessage = erroValidacao;
      notifyListeners();

      return false;
    }

    final ordemAtualizada = ordemServico.copyWith(status: novoStatus);

    return salvarOrdemServico(ordemAtualizada);
  }

  Future<OrdemServico?> buscarOrdemServicoPorId(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.buscarPorId(id);
    } catch (e) {
      _errorMessage = 'Não foi possível encontrar a ordem de serviço.';

      notifyListeners();

      return null;
    }
  }

  Future<double?> calcularValorTotalPorOrdemServicoId(
    int ordemServicoId,
  ) async {
    _errorMessage = null;

    try {
      final ordemServico = await _repository.buscarPorId(ordemServicoId);

      if (ordemServico == null) {
        _errorMessage = 'A ordem de serviço não foi encontrada.';
        notifyListeners();

        return null;
      }

      final itens = await _itemOrdemServicoRepository.listarPorOrdemServico(
        ordemServicoId,
      );

      return OrdemServicoCalculator.calcularValorTotal(
        valorMaoDeObra: ordemServico.valorMaoDeObra,
        itens: itens,
      );
    } catch (e) {
      _errorMessage =
          'Não foi possível calcular o valor total da ordem de serviço.';

      notifyListeners();

      return null;
    }
  }

  Future<String?> validarRelacionamentos(OrdemServico ordemServico) async {
    final equipamento = await _equipamentoRepository.buscarPorId(
      ordemServico.equipamentoId,
    );

    if (equipamento == null) {
      return 'O equipamento selecionado não foi encontrado.';
    }

    if (equipamento.clienteId != ordemServico.clienteId) {
      return 'O equipamento selecionado não pertence ao cliente informado.';
    }

    if (ordemServico.tecnicoId != null) {
      final tecnico = await _tecnicoRepository.buscarPorId(
        ordemServico.tecnicoId!,
      );

      if (tecnico == null) {
        return 'O técnico selecionado não foi encontrado.';
      }

      if (tecnico.situacao != SituacaoTecnico.ativo) {
        return 'Não é possível vincular um técnico inativo à ordem de serviço.';
      }
    }

    return null;
  }

  Future<OrdemServico?> buscarOrdemServicoPorNumero(String numero) async {
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.buscarPorNumero(numero);
    } catch (e) {
      _errorMessage = 'Não foi possível encontrar a ordem de serviço.';

      notifyListeners();

      return null;
    }
  }

  void limparErro() {
    _errorMessage = null;
    notifyListeners();
  }
}
