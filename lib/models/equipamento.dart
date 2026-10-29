import 'unidade.dart';

class Equipamento {
  final int? id;
  final String nome;
  final Unidade unidade;

  Equipamento({
    this.id,
    required this.nome,
    required this.unidade,
  });

  factory Equipamento.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['Id'] ?? json['ID'];
    final unidadeJson = json['unidade'] ?? json['Unidade'];
    return Equipamento(
      id: idValue == null ? null : int.tryParse(idValue.toString()),
      nome: (json['nome'] ?? json['Nome'] ?? '').toString(),
      unidade: unidadeJson is Map
          ? Unidade.fromJson(Map<String, dynamic>.from(unidadeJson))
          : Unidade(
              id: _asInt(json['unidadeId'] ?? json['UnidadeId']),
              nome: (json['nomeUnidade'] ?? json['NomeUnidade'] ?? '').toString(),
            ),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() => {
        'Nome': nome,
        'UnidadeId': unidade.id,
      };
}