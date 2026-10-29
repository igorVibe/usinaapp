import 'package:flutter/material.dart';

import '../../models/unidade_medida.dart';
import '../../services/api_service.dart';

class CadastroUnidadeMedidaPage extends StatefulWidget {
  const CadastroUnidadeMedidaPage({super.key});

  @override
  State<CadastroUnidadeMedidaPage> createState() =>
      _CadastroUnidadeMedidaPageState();
}

class _CadastroUnidadeMedidaPageState extends State<CadastroUnidadeMedidaPage> {
  final service = UnidadeMedidaService();
  late Future<List<UnidadeMedida>> dados;

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

  Future<void> abrirFormulario([UnidadeMedida? item]) async {
    final mudou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _UnidadeMedidaFormPage(unidadeMedida: item),
      ),
    );

    if (mudou == true && mounted) {
      recarregar();
    }
  }

  Future<void> excluir(UnidadeMedida item) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir unidade de medida?'),
        content: Text('${item.nome} (${item.simbolo})'),
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
        throw Exception('Unidade de medida sem ID.');
      }
      await service.excluir(item.id!);
      if (mounted) recarregar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir unidade de medida: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unidades de medida')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<UnidadeMedida>>(
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
            return const Center(
              child: Text('Nenhuma unidade de medida cadastrada.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => recarregar(),
            child: ListView.builder(
              itemCount: itens.length,
              itemBuilder: (context, index) {
                final item = itens[index];
                return ListTile(
                  title: Text(item.nome),
                  subtitle: Text(item.simbolo),
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

class _UnidadeMedidaFormPage extends StatefulWidget {
  final UnidadeMedida? unidadeMedida;

  const _UnidadeMedidaFormPage({this.unidadeMedida});

  @override
  State<_UnidadeMedidaFormPage> createState() => _UnidadeMedidaFormState();
}

class _UnidadeMedidaFormState extends State<_UnidadeMedidaFormPage> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final simboloController = TextEditingController();
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.unidadeMedida != null) {
      nomeController.text = widget.unidadeMedida!.nome;
      simboloController.text = widget.unidadeMedida!.simbolo;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    simboloController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => salvando = true);

    final item = UnidadeMedida(
      id: widget.unidadeMedida?.id,
      nome: nomeController.text.trim(),
      simbolo: simboloController.text.trim(),
    );

    try {
      final service = UnidadeMedidaService();
      if (item.id == null) {
        await service.criar(item);
      } else {
        await service.atualizar(item);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar unidade de medida: $e')),
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
          widget.unidadeMedida == null
              ? 'Nova unidade de medida'
              : 'Editar unidade de medida',
        ),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: simboloController,
              decoration: const InputDecoration(
                labelText: 'Símbolo',
                hintText: 'kg, °C, m',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Informe o símbolo.' : null,
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