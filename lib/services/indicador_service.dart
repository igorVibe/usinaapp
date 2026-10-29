import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/indicador.dart';
import 'api_service.dart';

class IndicadorService {
  static String get baseUrl =>
      '${ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/indicadores';

  Future<List<Indicador>> listar() async {
    final resposta = await http.get(
      Uri.parse(baseUrl),
      headers: {'Accept': 'application/json'},
    );

    if (resposta.statusCode != 200) {
      throw Exception(
        'Erro ao listar indicadores: ${resposta.statusCode}',
      );
    }

    final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
    if (dados is! List) {
      throw const FormatException(
        'A API deveria retornar uma lista JSON.',
      );
    }

    return dados.map((item) {
      return Indicador.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  Future<void> criar(Indicador item) async {
    final resposta = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(item.toJson()),
    );
    if (resposta.statusCode != 200 &&
        resposta.statusCode != 201 &&
        resposta.statusCode != 204) {
      throw Exception(
        'Erro ao cadastrar indicador: ${resposta.statusCode} - ${resposta.body}',
      );
    }
  }

  Future<void> atualizar(Indicador item) async {
    if (item.id == null) {
      throw Exception('O indicador não possui um ID válido.');
    }
    final resposta = await http.put(
      Uri.parse('$baseUrl/${item.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(item.toJson()),
    );
    if (resposta.statusCode != 200 && resposta.statusCode != 204) {
      throw Exception(
        'Erro ao atualizar indicador: ${resposta.statusCode} - ${resposta.body}',
      );
    }
  }

  Future<void> excluir(int id) async {
    final resposta = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Accept': 'application/json'},
    );
    if (resposta.statusCode != 200 &&
        resposta.statusCode != 202 &&
        resposta.statusCode != 204) {
      throw Exception(
        'Erro ao excluir indicador: ${resposta.statusCode} - ${resposta.body}',
      );
    }
  }
}