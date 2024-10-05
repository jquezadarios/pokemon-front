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
