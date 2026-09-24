import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tela_principal.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;

  void mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  Future<Position?> obterLocalizacao() async {
    final servicoAtivo =
        await Geolocator.isLocationServiceEnabled();

    if (!servicoAtivo) {
      mostrarMensagem(
        'Ative a localização do dispositivo.',
      );
      return null;
    }

    LocationPermission permissao =
        await Geolocator.checkPermission();

    if (permissao ==
        LocationPermission.denied) {
      permissao =
          await Geolocator.requestPermission();
    }

    if (permissao ==
        LocationPermission.denied) {
      mostrarMensagem(
        'Permissão de localização negada.',
      );
      return null;
    }

    if (permissao ==
        LocationPermission.deniedForever) {
      mostrarMensagem(
        'A localização foi negada permanentemente. '
        'Altere a permissão nas configurações.',
      );
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> entrar() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      carregando = true;
    });

    final email =
        emailController.text.trim();
    final senha =
        senhaController.text.trim();

    // Validação apenas para a aula.
    const emailTeste = 'aluno@usina.com';
    const senhaTeste = '123456';

    if (email != emailTeste ||
        senha != senhaTeste) {
      mostrarMensagem(
        'E-mail ou senha inválidos.',
      );

      setState(() {
        carregando = false;
      });
      return;
    }

    final posicao = await obterLocalizacao();

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'loginRealizado',
      true,
    );

    await prefs.setString(
      'emailUsuario',
      email,
    );

    await prefs.setString(
      'dataLogin',
      DateTime.now().toIso8601String(),
    );

    if (posicao != null) {
      await prefs.setDouble(
        'latitude',
        posicao.latitude,
      );

      await prefs.setDouble(
        'longitude',
        posicao.longitude,
      );
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const TelaPrincipal(),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 100,
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(
                    labelText: 'E-mail',
                    border:
                        OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null ||
                        valor.trim().isEmpty) {
                      return 'Informe o e-mail';
                    }

                    if (!valor.contains('@')) {
                      return 'E-mail inválido';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: senhaController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(
                    labelText: 'Senha',
                    border:
                        OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null ||
                        valor.length < 6) {
                      return 'Informe uma senha com 6 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        carregando ? null : entrar,
                    child: carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Entrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}