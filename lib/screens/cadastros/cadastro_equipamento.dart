import 'package:flutter/material.dart';

import '../../models/equipamento.dart';
import '../../models/unidade.dart';

class CadastroEquipamentoPage extends StatefulWidget {
  const CadastroEquipamentoPage({super.key});

  @override
  State<CadastroEquipamentoPage> createState() =>
      _CadastroEquipamentoPageState();
}

class _CadastroEquipamentoPageState
    extends State<CadastroEquipamentoPage> {
  final formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  final nomeController = TextEditingController();
  final unidadeIdController = TextEditingController();
  final unidadeNomeController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    nomeController.dispose();
    unidadeIdController.dispose();
    unidadeNomeController.dispose();
    super.dispose();
  }

  String? validarTexto(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Preencha este campo';
    }

    return null;
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

  void salvar() {
    if (formKey.currentState!.validate()) {
      final unidade = Unidade(
        id: int.parse(unidadeIdController.text.trim()),
        nome: unidadeNomeController.text.trim(),
      );

      final equipamento = Equipamento(
        id: int.parse(idController.text.trim()),
        nome: nomeController.text.trim(),
        unidade: unidade,
      );

      debugPrint('ID: ${equipamento.id}');
      debugPrint('Equipamento: ${equipamento.nome}');
      debugPrint('Unidade: ${equipamento.unidade.nome}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Equipamento cadastrado com sucesso!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Equipamento'),
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
                  labelText: 'ID do equipamento',
                  border: OutlineInputBorder(),
                ),
                validator: validarNumeroInteiro,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do equipamento',
                  border: OutlineInputBorder(),
                ),
                validator: validarTexto,
              ),
              const SizedBox(height: 24),
              const Text(
                'Unidade do equipamento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                controller: unidadeNomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da unidade',
                  border: OutlineInputBorder(),
                ),
                validator: validarTexto,
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