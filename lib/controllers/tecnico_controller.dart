import 'package:flutter/foundation.dart';
import 'package:ordem_servico/database/database_service.dart';

import '../models/tecnico.dart';
import '../repositories/tecnico_repository.dart';

class TecnicoController extends ChangeNotifier {
  TecnicoController({TecnicoRepository? tecnicoRepository})
    : _repository =
          tecnicoRepository ?? TecnicoRepository(DatabaseService.instance);

  final TecnicoRepository _repository;

  List<Tecnico> _tecnicos = [];
  bool _carregando = false;
  String? _errorMessage;

  List<Tecnico> get tecnicos => List.unmodifiable(_tecnicos);
  bool get carregando => _carregando;
  String? get errorMessage => _errorMessage;

  Future<void> carregarTecnicos() async {
    _carregando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tecnicos = await _repository.listar();
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os técnicos.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> salvarTecnico(Tecnico tecnico) async {
    _errorMessage = null;
    notifyListeners();

    try {
      if (tecnico.id == null) {
        await _repository.inserir(tecnico);
      } else {
        await _repository.atualizar(tecnico);
      }

      await carregarTecnicos();
      return true;
    } catch (e) {
      _errorMessage = tecnico.id == null
          ? 'Não foi possível cadastrar o técnico.'
          : 'Não foi possível atualizar o técnico.';

      notifyListeners();
      return false;
    }
  }

  Future<bool> excluirTecnico(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.excluir(id);
      await carregarTecnicos();
      return true;
    } catch (e) {
      _errorMessage = 'Não foi possível excluir o técnico.';

      notifyListeners();
      return false;
    }
  }
}
