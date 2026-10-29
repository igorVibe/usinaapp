import 'unidade_medida.dart';

class TipoInformacao {
  final int? id;
  final String nome;
  final UnidadeMedida unidadeMedida;

  TipoInformacao({
    this.id,
    required this.nome,
    required this.unidadeMedida,
  });

  factory TipoInformacao.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['Id'] ?? json['ID'];
    final unidadeMedidaJson = json['unidadeMedida'] ?? json['UnidadeMedida'];
    return TipoInformacao(
      id: idValue == null ? null : int.tryParse(idValue.toString()),
      nome: (json['nome'] ?? json['Nome'] ?? '').toString(),
      unidadeMedida: unidadeMedidaJson is Map
          ? UnidadeMedida.fromJson(Map<String, dynamic>.from(unidadeMedidaJson))
          : UnidadeMedida(
              id: _asInt(json['unidadeMedidaId'] ?? json['UnidadeMedidaId']),
              nome: (json['nomeUnidadeMedida'] ?? json['NomeUnidadeMedida'] ?? '').toString(),
              simbolo: (json['simboloUnidadeMedida'] ?? json['SimboloUnidadeMedida'] ?? '').toString(),
            ),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() => {
        'Nome': nome,
        'UnidadeMedidaId': unidadeMedida.id,
      };
}