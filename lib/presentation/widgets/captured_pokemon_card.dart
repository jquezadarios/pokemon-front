import 'package:flutter/material.dart';
import '../controllers/pokemon_controller.dart';

class CapturedPokemonCard extends StatelessWidget {
  final PokemonController controller;

  const CapturedPokemonCard({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final capturedPokemons = controller.state.capturedPokemons;
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
}
