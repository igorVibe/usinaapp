
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

import '../models/indicador.dart';
import '../services/indicador_service.dart';
import 'indicadores_page.dart';
import 'indicador_webview.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  // Lista dinâmica de indicadores vindos da API.
  Future<List<Indicador>> indicadores =
      IndicadorService().listar();

  bool cadastroAberto = false;

  // Atualiza os indicadores consultando novamente a API.
  void atualizarIndicadores() {
    setState(() {
      indicadores = IndicadorService().listar();
    });
  }

  // Fecha o Drawer e abre a tela selecionada.
  void abrirTela(Widget tela) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => tela,
      ),
    );
  }

  // Encerra a sessão e retorna à tela de login.
  Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('loginRealizado', false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  // Abre a tela de gerenciamento do CRUD.
  Future<void> abrirGerenciamentoIndicadores() async {
    Navigator.pop(context);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IndicadoresPage(),
      ),
    );

    if (!mounted) return;

    atualizarIndicadores();
  }

  // Constrói o menu lateral.
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
              abrirTela(const CadastroUsuarioPage());
            },
          ),

          // UNIDADE
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Unidades'),
            onTap: () {
              abrirTela(const CadastroUnidadePage());
            },
          ),

          // UNIDADE DE MEDIDA
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Unidades de Medida'),
            onTap: () {
              abrirTela(const CadastroUnidadeMedidaPage());
            },
          ),

          // EQUIPAMENTO
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Equipamentos'),
            onTap: () {
              abrirTela(const CadastroEquipamentoPage());
            },
          ),

          // INDICADOR - CADASTRO EXISTENTE
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Indicador'),
            onTap: () {
              abrirTela(const CadastroIndicadorPage());
            },
          ),

          // SAFRA
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Safras'),
            onTap: () {
              abrirTela(const CadastroSafraPage());
            },
          ),

          // TIPO DE INFORMAÇÃO
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Tipos de Informação'),
            onTap: () {
              abrirTela(const CadastroTipoInformacaoPage());
            },
          ),

          // MEDIÇÃO
          ListTile(
            leading: const Icon(Icons.chevron_right),
            title: const Text('Medições'),
            onTap: () {
              abrirTela(const CadastroMedicaoPage());
            },
          ),
        ],

        const Divider(),

        // GERENCIAR INDICADORES - CRUD
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Gerenciar indicadores'),
          onTap: abrirGerenciamentoIndicadores,
        ),

        // SUBMENU DINÂMICO DE INDICADORES
        ExpansionTile(
          leading: const Icon(Icons.analytics),
          title: const Text('Indicadores'),
          children: [
            FutureBuilder<List<Indicador>>(
              future: indicadores,
              builder: (context, snapshot) {
                // Carregamento ou erro.
                if (!snapshot.hasData) {
                  return ListTile(
                    leading: Icon(
                      snapshot.hasError
                          ? Icons.error_outline
                          : Icons.hourglass_empty,
                    ),
                    title: Text(
                      snapshot.hasError
                          ? 'Falha ao carregar indicadores'
                          : 'Carregando...',
                    ),
                    trailing: snapshot.hasError
                        ? IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Tentar novamente',
                            onPressed: atualizarIndicadores,
                          )
                        : null,
                  );
                }

                final lista = snapshot.data!;

                // Nenhum indicador cadastrado.
                if (lista.isEmpty) {
                  return const ListTile(
                    title: Text('Nenhum indicador cadastrado'),
                  );
                }

                // Lista os indicadores retornados pela API.
                return Column(
                  children: lista.map((item) {
                    return ListTile(
                      leading: const Icon(
                        Icons.insert_chart_outlined,
                      ),
                      title: Text(item.nome),
                      subtitle: Text(item.descricao),
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                IndicadorWebviewPage(
                              indicador: item,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),

        const Divider(),

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

      // Atualiza os indicadores sempre que o Drawer é aberto.
      onDrawerChanged: (aberto) {
        if (aberto) {
          atualizarIndicadores();
        }
      },

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
