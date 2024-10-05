import 'package:flutter/material.dart';
import '../../core/constants.dart';

class SearchCard extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedType;
  final VoidCallback onSearch;
  final ValueChanged<String?> onTypeChanged;

  const SearchCard({
    Key? key,
    required this.searchController,
    required this.selectedType,
    required this.onSearch,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Pokémon',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    onSearch();
                  },
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onSubmitted: (_) => onSearch(),
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
              value: selectedType.isEmpty ? '' : selectedType,
              hint: const Text('Select Type'),
              isExpanded: true,
              items: ['', ...pokemonTypes]
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.isEmpty ? 'All types' : type),
                      ))
                  .toList(),
              onChanged: (value) {
                onTypeChanged(value!.isEmpty ? null : value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
