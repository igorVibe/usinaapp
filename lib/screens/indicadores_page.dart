
import 'package:flutter/material.dart';
import '../models/indicador.dart';
import '../services/indicador_service.dart';
import 'cadastros/cadastro_indicador.dart';

class IndicadoresPage extends StatefulWidget {
  const IndicadoresPage({super.key});

  @override
  State<IndicadoresPage> createState() =>
      _IndicadoresPageState();
}

class _IndicadoresPageState extends State<IndicadoresPage> {
  final service = IndicadorService();
  late Future<List<Indicador>> dados;

  @override
  void initState() {
    super.initState();
    dados = service.listar();
  }

  void recarregar() {
    setState(() => dados = service.listar());
  }

  Future<void> abrirFormulario([Indicador? item]) async {
    final mudou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroIndicadorPage(
          indicador: item,
        ),
      ),
    );

    if (mudou == true && mounted) {
      recarregar();
    }
  }

  Future<void> excluir(Indicador item) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir indicador?'),
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
        throw Exception('Indicador sem ID');
      }

      await service.excluir(item.id!);

      if (mounted) recarregar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciar indicadores'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => abrirFormulario(),
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder<List<Indicador>>(
          future: dados,
          builder: (context, s) {
            if (s.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (s.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Erro: ${s.error}'),
                    ElevatedButton(
                      onPressed: recarregar,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            final itens = s.data ?? [];

            if (itens.isEmpty) {
              return const Center(
                child: Text('Nenhum indicador cadastrado'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                recarregar();
                await dados;
              },
              child: ListView.builder(
                itemCount: itens.length,
                itemBuilder: (context, i) {
                  final item = itens[i];

                  return ListTile(
                    title: Text(item.nome),
                    subtitle: Text(item.descricao),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              abrirFormulario(item),
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
