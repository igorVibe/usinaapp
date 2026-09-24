import 'package:flutter/material.dart';
import '../../models/safra.dart';

class CadastroSafraPage extends StatefulWidget {
  const CadastroSafraPage({super.key});

  @override
  State<CadastroSafraPage> createState() =>
      _CadastroSafraPageState();
}

class _CadastroSafraPageState extends State<CadastroSafraPage> {
  final formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  final nomeController = TextEditingController();

  DateTime? dataInicio;
  DateTime? dataFim;

  @override
  void dispose() {
    idController.dispose();
    nomeController.dispose();
    super.dispose();
  }

  Future<void> selecionarDataInicio() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada != null) {
      setState(() {
        dataInicio = dataSelecionada;
      });
    }
  }

  Future<void> selecionarDataFim() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataFim ?? dataInicio ?? DateTime.now(),
      firstDate: dataInicio ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada != null) {
      setState(() {
        dataFim = dataSelecionada;
      });
    }
  }

  String formatarData(DateTime? data) {
    if (data == null) {
      return 'Selecionar data';
    }

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  void salvar() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (dataInicio == null || dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione as datas da safra'),
        ),
      );
      return;
    }

    if (dataFim!.isBefore(dataInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A data final não pode ser anterior à inicial',
          ),
        ),
      );
      return;
    }

    final safra = Safra(
      id: int.parse(idController.text.trim()),
      nomeSafra: nomeController.text.trim(),
      dataInicio: dataInicio!,
      dataFim: dataFim!,
    );

    debugPrint('ID: ${safra.id}');
    debugPrint('Safra: ${safra.nomeSafra}');
    debugPrint('Início: ${safra.dataInicio}');
    debugPrint('Fim: ${safra.dataFim}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Safra cadastrada com sucesso!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Safra'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o ID';
                  }

                  if (int.tryParse(valor.trim()) == null) {
                    return 'Informe um número inteiro';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da safra',
                  hintText: 'Exemplo: Safra 2026/2027',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o nome da safra';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: selecionarDataInicio,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  'Data inicial: ${formatarData(dataInicio)}',
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: selecionarDataFim,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  'Data final: ${formatarData(dataFim)}',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: salvar,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}