import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'cadastros/cadastro_equipamento.dart';
import 'cadastros/cadastro_indicador.dart';
import 'cadastros/cadastro_medicao.dart';
import 'cadastros/cadastro_safra.dart';
import 'cadastros/cadastro_tipo_informacao.dart';
import 'cadastros/cadastro_unidade.dart';
import 'cadastros/cadastro_unidade_medida.dart';
import 'cadastros/cadastro_usuario.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  bool cadastroAberto = false;

  void abrirTela(Widget tela) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => tela,
      ),
    );
  }

  Future<void> sair() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'loginRealizado',
      false,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginPage(),
      ),
    );
  }

  Widget montarMenu() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          child: Text(
            'Menu Principal',
            style: TextStyle(fontSize: 22),
          ),
        ),

        // INÍCIO
        const ListTile(
          leading: Icon(Icons.home),
          title: Text('Início'),
        ),

        // CADASTRO
        ListTile(
          leading: const Icon(Icons.app_registration),
          title: const Text('Cadastro'),
          trailing: Icon(
            cadastroAberto
                ? Icons.expand_less
                : Icons.expand_more,
          ),
          onTap: () {
            setState(() {
              cadastroAberto = !cadastroAberto;
            });
          },
        ),

        // ITENS DO CADASTRO
        if (cadastroAberto) ...[
          // USUÁRIO
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Usuário'),
            onTap: () {
              abrirTela(
                const CadastroUsuarioPage(),
              );
            },
          ),

          // UNIDADE
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Unidade'),
            onTap: () {
              abrirTela(
                const CadastroUnidadePage(),
              );
            },
          ),

          // UNIDADE DE MEDIDA
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Unidade de Medida'),
            onTap: () {
              abrirTela(
                const CadastroUnidadeMedidaPage(),
              );
            },
          ),

          // EQUIPAMENTO
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Equipamento'),
            onTap: () {
              abrirTela(
                const CadastroEquipamentoPage(),
              );
            },
          ),

          // INDICADOR
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Indicador'),
            onTap: () {
              abrirTela(
                const CadastroIndicadorPage(),
              );
            },
          ),

          // SAFRA
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Safra'),
            onTap: () {
              abrirTela(
                const CadastroSafraPage(),
              );
            },
          ),

          // TIPO DE INFORMAÇÃO
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Tipo de Informação'),
            onTap: () {
              abrirTela(
                const CadastroTipoInformacaoPage(),
              );
            },
          ),

          // MEDIÇÃO
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Medição'),
            onTap: () {
              abrirTela(
                const CadastroMedicaoPage(),
              );
            },
          ),
        ],

        // SAIR
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sair'),
          onTap: sair,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usina App'),
      ),
      drawer: Drawer(
        child: montarMenu(),
      ),
      body: const Center(
        child: Text(
          'Tela Principal',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}