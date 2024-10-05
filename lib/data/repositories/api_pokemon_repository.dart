import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';

class ApiPokemonRepository implements PokemonRepository {
  final http.Client client;

  ApiPokemonRepository({required this.client});

  @override
  Future<Map<String, dynamic>> fetchPokemons(
      {required int page, String? name, String? type}) async {
    final queryParams = {
      'page': page.toString(),
      'per_page': kItemsPerPage.toString(),
      if (name != null && name.isNotEmpty) 'name': name,
      if (type != null && type.isNotEmpty) 'type': type,
    };

    final uri =
        Uri.parse('$kBaseUrl/pokemons').replace(queryParameters: queryParams);

    try {
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'pokemons': (responseData['pokemons'] as List)
              .map((json) => Pokemon.fromJson(json))
              .toList(),
          'page': responseData['page'] as int?,
          'total_pages': responseData['total_pages'] as int?,
          'total_count': responseData['total_count'] as int?,
        };
      } else {
        throw Exception('Failed to load pokemons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching pokemons: $e');
    }
  }

  @override
  Future<void> capturePokemon(int pokemonId) async {
    final uri = Uri.parse('$kBaseUrl/pokemons/$pokemonId/capture');
    try {
      final response = await client.post(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to capture pokemon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error capturing pokemon: $e');
    }
  }

  @override
  Future<List<Pokemon>> fetchCapturedPokemons() async {
    final uri = Uri.parse('$kBaseUrl/pokemons/captured');
    try {
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> pokemonList = json.decode(response.body);
        return pokemonList.map((json) => Pokemon.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load captured pokemons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching captured pokemons: $e');
    }
  }

  @override
  Future<void> releasePokemon(int pokemonId) async {
    final uri = Uri.parse('$kBaseUrl/pokemons/$pokemonId/release');
    try {
      final response = await client.delete(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to release pokemon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error releasing pokemon: $e');
    }
  }
}
