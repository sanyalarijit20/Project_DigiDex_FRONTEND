

// Main Pokémon class
class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final PokemonInfo info;
  final List<PokemonStat> stats;
  final List<String> moves;
  final List<DamageRelations> typeData;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.info,
    required this.stats,
    required this.moves,
    required this.typeData,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      info: PokemonInfo.fromJson(json['info'] ?? {}),
      stats: (json['stats'] as List? ?? [])
          .map((s) => PokemonStat.fromJson(s))
          .toList(),
      moves: List<String>.from(json['moves'] ?? []),
      typeData: (json['typeData'] as List? ?? [])
          .map((t) => DamageRelations.fromJson(t))
          .toList(),
    );
  }
}

// Nested class for the "info" object
class PokemonInfo {
  final int height;
  final int weight;
  final List<String> types;
  final String description;

  PokemonInfo({
    required this.height,
    required this.weight,
    required this.types,
    required this.description,
  });

  factory PokemonInfo.fromJson(Map<String, dynamic> json) {
    return PokemonInfo(
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      types: List<String>.from(json['types'] ?? []),
      description: json['description'] ?? 'No description available.',
    );
  }
}

// Nested class for each item in the "stats" list
class PokemonStat {
  final String name;
  final int value;

  PokemonStat({required this.name, required this.value});

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['name'] ?? 'unknown',
      value: json['value'] ?? 0,
    );
  }
}

// --- Nested Classes for "typeData" (Matchups) ---

class DamageRelations {
  final List<TypeRelation> doubleDamageFrom;
  final List<TypeRelation> doubleDamageTo;
  final List<TypeRelation> halfDamageFrom;
  final List<TypeRelation> halfDamageTo;
  final List<TypeRelation> noDamageFrom;
  final List<TypeRelation> noDamageTo;

  DamageRelations({
    required this.doubleDamageFrom,
    required this.doubleDamageTo,
    required this.halfDamageFrom,
    required this.halfDamageTo,
    required this.noDamageFrom,
    required this.noDamageTo,
  });

  factory DamageRelations.fromJson(Map<String, dynamic> json) {
    // Helper to parse the lists
    List<TypeRelation> parseList(dynamic list) {
      return (list as List? ?? [])
          .map((e) => TypeRelation.fromJson(e))
          .toList();
    }

    return DamageRelations(
      doubleDamageFrom: parseList(json['double_damage_from']),
      doubleDamageTo: parseList(json['double_damage_to']),
      halfDamageFrom: parseList(json['half_damage_from']),
      halfDamageTo: parseList(json['half_damage_to']),
      noDamageFrom: parseList(json['no_damage_from']),
      noDamageTo: parseList(json['no_damage_to']),
    );
  }
}

class TypeRelation {
  final String name;
  TypeRelation({required this.name});

  factory TypeRelation.fromJson(Map<String, dynamic> json) {
    return TypeRelation(name: json['name'] ?? 'unknown');
  }
}