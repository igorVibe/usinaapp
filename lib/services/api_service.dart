import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/equipamento.dart';
import '../models/medicao.dart';
import '../models/safra.dart';
import '../models/tipo_informacao.dart';
import '../models/unidade.dart';
import '../models/unidade_medida.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiConfig {
  static const String defaultBaseUrl = 'http://10.0.2.2:1880';
  static String baseUrl = defaultBaseUrl;

  static String url(String path) {
    final normalizedBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');
    return '$normalizedBase/$normalizedPath';
  }
}

class ApiClient {
  static Future<List<dynamic>> list(String path) async {
    final response = await http.get(
      Uri.parse(ApiConfig.url(path)),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode >= 400) {
      throw ApiException(
        'Erro ao consultar $path (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.body.trim().isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      for (final key in ['data', 'items', 'result', 'records', 'value']) {
        final value = map[key];
        if (value is List) {
          return value;
        }
      }

      for (final key in ['safras', 'unidades', 'unidadesmedida', 'equipamentos', 'tipoinformacoes', 'medicoes']) {
        final value = map[key];
        if (value is List) {
          return value;
        }
      }

      return [map];
    }

    throw const ApiException('A API retornou um formato inesperado.');
  }

  static Future<void> post(String path, Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse(ApiConfig.url(path)),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Erro ao cadastrar em $path (${response.statusCode}).\n${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  static Future<void> put(String path, Map<String, dynamic> payload) async {
    final response = await http.put(
      Uri.parse(ApiConfig.url(path)),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Erro ao atualizar em $path (${response.statusCode}).\n${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  static Future<void> delete(String path) async {
    final response = await http.delete(
      Uri.parse(ApiConfig.url(path)),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Erro ao excluir em $path (${response.statusCode}).\n${response.body}',
        statusCode: response.statusCode,
      );
    }
  }
}

class UnidadeService {
  static const String path = 'api/unidades';

  Future<List<Unidade>> listar() async {
    final response = await ApiClient.list(path);
    return response
        .map((item) => Unidade.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> criar(Unidade unidade) async {
    await ApiClient.post(path, unidade.toJson());
  }

  Future<void> atualizar(Unidade unidade) async {
    if (unidade.id == null) {
      throw const ApiException('Unidade sem ID para atualização.');
    }
    await ApiClient.put('$path/${unidade.id}', unidade.toJson());
  }

  Future<void> excluir(int id) async {
    await ApiClient.delete('$path/$id');
  }
}

class UnidadeMedidaService {
  static const String path = 'api/unidadesmedida';

  Future<List<UnidadeMedida>> listar() async {
    final response = await ApiClient.list(path);
    return response
        .map((item) => UnidadeMedida.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> criar(UnidadeMedida unidadeMedida) async {
    await ApiClient.post(path, unidadeMedida.toJson());
  }

  Future<void> atualizar(UnidadeMedida unidadeMedida) async {
    if (unidadeMedida.id == null) {
      throw const ApiException('Unidade de medida sem ID para atualização.');
    }
    await ApiClient.put('$path/${unidadeMedida.id}', unidadeMedida.toJson());
  }

  Future<void> excluir(int id) async {
    await ApiClient.delete('$path/$id');
  }
}

class SafraService {
  static const String path = 'api/safras';

  Future<List<Safra>> listar() async {
    final response = await ApiClient.list(path);
    return response
        .map((item) => Safra.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> criar(Safra safra) async {
    await ApiClient.post(path, safra.toJson());
  }

  Future<void> atualizar(Safra safra) async {
    if (safra.id == null) {
      throw const ApiException('Safra sem ID para atualização.');
    }
    await ApiClient.put('$path/${safra.id}', safra.toJson());
  }

  Future<void> excluir(int id) async {
    await ApiClient.delete('$path/$id');
  }
}

class EquipamentoService {
  static const String path = 'api/equipamentos';

  Future<List<Equipamento>> listar() async {
    final response = await ApiClient.list(path);
    return response
        .map((item) => Equipamento.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> criar(Equipamento equipamento) async {
    await ApiClient.post(path, equipamento.toJson());
  }

  Future<void> atualizar(Equipamento equipamento) async {
    if (equipamento.id == null) {
      throw const ApiException('Equipamento sem ID para atualização.');
    }
    await ApiClient.put('$path/${equipamento.id}', equipamento.toJson());
  }

  Future<void> excluir(int id) async {
    await ApiClient.delete('$path/$id');
  }
}

class TipoInformacaoService {
  static const String path = 'api/tipoinformacoes';

  Future<List<TipoInformacao>> listar() async {
    final response = await ApiClient.list(path);
    return response
        .map((item) => TipoInformacao.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> criar(TipoInformacao tipoInformacao) async {
    await ApiClient.post(path, tipoInformacao.toJson());
  }

  Future<void> atualizar(TipoInformacao tipoInformacao) async {
    if (tipoInformacao.id == null) {
      throw const ApiException('Tipo de informação sem ID para atualização.');
    }
    await ApiClient.put('$path/${tipoInformacao.id}', tipoInformacao.toJson());
  }

  Future<void> excluir(int id) async {
    await ApiClient.delete('$path/$id');
  }
}

class MedicaoService {
  static const String path = 'api/medicoes';

  Future<List<Medicao>> listar() async {
    final response = await ApiClient.list(path);
    return response
        .map((item) => Medicao.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> criar(Medicao medicao) async {
    await ApiClient.post(path, medicao.toJson());
  }

  Future<void> atualizar(Medicao medicao) async {
    if (medicao.id == null) {
      throw const ApiException('Medição sem ID para atualização.');
    }
    await ApiClient.put('$path/${medicao.id}', medicao.toJson());
  }

  Future<void> excluir(int id) async {
    await ApiClient.delete('$path/$id');
  }
}
