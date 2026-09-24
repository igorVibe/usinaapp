import 'package:flutter/material.dart';
import '../../models/indicador.dart';

class CadastroIndicadorPage extends StatefulWidget {
  const CadastroIndicadorPage({super.key});

  @override
  State<CadastroIndicadorPage> createState() =>
      _CadastroIndicadorPageState();
}

class _CadastroIndicadorPageState
    extends State<CadastroIndicadorPage> {

  final formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final urlController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    urlController.dispose();
    super.dispose();
  }

  void salvar() {
    if (formKey.currentState!.validate()) {
      final indicador = Indicador(
        nome: nomeController.text.trim(),
        descricao: descricaoController.text.trim(),
        url: urlController.text.trim(),
      );

      print('Nome: ${indicador.nome}');
      print('Descrição: ${indicador.descricao}');
      print('URL: ${indicador.url}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Indicador cadastrado com sucesso!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Indicador'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                controller: descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe a descrição';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: urlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://exemplo.com',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe a URL';
                  }

                  final uri = Uri.tryParse(valor.trim());

                  if (uri == null ||
                      !uri.hasScheme ||
                      !uri.hasAuthority) {
                    return 'Informe uma URL válida';
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