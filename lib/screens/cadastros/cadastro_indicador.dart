
import 'package:flutter/material.dart';
import '../../models/indicador.dart';
import '../../services/indicador_service.dart';

class CadastroIndicadorPage extends StatefulWidget {
  final Indicador? indicador;

  const CadastroIndicadorPage({
    super.key,
    this.indicador,
  });

  @override
  State<CadastroIndicadorPage> createState() =>
      _CadastroIndicadorPageState();
}

class _CadastroIndicadorPageState
    extends State<CadastroIndicadorPage> {
  final chave = GlobalKey<FormState>();
  final nome = TextEditingController();
  final descricao = TextEditingController();
  final url = TextEditingController();

  bool salvando = false;

  @override
  void initState() {
    super.initState();

    final item = widget.indicador;

    if (item != null) {
      nome.text = item.nome;
      descricao.text = item.descricao;
      url.text = item.url;
    }
  }

  @override
  void dispose() {
    nome.dispose();
    descricao.dispose();
    url.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!chave.currentState!.validate()) return;

    setState(() => salvando = true);

    final item = Indicador(
      id: widget.indicador?.id,
      nome: nome.text.trim(),
      descricao: descricao.text.trim(),
      url: url.text.trim(),
    );

    try {
      final service = IndicadorService();

      if (item.id == null) {
        await service.criar(item);
      } else {
        await service.atualizar(item);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            widget.indicador == null
                ? 'Novo indicador'
                : 'Editar indicador',
          ),
        ),
        body: Form(
          key: chave,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: nome,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Informe o nome'
                        : null,
              ),
              TextFormField(
                controller: descricao,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Informe a descrição'
                        : null,
              ),
              TextFormField(
                controller: url,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://exemplo.com',
                ),
                validator: (v) {
                  final u = Uri.tryParse(v?.trim() ?? '');

                  if (u == null ||
                      !['http', 'https'].contains(u.scheme) ||
                      u.host.isEmpty) {
                    return 'Informe uma URL http(s) válida';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: salvando ? null : salvar,
                child: Text(
                  salvando ? 'Salvando...' : 'Salvar',
                ),
              ),
            ],
          ),
        ),
      );
}
