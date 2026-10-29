import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/usuario.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() =>
      _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState
    extends State<CadastroUsuarioPage> {
  final formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  XFile? fotoSelecionada;

  // =========================================================
  // MENSAGEM
  // =========================================================

  void mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  // =========================================================
  // SELECIONAR FOTO DA GALERIA
  // =========================================================

  Future<void> selecionarFoto() async {
    try {
      final XFile? imagem = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagem == null) return;

      setState(() {
        fotoSelecionada = imagem;
      });
    } on PlatformException catch (e) {
      mostrarMensagem(
        'Não foi possível abrir as fotos: '
        '${e.message ?? e.code}',
      );
    }
  }

  // =========================================================
  // TIRAR FOTO PELA CÂMERA
  // =========================================================

  Future<void> tirarFoto() async {
    try {
      final XFile? imagem = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (imagem == null) return;

      setState(() {
        fotoSelecionada = imagem;
      });
    } on PlatformException catch (e) {
      mostrarMensagem(
        'Não foi possível acessar a câmera: '
        '${e.message ?? e.code}',
      );
    } catch (_) {
      mostrarMensagem(
        'Câmera indisponível. '
        'Selecione uma foto da galeria.',
      );
    }
  }

  // =========================================================
  // SALVAR
  // =========================================================

  void salvar() {
    if (formKey.currentState!.validate()) {
      final usuario = Usuario(
        nome: nomeController.text.trim(),
        email: emailController.text.trim(),
        senha: senhaController.text.trim(),
        fotoPath: fotoSelecionada?.path,
      );

      debugPrint('Nome: ${usuario.nome}');
      debugPrint('E-mail: ${usuario.email}');
      debugPrint('Senha: ${usuario.senha}');
      debugPrint(
        'Foto: ${usuario.fotoPath ?? "sem foto"}',
      );

      mostrarMensagem(
        'Usuário validado com sucesso!',
      );
    }
  }

  // =========================================================
  // DESCARTAR CONTROLLERS
  // =========================================================

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();

    super.dispose();
  }

  // =========================================================
  // TELA
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro de Usuário',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: formKey,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              // =================================================
              // FOTO
              // =================================================

              Center(
                child: CircleAvatar(
                  radius: 70,

                  backgroundColor:
                      Colors.blue.shade50,

                  backgroundImage:
                      fotoSelecionada == null
                          ? null
                          : FileImage(
                              File(
                                fotoSelecionada!.path,
                              ),
                            ),

                  child: fotoSelecionada == null
                      ? const Icon(
                          Icons.person,
                          size: 70,
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              // =================================================
              // BOTÕES DE FOTO
              // =================================================

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: selecionarFoto,

                      icon: const Icon(
                        Icons.photo_library_outlined,
                      ),

                      label: const Text(
                        'Selecionar foto',
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: tirarFoto,

                      icon: const Icon(
                        Icons.camera_alt_outlined,
                      ),

                      label: const Text(
                        'Tirar foto',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // =================================================
              // NOME
              // =================================================

              TextFormField(
                controller: nomeController,

                decoration:
                    const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),

                validator: (valor) {
                  if (valor == null ||
                      valor.trim().isEmpty) {
                    return 'Informe o nome';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =================================================
              // E-MAIL
              // =================================================

              TextFormField(
                controller: emailController,

                keyboardType:
                    TextInputType.emailAddress,

                decoration:
                    const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),

                validator: (valor) {
                  if (valor == null ||
                      valor.trim().isEmpty) {
                    return 'Informe o e-mail';
                  }

                  if (!valor.contains('@') ||
                      !valor.contains('.')) {
                    return 'Informe um e-mail válido';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =================================================
              // SENHA
              // =================================================

              TextFormField(
                controller: senhaController,

                obscureText: true,

                decoration:
                    const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),

                validator: (valor) {
                  if (valor == null ||
                      valor.trim().length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // =================================================
              // SALVAR
              // =================================================

              ElevatedButton(
                onPressed: salvar,

                child: const Text(
                  'Salvar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}