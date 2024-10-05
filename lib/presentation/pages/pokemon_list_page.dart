import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../controllers/pokemon_controller.dart';
import '../widgets/search_card.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/captured_pokemon_card.dart';
import '../widgets/pagination_controls.dart';
import '../../data/repositories/api_pokemon_repository.dart';

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

    Future.microtask(() {
      _controller.initializeData();
    });
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
          SearchCard(
            searchController: _searchController,
            selectedType: _selectedType,
            onSearch: _performSearch,
            onTypeChanged: (value) {
              setState(() {
                _selectedType = value ?? '';
                _performSearch();
              });
            },
          ),
          Expanded(child: _buildPokemonList()),
          CapturedPokemonCard(controller: _controller),
        ],
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
                  onPressed: () => _controller.initializeData(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.allPokemons.length,
                itemBuilder: (context, index) {
                  final pokemon = state.allPokemons[index];
                  final isCaptured = state.capturedPokemons.contains(pokemon);
                  return PokemonCard(
                    pokemon: pokemon,
                    isCaptured: isCaptured,
                    onTap: () => _controller.toggleCapture(pokemon),
                  );
                },
              ),
            ),
            PaginationControls(controller: _controller),
          ],
        );
      },
    );
  }

  void _performSearch() {
    _controller.fetchPokemons(
      name: _searchController.text,
      type: _selectedType.isNotEmpty ? _selectedType : null,
      page: 1,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
