class UnidadeMedida {
  final int? id;
  final String nome;
  final String simbolo;

  UnidadeMedida({
    this.id,
    required this.nome,
    required this.simbolo,
  });

  factory UnidadeMedida.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['Id'] ?? json['ID'];
    return UnidadeMedida(
      id: idValue == null ? null : int.tryParse(idValue.toString()),
      nome: (json['nome'] ?? json['Nome'] ?? '').toString(),
      simbolo: (json['simbolo'] ?? json['Simbolo'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'Nome': nome,
        'Simbolo': simbolo,
      };
}