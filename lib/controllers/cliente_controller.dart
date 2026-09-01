import 'package:flutter/foundation.dart';
import 'package:ordem_servico/database/database_service.dart';
import '../models/cliente.dart';
import '../repositories/cliente_repository.dart';

class ClienteController extends ChangeNotifier {
  ClienteController({ClienteRepository? clienteRepository})
    : _repository =
          clienteRepository ?? ClienteRepository(DatabaseService.instance);

  final ClienteRepository _repository;

  List<Cliente> _clientes = [];

  bool _isLoading = false;

  String? _errorMessage;

  List<Cliente> get clientes => List.unmodifiable(_clientes);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> carregarClientes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _clientes = await _repository.listar();
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os clientes.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> salvarCliente(Cliente cliente) async {
    _errorMessage = null;
    notifyListeners();

    try {
      if (cliente.id == null) {
        await _repository.inserir(cliente);
      } else {
        await _repository.atualizar(cliente);
      }

      await carregarClientes();

      return true;
    } catch (e) {
      _errorMessage = cliente.id == null
          ? 'Não foi possível cadastrar o cliente.'
          : 'Não foi possível atualizar o cliente.';

      notifyListeners();

      return false;
    }
  }

  Future<bool> excluirCliente(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.excluir(id);

      await carregarClientes();

      return true;
    } catch (e) {
      _errorMessage = 'Não foi possível excluir o cliente.';

      notifyListeners();

      return false;
    }
  }

  Future<Cliente?> buscarClientePorId(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.buscarPorId(id);
    } catch (e) {
      _errorMessage = 'Não foi possível encontrar o cliente.';

      notifyListeners();

      return null;
    }
  }

  void limparErro() {
    _errorMessage = null;
    notifyListeners();
  }
}
