import 'package:flutter/material.dart';

import '../../models/equipamento.dart';
import '../../models/medicao.dart';
import '../../models/safra.dart';
import '../../models/tipo_informacao.dart';
import '../../services/api_service.dart';

class CadastroMedicaoPage extends StatefulWidget {
  const CadastroMedicaoPage({super.key});

  @override
  State<CadastroMedicaoPage> createState() => _CadastroMedicaoPageState();
}

class _CadastroMedicaoPageState extends State<CadastroMedicaoPage> {
  final service = MedicaoService();
  final safraService = SafraService();
  final equipamentoService = EquipamentoService();
  final tipoInformacaoService = TipoInformacaoService();
  late Future<List<Medicao>> dados;
  late Future<List<Safra>> safras;
  late Future<List<Equipamento>> equipamentos;
  late Future<List<TipoInformacao>> tiposInformacao;

  @override
  void initState() {
    super.initState();
    dados = service.listar();
    safras = safraService.listar();
    equipamentos = equipamentoService.listar();
    tiposInformacao = tipoInformacaoService.listar();
  }

  void recarregar() {
    setState(() {
      dados = service.listar();
      safras = safraService.listar();
      equipamentos = equipamentoService.listar();
      tiposInformacao = tipoInformacaoService.listar();
    });
  }

