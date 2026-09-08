import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/tecnico_controller.dart';
import '../../models/tecnico.dart';

class TecnicoFormPage extends StatefulWidget {
  const TecnicoFormPage({super.key, this.tecnico});

  final Tecnico? tecnico;

  @override
  State<TecnicoFormPage> createState() => _TecnicoFormPageState();
}

class _TecnicoFormPageState extends State<TecnicoFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _contatoController;
  late final TextEditingController _especialidadeController;
  late SituacaoTecnico _situacao;

  bool _salvando = false;
  bool get _editando => widget.tecnico != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.tecnico?.nome ?? '');
    _contatoController = TextEditingController(
      text: widget.tecnico?.contato ?? '',
    );
    _especialidadeController = TextEditingController(
      text: widget.tecnico?.especialidade ?? '',
    );
    _situacao = widget.tecnico?.situacao ?? SituacaoTecnico.ativo;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _contatoController.dispose();
    _especialidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final tecnico = Tecnico(
      id: widget.tecnico?.id,
      nome: _nomeController.text.trim(),
      contato: _contatoController.text.trim(),
      especialidade: _especialidadeController.text.trim(),
      situacao: _situacao,
    );

    final controller = context.read<TecnicoController>();
    final sucesso = await controller.salvarTecnico(tecnico);

    if (!mounted) return;
    setState(() => _salvando = false);

    if (sucesso) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ?? 'Não foi possível salvar o técnico.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar técnico' : 'Novo técnico'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe o nome do técnico.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contatoController,
                decoration: const InputDecoration(
                  labelText: 'Contato *',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe o contato do técnico.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _especialidadeController,
                decoration: const InputDecoration(
                  labelText: 'Especialidade *',
                  prefixIcon: Icon(Icons.engineering_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe a especialidade.'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SituacaoTecnico>(
                initialValue: _situacao,
                decoration: const InputDecoration(
                  labelText: 'Situação',
                  prefixIcon: Icon(Icons.toggle_on_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: SituacaoTecnico.ativo,
                    child: Text('Ativo'),
                  ),
                  DropdownMenuItem(
                    value: SituacaoTecnico.inativo,
                    child: Text('Inativo'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _situacao = value);
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _salvando
                        ? 'Salvando...'
                        : _editando
                        ? 'Salvar alterações'
                        : 'Salvar técnico',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
