import 'package:flutter/material.dart';

import '../../models/equipamento.dart';
import '../../models/unidade.dart';
import '../../services/api_service.dart';

class CadastroEquipamentoPage extends StatefulWidget {
  const CadastroEquipamentoPage({super.key});

  @override
  State<CadastroEquipamentoPage> createState() => _CadastroEquipamentoPageState();
}

class _CadastroEquipamentoPageState extends State<CadastroEquipamentoPage> {
  final service = EquipamentoService();
  final unidadeService = UnidadeService();
  late Future<List<Equipamento>> dados;
  late Future<List<Unidade>> unidades;

  @override
  void initState() {
    super.initState();
    dados = service.listar();
    unidades = unidadeService.listar();
  }

  void recarregar() {
    setState(() {
      dados = service.listar();
      unidades = unidadeService.listar();
    });
  }

  Future<void> abrirFormulario([Equipamento? item]) async {
    final mudou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _EquipamentoFormPage(
          equipamento: item,
          unidades: unidades,
        ),
      ),
    );

    if (mudou == true && mounted) {
      recarregar();
    }
  }

  Future<void> excluir(Equipamento item) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir equipamento?'),
        content: Text(item.nome),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirma != true) return;

    try {
      if (item.id == null) {
        throw Exception('Equipamento sem ID.');
      }
      await service.excluir(item.id!);
      if (mounted) recarregar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir equipamento: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipamentos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Equipamento>>(
        future: dados,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Erro: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: recarregar,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final itens = snapshot.data ?? [];
          if (itens.isEmpty) {
            return const Center(child: Text('Nenhum equipamento cadastrado.'));
          }

          return RefreshIndicator(
            onRefresh: () async => recarregar(),
            child: ListView.builder(
              itemCount: itens.length,
              itemBuilder: (context, index) {
                final item = itens[index];
                return ListTile(
                  title: Text(item.nome),
                  subtitle: Text(item.unidade.nome),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => abrirFormulario(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => excluir(item),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EquipamentoFormPage extends StatefulWidget {
  final Equipamento? equipamento;
  final Future<List<Unidade>> unidades;

  const _EquipamentoFormPage({this.equipamento, required this.unidades});

  @override
  State<_EquipamentoFormPage> createState() => _EquipamentoFormState();
}

class _EquipamentoFormState extends State<_EquipamentoFormPage> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  int? unidadeSelecionadaId;
  late Future<List<Unidade>> unidades;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    unidades = widget.unidades;
    if (widget.equipamento != null) {
      nomeController.text = widget.equipamento!.nome;
      unidadeSelecionadaId = widget.equipamento!.unidade.id;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!formKey.currentState!.validate()) return;
    if (unidadeSelecionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma unidade válida.')),
      );
      return;
    }

    setState(() => salvando = true);

    final item = Equipamento(
      id: widget.equipamento?.id,
      nome: nomeController.text.trim(),
      unidade: Unidade(id: unidadeSelecionadaId, nome: ''),
    );

    try {
      final service = EquipamentoService();
      if (item.id == null) {
        await service.criar(item);
      } else {
        await service.atualizar(item);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar equipamento: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.equipamento == null ? 'Novo equipamento' : 'Editar equipamento',
        ),
      ),
      body: Form(
        key: formKey,
        child: FutureBuilder<List<Unidade>>(
          future: unidades,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return const Center(child: Text('Nenhuma unidade disponível.'));
            }

            if (unidadeSelecionadaId == null && list.isNotEmpty) {
              unidadeSelecionadaId ??= list.first.id;
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do equipamento',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Informe o nome.' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  value: unidadeSelecionadaId,
                  decoration: const InputDecoration(
                    labelText: 'Unidade',
                    border: OutlineInputBorder(),
                  ),
                  items: list
                      .map(
                        (item) => DropdownMenuItem<int?>(
                          value: item.id,
                          child: Text(item.nome),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => unidadeSelecionadaId = value),
                  validator: (value) =>
                      value == null ? 'Selecione uma unidade.' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: salvando ? null : salvar,
                  child: Text(salvando ? 'Salvando...' : 'Salvar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}