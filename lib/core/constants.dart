const String kBaseUrl = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000/api/v1');
const int kItemsPerPage = 10;

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
