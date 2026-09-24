import 'safra.dart';
import 'unidade.dart';
import 'tipo_informacao.dart';

class Medicao {
  final int id;
  final Safra safra;
  final Unidade unidade;
  final TipoInformacao tipoInformacao;
  final double valor;
  final DateTime data;

  Medicao({
    required this.id,
    required this.safra,
    required this.unidade,
    required this.tipoInformacao,
    required this.valor,
    required this.data,
  });
}