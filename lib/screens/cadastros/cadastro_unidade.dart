import 'package:flutter/material.dart';

import '../../models/unidade.dart';
import '../../services/api_service.dart';

class CadastroUnidadePage extends StatefulWidget {
  const CadastroUnidadePage({super.key});

  @override
  State<CadastroUnidadePage> createState() => _CadastroUnidadePageState();
}

class _CadastroUnidadePageState extends State<CadastroUnidadePage> {
  final service = UnidadeService();
  late Future<List<Unidade>> dados;

  @override
  void initState() {
    super.initState();
    dados = service.listar();
  }

  void recarregar() {
    setState(() {
      dados = service.listar();
    });
  }

  Future<void> abrirFormulario([Unidade? item]) async {
    final mudou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _UnidadeFormPage(unidade: item),
      ),
    );

    if (mudou == true && mounted) {
      recarregar();
    }
  }

  Future<void> excluir(Unidade item) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir unidade?'),
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
        throw Exception('Unidade sem ID.');
      }
      await service.excluir(item.id!);
      if (mounted) recarregar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir unidade: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unidades')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Unidade>>(
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
                  )
                ],
              ),
            );
          }

          final itens = snapshot.data ?? [];
          if (itens.isEmpty) {
            return const Center(child: Text('Nenhuma unidade cadastrada.'));
          }

          return RefreshIndicator(
            onRefresh: () async => recarregar(),
            child: ListView.builder(
              itemCount: itens.length,
              itemBuilder: (context, index) {
                final item = itens[index];
                return ListTile(
                  title: Text(item.nome),
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

class _UnidadeFormPage extends StatefulWidget {
  final Unidade? unidade;

  const _UnidadeFormPage({this.unidade});

  @override
  State<_UnidadeFormPage> createState() => _UnidadeFormState();
}

class _UnidadeFormState extends State<_UnidadeFormPage> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.unidade != null) {
      nomeController.text = widget.unidade!.nome;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => salvando = true);

    final item = Unidade(
      id: widget.unidade?.id,
      nome: nomeController.text.trim(),
    );

    try {
      final service = UnidadeService();
      if (item.id == null) {
        await service.criar(item);
      } else {
        await service.atualizar(item);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar unidade: $e')),
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
        title: Text(widget.unidade == null ? 'Nova unidade' : 'Editar unidade'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Informe o nome.' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: salvando ? null : salvar,
              child: Text(salvando ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}