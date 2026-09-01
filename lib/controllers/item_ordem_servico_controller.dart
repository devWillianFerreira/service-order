import 'package:flutter/foundation.dart';
import 'package:ordem_servico/database/database_service.dart';

import '../models/item_ordem_servico.dart';
import '../repositories/item_ordem_servico_repository.dart';

class ItemOrdemServicoController extends ChangeNotifier {
  ItemOrdemServicoController({
    ItemOrdemServicoRepository? itemOrdemServicoRepository,
  }) : _repository =
           itemOrdemServicoRepository ??
           ItemOrdemServicoRepository(DatabaseService.instance);

  final ItemOrdemServicoRepository _repository;

  List<ItemOrdemServico> _itens = [];

  bool _carregando = false;

  String? _errorMessage;

  List<ItemOrdemServico> get itens => List.unmodifiable(_itens);

  bool get carregando => _carregando;

  String? get errorMessage => _errorMessage;

  int get quantidadeItens => _itens.length;

  double get totalItens {
    return _itens.fold<double>(0, (total, item) => total + item.subtotal);
  }

  Future<void> carregarItensPorOrdemServico(int ordemServicoId) async {
    _carregando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _itens = await _repository.listarPorOrdemServico(ordemServicoId);
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os itens da ordem de serviço.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> salvarItem(ItemOrdemServico item) async {
    _errorMessage = null;
    notifyListeners();

    try {
      if (item.id == null) {
        await _repository.inserir(item);
      } else {
        await _repository.atualizar(item);
      }

      await carregarItensPorOrdemServico(item.ordemServicoId);

      return true;
    } catch (e) {
      _errorMessage = item.id == null
          ? 'Não foi possível adicionar o item à ordem de serviço.'
          : 'Não foi possível atualizar o item da ordem de serviço.';

      notifyListeners();

      return false;
    }
  }

  Future<bool> excluirItem(int id, int ordemServicoId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.excluir(id);

      await carregarItensPorOrdemServico(ordemServicoId);

      return true;
    } catch (e) {
      _errorMessage = 'Não foi possível excluir o item da ordem de serviço.';

      notifyListeners();

      return false;
    }
  }

  Future<ItemOrdemServico?> buscarItemPorId(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.buscarPorId(id);
    } catch (e) {
      _errorMessage = 'Não foi possível encontrar o item da ordem de serviço.';

      notifyListeners();

      return null;
    }
  }

  void limparItens() {
    _itens = [];
    notifyListeners();
  }

  void limparErro() {
    _errorMessage = null;
    notifyListeners();
  }
}
