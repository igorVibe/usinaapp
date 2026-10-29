class Unidade {
  final int? id;
  final String nome;

  Unidade({
    this.id,
    required this.nome,
  });

  factory Unidade.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['Id'] ?? json['ID'];
    return Unidade(
      id: idValue == null ? null : int.tryParse(idValue.toString()),
      nome: (json['nome'] ?? json['Nome'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'Nome': nome,
      };
}