  Future<void> abrirFormulario([Medicao? item]) async {
    final mudou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _MedicaoFormPage(
          medicao: item,
          safras: safras,
          equipamentos: equipamentos,
          tiposInformacao: tiposInformacao,
        ),
      ),
    );

    if (mudou == true && mounted) {
      recarregar();
    }
  }

  Future<void> excluir(Medicao item) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir medição?'),
        content: Text('Valor: ${item.valor}'),
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
        throw Exception('Medição sem ID.');
      }
      await service.excluir(item.id!);
      if (mounted) recarregar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir medição: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medições')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Medicao>>(
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
            return const Center(child: Text('Nenhuma medição cadastrada.'));
          }

          return RefreshIndicator(
            onRefresh: () async => recarregar(),
            child: ListView.builder(
              itemCount: itens.length,
              itemBuilder: (context, index) {
                final item = itens[index];
                return ListTile(
                  title: Text(item.valor.toStringAsFixed(2)),
                  subtitle: Text(
                    'Safra ${item.safraId} • Equipamento ${item.equipamentoId} • Tipo ${item.tipoInformacaoId}',
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

class _MedicaoFormPage extends StatefulWidget {
  final Medicao? medicao;
  final Future<List<Safra>> safras;
  final Future<List<Equipamento>> equipamentos;
  final Future<List<TipoInformacao>> tiposInformacao;

  const _MedicaoFormPage({
    this.medicao,
    required this.safras,
    required this.equipamentos,
    required this.tiposInformacao,
  });

  @override
  State<_MedicaoFormPage> createState() => _MedicaoFormState();
}

class _MedicaoFormState extends State<_MedicaoFormPage> {
  final formKey = GlobalKey<FormState>();
  final valorController = TextEditingController();
  int? safraSelecionadaId;
  int? equipamentoSelecionadoId;
  int? tipoInformacaoSelecionadoId;
  DateTime dataHora = DateTime.now();
  bool salvando = false;
  late Future<List<Safra>> safras;
  late Future<List<Equipamento>> equipamentos;
  late Future<List<TipoInformacao>> tiposInformacao;

  @override
  void initState() {
    super.initState();
    safras = widget.safras;
    equipamentos = widget.equipamentos;
    tiposInformacao = widget.tiposInformacao;
    if (widget.medicao != null) {
      valorController.text = widget.medicao!.valor.toString();
      safraSelecionadaId = widget.medicao!.safraId;
      equipamentoSelecionadoId = widget.medicao!.equipamentoId;
      tipoInformacaoSelecionadoId = widget.medicao!.tipoInformacaoId;
      dataHora = widget.medicao!.data;
    }
  }

  @override
  void dispose() {
    valorController.dispose();
    super.dispose();
  }

  Future<void> selecionarDataHora() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataHora,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada == null) return;

    final horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dataHora),
    );

    if (horaSelecionada == null) return;

    setState(() {
      dataHora = DateTime(
        dataSelecionada.year,
        dataSelecionada.month,
        dataSelecionada.day,
        horaSelecionada.hour,
        horaSelecionada.minute,
      );
    });
  }

  Future<void> salvar() async {
    if (!formKey.currentState!.validate()) return;
    if (safraSelecionadaId == null ||
        equipamentoSelecionadoId == null ||
        tipoInformacaoSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione todos os relacionamentos obrigatórios.')),
      );
      return;
    }

    setState(() => salvando = true);

    final item = Medicao(
      id: widget.medicao?.id,
      safraId: safraSelecionadaId!,
      equipamentoId: equipamentoSelecionadoId!,
      tipoInformacaoId: tipoInformacaoSelecionadoId!,
      valor: double.tryParse(valorController.text.trim().replaceAll(',', '.')) ?? 0,
      data: dataHora,
    );

    try {
      final service = MedicaoService();
      if (item.id == null) {
        await service.criar(item);
      } else {
        await service.atualizar(item);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar medição: $e')),
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
        title: Text(widget.medicao == null ? 'Nova medição' : 'Editar medição'),
      ),
      body: Form(
        key: formKey,
        child: FutureBuilder<List<Safra>>(
          future: safras,
          builder: (context, snapshotSafra) {
            if (snapshotSafra.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            return FutureBuilder<List<Equipamento>>(
              future: equipamentos,
              builder: (context, snapshotEquipamento) {
                if (snapshotEquipamento.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                return FutureBuilder<List<TipoInformacao>>(
                  future: tiposInformacao,
                  builder: (context, snapshotTipo) {
                    if (snapshotTipo.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final safrasLista = snapshotSafra.data ?? [];
                    final equipamentosLista = snapshotEquipamento.data ?? [];
                    final tiposLista = snapshotTipo.data ?? [];

                    if (safrasLista.isEmpty ||
                        equipamentosLista.isEmpty ||
                        tiposLista.isEmpty) {
                      return const Center(
                        child: Text('Cadastre etidades relacionadas antes de criar medições.'),
                      );
                    }

                    safraSelecionadaId ??= safrasLista.first.id;
                    equipamentoSelecionadoId ??= equipamentosLista.first.id;
                    tipoInformacaoSelecionadoId ??= tiposLista.first.id;

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        DropdownButtonFormField<int?>(
                          value: safraSelecionadaId,
                          decoration: const InputDecoration(
                            labelText: 'Safra',
                            border: OutlineInputBorder(),
                          ),
                          items: safrasLista
                              .map(
                                (item) => DropdownMenuItem<int?>(
                                  value: item.id,
                                  child: Text(item.nomeSafra),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => safraSelecionadaId = value),
                          validator: (value) => value == null ? 'Selecione uma safra.' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int?>(
                          value: equipamentoSelecionadoId,
                          decoration: const InputDecoration(
                            labelText: 'Equipamento',
                            border: OutlineInputBorder(),
                          ),
                          items: equipamentosLista
                              .map(
                                (item) => DropdownMenuItem<int?>(
                                  value: item.id,
                                  child: Text(item.nome),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => equipamentoSelecionadoId = value),
                          validator: (value) => value == null ? 'Selecione um equipamento.' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int?>(
                          value: tipoInformacaoSelecionadoId,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de informação',
                            border: OutlineInputBorder(),
                          ),
                          items: tiposLista
                              .map(
                                (item) => DropdownMenuItem<int?>(
                                  value: item.id,
                                  child: Text(item.nome),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => tipoInformacaoSelecionadoId = value),
                          validator: (value) => value == null ? 'Selecione um tipo de informação.' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: valorController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Valor',
                            hintText: 'Exemplo: 25,5',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o valor.';
                            }
                            if (double.tryParse(value.trim().replaceAll(',', '.')) == null) {
                              return 'Informe um valor numérico válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: selecionarDataHora,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            'Data e hora: ${dataHora.day.toString().padLeft(2, '0')}/${dataHora.month.toString().padLeft(2, '0')}/${dataHora.year} ${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: salvando ? null : salvar,
                          child: Text(salvando ? 'Salvando...' : 'Salvar'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}