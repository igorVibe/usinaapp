import 'package:flutter/material.dart';
import '../../models/unidade.dart';

class CadastroUnidadePage extends StatefulWidget {
  const CadastroUnidadePage({super.key});

  @override
  State<CadastroUnidadePage> createState() =>
      _CadastroUnidadePageState();
}

class _CadastroUnidadePageState extends State<CadastroUnidadePage> {
  final formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  final nomeController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    nomeController.dispose();
    super.dispose();
  }

  void salvar() {
    if (formKey.currentState!.validate()) {
      final unidade = Unidade(
        id: int.parse(idController.text.trim()),
        nome: nomeController.text.trim(),
      );

      debugPrint('ID: ${unidade.id}');
      debugPrint('Nome: ${unidade.nome}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unidade cadastrada com sucesso!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Unidade'),
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
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o nome';
                  }

                  return null;
                },
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