import 'package:flutter/material.dart';

import '../../models/medicao.dart';
import '../../models/safra.dart';
import '../../models/tipo_informacao.dart';
import '../../models/unidade.dart';
import '../../models/unidade_medida.dart';

class CadastroMedicaoPage extends StatefulWidget {
  const CadastroMedicaoPage({super.key});

  @override
  State<CadastroMedicaoPage> createState() =>
      _CadastroMedicaoPageState();
}

class _CadastroMedicaoPageState
    extends State<CadastroMedicaoPage> {
  final formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  final safraIdController = TextEditingController();
  final unidadeIdController = TextEditingController();
  final tipoInformacaoIdController = TextEditingController();
  final valorController = TextEditingController();

  DateTime dataMedicao = DateTime.now();

  @override
  void dispose() {
    idController.dispose();
    safraIdController.dispose();
    unidadeIdController.dispose();
    tipoInformacaoIdController.dispose();
    valorController.dispose();
    super.dispose();
  }

  String? validarNumeroInteiro(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Preencha este campo';
    }

    if (int.tryParse(valor.trim()) == null) {
      return 'Informe um número inteiro';
    }

    return null;
  }

  String? validarValor(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe o valor';
    }

    final valorConvertido = valor.trim().replaceAll(',', '.');

    if (double.tryParse(valorConvertido) == null) {
      return 'Informe um valor válido';
    }

    return null;
  }

  String formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  Future<void> selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataMedicao,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada != null) {
      setState(() {
        dataMedicao = dataSelecionada;
      });
    }
  }

  void salvar() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final safra = Safra(
      id: int.parse(safraIdController.text.trim()),
      nomeSafra: 'Safra selecionada',
      dataInicio: DateTime(dataMedicao.year, 1, 1),
      dataFim: DateTime(dataMedicao.year, 12, 31),
    );

    final unidade = Unidade(
      id: int.parse(unidadeIdController.text.trim()),
      nome: 'Unidade selecionada',
    );

    final unidadeMedida = UnidadeMedida(
      id: 0,
      nome: 'Unidade de medida',
      simbolo: '',
    );

    final tipoInformacao = TipoInformacao(
      id: int.parse(tipoInformacaoIdController.text.trim()),
      nome: 'Tipo de informação selecionado',
      unidadeMedida: unidadeMedida,
    );

    final medicao = Medicao(
      id: int.parse(idController.text.trim()),
      safra: safra,
      unidade: unidade,
      tipoInformacao: tipoInformacao,
      valor: double.parse(
        valorController.text.trim().replaceAll(',', '.'),
      ),
      data: dataMedicao,
    );

    debugPrint('ID: ${medicao.id}');
    debugPrint('Safra ID: ${medicao.safra.id}');
    debugPrint('Unidade ID: ${medicao.unidade.id}');
    debugPrint(
      'Tipo de informação ID: ${medicao.tipoInformacao.id}',
    );
    debugPrint('Valor: ${medicao.valor}');
    debugPrint('Data: ${medicao.data}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medição cadastrada com sucesso!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Medição'),
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
                  labelText: 'ID da medição',
                  border: OutlineInputBorder(),
                ),
                validator: validarNumeroInteiro,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: safraIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID da safra',
                  border: OutlineInputBorder(),
                ),
                validator: validarNumeroInteiro,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: unidadeIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID da unidade',
                  border: OutlineInputBorder(),
                ),
                validator: validarNumeroInteiro,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: tipoInformacaoIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID do tipo de informação',
                  border: OutlineInputBorder(),
                ),
                validator: validarNumeroInteiro,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor da medição',
                  hintText: 'Exemplo: 25,5',
                  border: OutlineInputBorder(),
                ),
                validator: validarValor,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: selecionarData,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  'Data: ${formatarData(dataMedicao)}',
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