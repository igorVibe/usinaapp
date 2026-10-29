import 'package:flutter/material.dart';

import '../../models/tipo_informacao.dart';
import '../../models/unidade_medida.dart';
import '../../services/api_service.dart';

class CadastroTipoInformacaoPage extends StatefulWidget {
  const CadastroTipoInformacaoPage({super.key});

  @override
  State<CadastroTipoInformacaoPage> createState() =>
      _CadastroTipoInformacaoPageState();
}

class _CadastroTipoInformacaoPageState extends State<CadastroTipoInformacaoPage> {
  final service = TipoInformacaoService();
  final unidadeMedidaService = UnidadeMedidaService();
  late Future<List<TipoInformacao>> dados;
  late Future<List<UnidadeMedida>> unidadesMedida;

  @override
  void initState() {
    super.initState();
    dados = service.listar();
    unidadesMedida = unidadeMedidaService.listar();
  }

  void recarregar() {
    setState(() {
      dados = service.listar();
      unidadesMedida = unidadeMedidaService.listar();
    });
  }

  Future<void> abrirFormulario([TipoInformacao? item]) async {
    final mudou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _TipoInformacaoFormPage(
          tipoInformacao: item,
          unidadesMedida: unidadesMedida,
        ),
      ),
    );

    if (mudou == true && mounted) {
      recarregar();
    }
  }

  Future<void> excluir(TipoInformacao item) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir tipo de informação?'),
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
        throw Exception('Tipo de informação sem ID.');
      }
      await service.excluir(item.id!);
      if (mounted) recarregar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir tipo de informação: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tipos de informação')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<TipoInformacao>>(
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
              child: Text('Nenhum tipo de informação cadastrado.'),
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
                  subtitle: Text(item.unidadeMedida.nome),
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

class _TipoInformacaoFormPage extends StatefulWidget {
  final TipoInformacao? tipoInformacao;
  final Future<List<UnidadeMedida>> unidadesMedida;

  const _TipoInformacaoFormPage({this.tipoInformacao, required this.unidadesMedida});

  @override
  State<_TipoInformacaoFormPage> createState() => _TipoInformacaoFormState();
}

class _TipoInformacaoFormState extends State<_TipoInformacaoFormPage> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  int? unidadeMedidaSelecionadaId;
  late Future<List<UnidadeMedida>> unidadesMedida;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    unidadesMedida = widget.unidadesMedida;
    if (widget.tipoInformacao != null) {
      nomeController.text = widget.tipoInformacao!.nome;
      unidadeMedidaSelecionadaId = widget.tipoInformacao!.unidadeMedida.id;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!formKey.currentState!.validate()) return;
    if (unidadeMedidaSelecionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma unidade de medida válida.')),
      );
      return;
    }

    setState(() => salvando = true);

    final item = TipoInformacao(
      id: widget.tipoInformacao?.id,
      nome: nomeController.text.trim(),
      unidadeMedida: UnidadeMedida(id: unidadeMedidaSelecionadaId, nome: '', simbolo: ''),
    );

    try {
      final service = TipoInformacaoService();
      if (item.id == null) {
        await service.criar(item);
      } else {
        await service.atualizar(item);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar tipo de informação: $e')),
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
          widget.tipoInformacao == null ? 'Novo tipo de informação' : 'Editar tipo de informação',
        ),
      ),
      body: Form(
        key: formKey,
        child: FutureBuilder<List<UnidadeMedida>>(
          future: unidadesMedida,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return const Center(child: Text('Nenhuma unidade de medida disponível.'));
            }

            if (unidadeMedidaSelecionadaId == null && list.isNotEmpty) {
              unidadeMedidaSelecionadaId ??= list.first.id;
            }

            return ListView(
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
                DropdownButtonFormField<int?>(
                  value: unidadeMedidaSelecionadaId,
                  decoration: const InputDecoration(
                    labelText: 'Unidade de medida',
                    border: OutlineInputBorder(),
                  ),
                  items: list
                      .map(
                        (item) => DropdownMenuItem<int?>(
                          value: item.id,
                          child: Text('${item.nome} (${item.simbolo})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => unidadeMedidaSelecionadaId = value),
                  validator: (value) =>
                      value == null ? 'Selecione uma unidade de medida.' : null,
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