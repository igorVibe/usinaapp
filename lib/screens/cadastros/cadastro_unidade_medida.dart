import 'package:flutter/material.dart';
import '../../models/unidade_medida.dart';

class CadastroUnidadeMedidaPage extends StatefulWidget {
  const CadastroUnidadeMedidaPage({super.key});

  @override
  State<CadastroUnidadeMedidaPage> createState() =>
      _CadastroUnidadeMedidaPageState();
}

class _CadastroUnidadeMedidaPageState
    extends State<CadastroUnidadeMedidaPage> {
  final formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  final nomeController = TextEditingController();
  final simboloController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    nomeController.dispose();
    simboloController.dispose();
    super.dispose();
  }

  void salvar() {
    if (formKey.currentState!.validate()) {
      final unidadeMedida = UnidadeMedida(
        id: int.parse(idController.text.trim()),
        nome: nomeController.text.trim(),
        simbolo: simboloController.text.trim(),
      );

      debugPrint('ID: ${unidadeMedida.id}');
      debugPrint('Nome: ${unidadeMedida.nome}');
      debugPrint('Símbolo: ${unidadeMedida.simbolo}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unidade de medida cadastrada com sucesso!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Unidade de Medida'),
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
                validator: validarId,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: simboloController,
                decoration: const InputDecoration(
                  labelText: 'Símbolo',
                  hintText: 'Exemplo: kg, °C, m',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o símbolo';
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

  String? validarId(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe o ID';
    }

    if (int.tryParse(valor.trim()) == null) {
      return 'Informe um número inteiro';
    }

    return null;
  }
}