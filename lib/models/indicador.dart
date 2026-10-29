class Indicador {
  final int? id;
  final String nome;
  final String descricao;
  final String url;

  const Indicador({
    this.id,
    required this.nome,
    required this.descricao,
    required this.url,
  });

  factory Indicador.fromJson(Map<String, dynamic> json) =>
      Indicador(
        id: (json['Id'] ?? json['id']) as int?,
        nome: (json['Nome'] ?? json['nome'] ?? '') as String,
        descricao:
            (json['Descricao'] ?? json['descricao'] ?? '') as String,
        url: (json['Url'] ?? json['url'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'Nome': nome,
        'Descricao': descricao,
        'Url': url,
      };
}
