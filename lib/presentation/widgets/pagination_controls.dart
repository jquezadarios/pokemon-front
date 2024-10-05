import 'package:flutter/material.dart';
import '../controllers/pokemon_controller.dart';

class PaginationControls extends StatelessWidget {
  final PokemonController controller;

  const PaginationControls({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final state = controller.state;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: state.currentPage != null && state.currentPage! > 1
                    ? controller.previousPage
                    : null,
                child: const Text('Previous'),
              ),
              Text(
                  'Page ${state.currentPage ?? 1} of ${state.totalPages ?? 1}'),
              ElevatedButton(
                onPressed: state.currentPage != null &&
                        state.totalPages != null &&
                        state.currentPage! < state.totalPages!
                    ? controller.nextPage
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        );
      },
    );
  }
}
