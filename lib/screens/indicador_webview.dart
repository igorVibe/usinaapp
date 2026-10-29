
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/indicador.dart';

class IndicadorWebviewPage extends StatefulWidget {
  final Indicador indicador;

  const IndicadorWebviewPage({
    super.key,
    required this.indicador,
  });

  @override
  State<IndicadorWebviewPage> createState() =>
      _IndicadorWebviewPageState();
}

class _IndicadorWebviewPageState
    extends State<IndicadorWebviewPage> {
  late final WebViewController controller;

  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              carregando = true;
              erro = null;
            });
          },
          onPageFinished: (_) {
            setState(() => carregando = false);
          },
          onWebResourceError: (e) {
            if (e.isForMainFrame == true) {
              setState(() {
                erro = e.description;
                carregando = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.indicador.url));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.indicador.nome),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (carregando)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (erro != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Não foi possível abrir o indicador: $erro',
                  ),
                ),
              ),
          ],
        ),
      );
}
