class Medicao {
  final int? id;
  final int safraId;
  final int equipamentoId;
  final int tipoInformacaoId;
  final double valor;
  final DateTime data;

  Medicao({
    this.id,
    required this.safraId,
    required this.equipamentoId,
    required this.tipoInformacaoId,
    required this.valor,
    required this.data,
  });

  factory Medicao.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['Id'] ?? json['ID'];
    final safraIdValue = json['safraId'] ?? json['SafraId'] ?? json['safra_id'] ?? json['Safra_Id'];
    final equipamentoIdValue = json['equipamentoId'] ?? json['EquipamentoId'] ?? json['equipamento_id'] ?? json['Equipamento_Id'];
    final tipoInformacaoIdValue = json['tipoInformacaoId'] ?? json['TipoInformacaoId'] ?? json['tipo_informacao_id'] ?? json['TipoInformacao_Id'];

    return Medicao(
      id: idValue == null ? null : int.tryParse(idValue.toString()),
      safraId: _toInt(safraIdValue),
      equipamentoId: _toInt(equipamentoIdValue),
      tipoInformacaoId: _toInt(tipoInformacaoIdValue),
      valor: double.tryParse((json['valor'] ?? json['Valor'] ?? '0').toString()) ?? 0,
      data: _parseDate(json['data'] ?? json['Data'] ?? DateTime.now()),
    );
  }

  static int _toInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

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
        'SafraId': safraId,
        'EquipamentoId': equipamentoId,
        'TipoInformacaoId': tipoInformacaoId,
        'Valor': valor,
        'Data': data.toUtc().toIso8601String(),
      };
}