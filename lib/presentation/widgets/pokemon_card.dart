import 'package:flutter/material.dart';
import '../../domain/entities/pokemon.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final bool isCaptured;
  final VoidCallback onTap;

  const PokemonCard({
    Key? key,
    required this.pokemon,
    required this.isCaptured,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
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
}
