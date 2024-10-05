import '../entities/pokemon.dart';

abstract class PokemonRepository {
  Future<Map<String, dynamic>> fetchPokemons(
      {required int page, String? name, String? type});
  Future<void> capturePokemon(int pokemonId);
  Future<List<Pokemon>> fetchCapturedPokemons();
  Future<void> releasePokemon(int pokemonId);
}
