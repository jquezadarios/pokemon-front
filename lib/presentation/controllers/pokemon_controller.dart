import 'package:flutter/foundation.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';

class PokemonState {
  final List<Pokemon> allPokemons;
  final List<Pokemon> capturedPokemons;
  final bool isLoading;
  final String error;
  final int? currentPage;
  final int? totalPages;
  final int? totalCount;
  final String? searchName;
  final String? searchType;

  const PokemonState({
    this.allPokemons = const [],
    this.capturedPokemons = const [],
    this.isLoading = false,
    this.error = '',
    this.currentPage,
    this.totalPages,
    this.totalCount,
    this.searchName,
    this.searchType,
  });

  PokemonState copyWith({
    List<Pokemon>? allPokemons,
    List<Pokemon>? capturedPokemons,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    String? searchName,
    String? searchType,
  }) {
    return PokemonState(
      allPokemons: allPokemons ?? this.allPokemons,
      capturedPokemons: capturedPokemons ?? this.capturedPokemons,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      searchName: searchName ?? this.searchName,
      searchType: searchType ?? this.searchType,
    );
  }
}

class PokemonController extends ChangeNotifier {
  final PokemonRepository repository;
  PokemonState _state = const PokemonState();

  PokemonController({required this.repository});

  PokemonState get state => _state;

  Future<void> fetchPokemons({String? name, String? type, int? page}) async {
    _state = _state.copyWith(
      isLoading: true,
      error: '',
      searchName: name ?? _state.searchName,
      searchType: type ?? _state.searchType,
    );
    notifyListeners();
    try {
      final response = await repository.fetchPokemons(
        page: page ?? _state.currentPage ?? 1,
        name: _state.searchName,
        type: _state.searchType,
      );
      _state = _state.copyWith(
        allPokemons: response['pokemons'],
        currentPage: response['page'] ?? _state.currentPage,
        totalPages: response['total_pages'] ?? _state.totalPages,
        totalCount: response['total_count'] ?? _state.totalCount,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        error:
            'Failed to load Pokémon. Please check your internet connection and try again.',
        isLoading: false,
      );
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

  void nextPage() {
    if (_state.currentPage != null &&
        _state.totalPages != null &&
        _state.currentPage! < _state.totalPages!) {
      fetchPokemons(page: _state.currentPage! + 1);
    }
  }

  void previousPage() {
    if (_state.currentPage != null && _state.currentPage! > 1) {
      fetchPokemons(page: _state.currentPage! - 1);
    }
  }

  void resetSearch() {
    _state = _state.copyWith(searchName: null, searchType: null);
    fetchPokemons(page: 1);
  }
}
