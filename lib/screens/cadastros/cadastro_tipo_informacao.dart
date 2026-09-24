import 'package:flutter/material.dart';

import '../../models/tipo_informacao.dart';
import '../../models/unidade_medida.dart';

class CadastroTipoInformacaoPage extends StatefulWidget {
  const CadastroTipoInformacaoPage({super.key});

  @override
  State<CadastroTipoInformacaoPage> createState() =>
      _CadastroTipoInformacaoPageState();
}

class _CadastroTipoInformacaoPageState
    extends State<CadastroTipoInformacaoPage> {
  final formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  final nomeController = TextEditingController();

  final unidadeMedidaIdController = TextEditingController();
  final unidadeMedidaNomeController = TextEditingController();
  final simboloController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    nomeController.dispose();
    unidadeMedidaIdController.dispose();
    unidadeMedidaNomeController.dispose();
    simboloController.dispose();
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
      final unidadeMedida = UnidadeMedida(
        id: int.parse(unidadeMedidaIdController.text.trim()),
        nome: unidadeMedidaNomeController.text.trim(),
        simbolo: simboloController.text.trim(),
      );

      final tipoInformacao = TipoInformacao(
        id: int.parse(idController.text.trim()),
        nome: nomeController.text.trim(),
        unidadeMedida: unidadeMedida,
      );

      debugPrint('ID: ${tipoInformacao.id}');
      debugPrint('Tipo: ${tipoInformacao.nome}');
      debugPrint(
        'Unidade de medida: '
        '${tipoInformacao.unidadeMedida.nome}',
      );
      debugPrint(
        'Símbolo: ${tipoInformacao.unidadeMedida.simbolo}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tipo de informação cadastrado com sucesso!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Tipo de Informação'),
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
                validator: validarNumeroInteiro,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Exemplo: Temperatura',
                  border: OutlineInputBorder(),
                ),
                validator: validarTexto,
              ),
              const SizedBox(height: 24),
              const Text(
                'Unidade de medida',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: unidadeMedidaIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID da unidade de medida',
                  border: OutlineInputBorder(),
                ),
                validator: validarNumeroInteiro,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: unidadeMedidaNomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da unidade de medida',
                  hintText: 'Exemplo: Graus Celsius',
                  border: OutlineInputBorder(),
                ),
                validator: validarTexto,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: simboloController,
                decoration: const InputDecoration(
                  labelText: 'Símbolo',
                  hintText: 'Exemplo: °C',
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