import 'package:flutter/material.dart';

import '../../models/safra.dart';
import '../../services/api_service.dart';

String formatarDataSimples(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

class CadastroSafraPage extends StatefulWidget {
  const CadastroSafraPage({super.key});

  @override
  State<CadastroSafraPage> createState() => _CadastroSafraPageState();
}

class _CadastroSafraPageState extends State<CadastroSafraPage> {
  final service = SafraService();
  late Future<List<Safra>> dados;

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

  Future<void> abrirFormulario([Safra? item]) async {
    final mudou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _SafraFormPage(safra: item),
      ),
    );

    if (mudou == true && mounted) {
      recarregar();
    }
  }

  Future<void> excluir(Safra item) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir safra?'),
        content: Text(item.nomeSafra),
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
        throw Exception('Safra sem ID.');
      }
      await service.excluir(item.id!);
      if (mounted) recarregar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir safra: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safras')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Safra>>(
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
            return const Center(child: Text('Nenhuma safra cadastrada.'));
          }

          return RefreshIndicator(
            onRefresh: () async => recarregar(),
            child: ListView.builder(
              itemCount: itens.length,
              itemBuilder: (context, index) {
                final item = itens[index];
                return ListTile(
                  title: Text(item.nomeSafra),
                  subtitle: Text(
                    '${formatarDataSimples(item.dataInicio)} - ${formatarDataSimples(item.dataFim)}',
                  ),
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

class _SafraFormPage extends StatefulWidget {
  final Safra? safra;

  const _SafraFormPage({this.safra});

  @override
  State<_SafraFormPage> createState() => _SafraFormState();
}

class _SafraFormState extends State<_SafraFormPage> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  DateTime? dataInicio;
  DateTime? dataFim;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    final item = widget.safra;
    if (item != null) {
      nomeController.text = item.nomeSafra;
      dataInicio = item.dataInicio;
      dataFim = item.dataFim;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  Future<void> selecionarDataInicio() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: dataInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() => dataInicio = selected);
    }
  }

  Future<void> selecionarDataFim() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: dataFim ?? dataInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() => dataFim = selected);
    }
  }

  Future<void> salvar() async {
    if (!formKey.currentState!.validate()) return;
    if (dataInicio == null || dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione as datas da safra.')),
      );
      return;
    }
    if (dataFim!.isBefore(dataInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A data final não pode ser anterior à inicial.')),
      );
      return;
    }

    setState(() => salvando = true);

    final item = Safra(
      id: widget.safra?.id,
      nomeSafra: nomeController.text.trim(),
      dataInicio: dataInicio!,
      dataFim: dataFim!,
    );

    try {
      final service = SafraService();
      if (item.id == null) {
        await service.criar(item);
      } else {
        await service.atualizar(item);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar safra: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.safra == null ? 'Nova safra' : 'Editar safra'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da safra',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Informe o nome da safra.'
                      : null,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: selecionarDataInicio,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                dataInicio == null
                    ? 'Selecionar data inicial'
                    : 'Data inicial: ${formatarDataSimples(dataInicio!)}',
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: selecionarDataFim,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                dataFim == null
                    ? 'Selecionar data final'
                    : 'Data final: ${formatarDataSimples(dataFim!)}',
              ),
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