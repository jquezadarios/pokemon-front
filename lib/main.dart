import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String kBaseUrl = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000/api/v1');
const int kItemsPerPage = 10;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardTheme(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
      ),
      home: const PokemonListPage(),
    );
  }
}

class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final String image;
  final bool captured;
  final String? capturedAt;

  const Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.image,
    required this.captured,
    this.capturedAt,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      types: List<String>.from(json['types']),
      image: json['image'],
      captured: json['captured'],
      capturedAt: json['captured_at'],
    );
  }
}

abstract class PokemonRepository {
  Future<List<Pokemon>> fetchPokemons(
      {required int page, String? name, String? type});
  Future<void> capturePokemon(int pokemonId);
  Future<List<Pokemon>> fetchCapturedPokemons();
  Future<void> releasePokemon(int pokemonId);
}

class ApiPokemonRepository implements PokemonRepository {
  final http.Client client;

  ApiPokemonRepository({required this.client});

  @override
  Future<List<Pokemon>> fetchPokemons(
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
        final List<dynamic> pokemonList = responseData['pokemons'];
        return pokemonList.map((json) => Pokemon.fromJson(json)).toList();
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

class PokemonState {
  final List<Pokemon> allPokemons;
  final List<Pokemon> capturedPokemons;
  final bool isLoading;
  final String error;

  const PokemonState({
    this.allPokemons = const [],
    this.capturedPokemons = const [],
    this.isLoading = false,
    this.error = '',
  });

  PokemonState copyWith({
    List<Pokemon>? allPokemons,
    List<Pokemon>? capturedPokemons,
    bool? isLoading,
    String? error,
  }) {
    return PokemonState(
      allPokemons: allPokemons ?? this.allPokemons,
      capturedPokemons: capturedPokemons ?? this.capturedPokemons,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PokemonController extends ChangeNotifier {
  final PokemonRepository repository;
  PokemonState _state = const PokemonState();
  int _currentPage = 1;

  PokemonController({required this.repository});

  PokemonState get state => _state;

  Future<void> fetchPokemons({String? name, String? type}) async {
    _state = _state.copyWith(isLoading: true, error: '');
    notifyListeners();
    try {
      final pokemons = await repository.fetchPokemons(
          page: _currentPage, name: name, type: type);
      if (_currentPage == 1) {
        _state = _state.copyWith(allPokemons: pokemons, isLoading: false);
      } else {
        _state = _state.copyWith(
            allPokemons: [..._state.allPokemons, ...pokemons],
            isLoading: false);
      }
    } catch (e) {
      _state = _state.copyWith(
          error:
              'Failed to load Pokémon. Please check your internet connection and try again.',
          isLoading: false);
    }
    notifyListeners();
  }

  Future<void> toggleCapture(Pokemon pokemon) async {
    try {
      if (_state.capturedPokemons.contains(pokemon)) {
        await repository.releasePokemon(pokemon.id);
        final updatedCaptured = List<Pokemon>.from(_state.capturedPokemons)
          ..remove(pokemon);
        _state = _state.copyWith(capturedPokemons: updatedCaptured);
      } else {
        if (_state.capturedPokemons.length >= 6) {
          // Remover el Pokémon más antiguo
          final updatedCaptured = List<Pokemon>.from(_state.capturedPokemons);
          updatedCaptured.removeAt(0);
          updatedCaptured.add(pokemon);
          await repository.capturePokemon(pokemon.id);
          _state = _state.copyWith(capturedPokemons: updatedCaptured);
        } else {
          await repository.capturePokemon(pokemon.id);
          final updatedCaptured = List<Pokemon>.from(_state.capturedPokemons)
            ..add(pokemon);
          _state = _state.copyWith(capturedPokemons: updatedCaptured);
        }
      }
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  Future<void> fetchCapturedPokemons() async {
    try {
      final capturedPokemons = await repository.fetchCapturedPokemons();
      _state = _state.copyWith(capturedPokemons: capturedPokemons);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: 'Failed to fetch captured Pokémon');
      notifyListeners();
    }
  }

  void loadMore() {
    _currentPage++;
    fetchPokemons();
  }

  void resetSearch() {
    _currentPage = 1;
    _state = _state.copyWith(allPokemons: []);
    notifyListeners();
  }
}

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({Key? key}) : super(key: key);

  @override
  PokemonListPageState createState() => PokemonListPageState();
}

class PokemonListPageState extends State<PokemonListPage> {
  late final PokemonController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = '';

  @override
  void initState() {
    super.initState();
    _controller = PokemonController(
        repository: ApiPokemonRepository(client: http.Client()));
    _controller.fetchPokemons();
    _controller.fetchCapturedPokemons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchCard(),
          Expanded(child: _buildPokemonList()),
          _buildCapturedPokemonCard(),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Pokémon',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              value: _selectedType,
              hint: const Text('Select Type'),
              isExpanded: true,
              items: ['', ...pokemonTypes]
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.isEmpty ? 'All types' : type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _performSearch();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonList() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final state = _controller.state;
        if (state.isLoading && state.allPokemons.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchPokemons(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.allPokemons.length + 1,
          itemBuilder: (context, index) {
            if (index == state.allPokemons.length) {
              return state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: ElevatedButton(
                        onPressed: _controller.loadMore,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        child: const Text('Load More'),
                      ),
                    );
            }

            final pokemon = state.allPokemons[index];
            final isCaptured = state.capturedPokemons.contains(pokemon);
            return _buildPokemonCard(pokemon, isCaptured);
          },
        );
      },
    );
  }

  Widget _buildPokemonCard(Pokemon pokemon, bool isCaptured) {
    return Card(
      child: InkWell(
        onTap: () => _controller.toggleCapture(pokemon),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'pokemon-${pokemon.id}',
              child: Image.network(pokemon.image, width: 100, height: 100),
            ),
            Text(pokemon.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(pokemon.types.join(', '),
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Icon(
              isCaptured
                  ? Icons.catching_pokemon
                  : Icons.catching_pokemon_outlined,
              color: isCaptured ? Colors.red : Colors.grey,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturedPokemonCard() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final capturedPokemons = _controller.state.capturedPokemons;
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Captured Pokémons (${capturedPokemons.length}/6)',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: capturedPokemons.length,
                    itemBuilder: (context, index) {
                      final pokemon = capturedPokemons[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                              child: Image.network(pokemon.image,
                                  width: 40, height: 40),
                            ),
                            const SizedBox(height: 5),
                            Text(pokemon.name,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performSearch() {
    _controller.resetSearch();
    _controller.fetchPokemons(
        name: _searchController.text, type: _selectedType);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

final List<String> pokemonTypes = [
  'Water',
  'Fire',
  'Grass',
  'Electric',
  'Normal',
  'Fighting',
  'Flying',
  'Poison',
  'Ground',
  'Psychic',
  'Bug',
  'Rock',
  'Ghost',
  'Ice',
  'Dragon',
  'Dark',
  'Steel',
  'Fairy'
];
