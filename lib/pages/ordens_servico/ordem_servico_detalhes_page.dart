import 'package:flutter/material.dart';
import 'package:ordem_servico/controllers/ordem_servico_controller.dart';
import 'package:ordem_servico/models/ordem_servico.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'ordem_servico_form_page.dart';

class OrdemServicoDetalhesPage extends StatefulWidget {
  const OrdemServicoDetalhesPage({super.key, required this.ordemServicoId});

  final int ordemServicoId;

  @override
  State<OrdemServicoDetalhesPage> createState() =>
      _OrdemServicoDetalhesPageState();
}

class _OrdemServicoDetalhesPageState extends State<OrdemServicoDetalhesPage> {
  OrdemServico? _os;
  double? _total;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final c = context.read<OrdemServicoController>();
    final os = await c.buscarOrdemServicoPorId(widget.ordemServicoId);
    final total = await c.calcularValorTotalPorOrdemServicoId(
      widget.ordemServicoId,
    );
    if (!mounted) return;
    setState(() {
      _os = os;
      _total = total;
      _carregando = false;
    });
  }

  Future<void> _trocarStatus(StatusOrdemServico status) async {
    if (_os == null) return;

    if (status == StatusOrdemServico.concluida) {
      final diagVazio = _os!.diagnostico.trim().isEmpty;
      final solVazia = _os!.solucao.trim().isEmpty;

      if (diagVazio && solVazia) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A OS só pode ser concluída com diagnóstico ou solução preenchidos. Edite a OS primeiro.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final c = context.read<OrdemServicoController>();
    final ok = await c.alterarStatus(_os!, status);

    if (!mounted) return;

    if (ok) {
      _carregar();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(c.errorMessage ?? 'Transição de status inválida.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_os == null) {
      return const Scaffold(body: Center(child: Text('OS não encontrada.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('OS #${_os!.numero}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => OrdemServicoFormPage(ordemServico: _os),
                ),
              );
              if (ok == true) _carregar();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${_os!.status.name.toUpperCase()} • Prioridade: ${_os!.prioridade.name.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Descrição do Problema:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(_os!.descricaoProblema),
                  const SizedBox(height: 12),
                  const Text(
                    'Diagnóstico Técnico:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(_os!.diagnostico.isEmpty ? 'Nenhum' : _os!.diagnostico),
                  const SizedBox(height: 12),
                  const Text(
                    'Solução:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(_os!.solucao.isEmpty ? 'Nenhuma' : _os!.solucao),
                  const Divider(height: 24),
                  Text(
                    'Mão de obra: R\$ ${_os!.valorMaoDeObra.toStringAsFixed(2)}',
                  ),
                  if (_os!.fotoPath != null && _os!.fotoPath!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Evidência / Foto:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 320,
                          maxHeight: 200,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_os!.fotoPath!),
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Imagem não encontrada no dispositivo.',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  Text(
                    'Valor Total (com itens): R\$ ${(_total ?? _os!.valorMaoDeObra).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Alterar Situação:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: StatusOrdemServico.values.map((s) {
              return ChoiceChip(
                label: Text(s.name.toUpperCase()),
                selected: _os!.status == s,
                onSelected: (val) {
                  if (val && _os!.status != s) _trocarStatus(s);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
