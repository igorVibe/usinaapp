class Safra {
  final int? id;
  final String nomeSafra;
  final DateTime dataInicio;
  final DateTime dataFim;

  Safra({
    this.id,
    required this.nomeSafra,
    required this.dataInicio,
    required this.dataFim,
  });

  factory Safra.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['Id'] ?? json['ID'];
    return Safra(
      id: idValue == null ? null : int.tryParse(idValue.toString()),
      nomeSafra: (json['nomeSafra'] ?? json['NomeSafra'] ?? json['nome'] ?? json['Nome'] ?? '').toString(),
      dataInicio: _parseDate(json['dataInicio'] ?? json['DataInicio'] ?? json['inicio'] ?? json['Inicio'] ?? DateTime.now()),
      dataFim: _parseDate(json['dataFim'] ?? json['DataFim'] ?? json['fim'] ?? json['Fim'] ?? DateTime.now()),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty) return DateTime.now();
      return DateTime.tryParse(normalized) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'NomeSafra': nomeSafra,
        'DataInicio': _toIsoDate(dataInicio),
        'DataFim': _toIsoDate(dataFim),
      };

  String _toIsoDate(DateTime value) => value.toIso8601String().split('T').first;
}