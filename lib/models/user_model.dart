
class User {
  final String id;
  final String username;
  final List<UserFolder> folders;
  final List<UserBadge> badges;

  User({
    required this.id,
    required this.username,
    required this.folders,
    required this.badges,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper to parse 'folders' list
    var foldersList = json['folders'] as List? ?? [];
    List<UserFolder> userFolders =
        foldersList.map((folder) => UserFolder.fromJson(folder)).toList();

    // Helper to parse 'badges' list
    var badgesList = json['badges'] as List? ?? [];
    List<UserBadge> userBadges =
        badgesList.map((badge) => UserBadge.fromJson(badge)).toList();

    return User(
      id: json['_id'], // Mongoose uses _id
      username: json['username'],
      folders: userFolders,
      badges: userBadges,
    );
  }
}

// Model for the embedded FolderSchema
class UserFolder {
  final String id;
  final String name;
  final List<String> pokemons; //Since Schema has this data as String 

  UserFolder({
    required this.id,
    required this.name,
    required this.pokemons,
  });

  factory UserFolder.fromJson(Map<String, dynamic> json) {
    return UserFolder(
      id: json['_id'],
      name: json['name'],
      pokemons: List<String>.from(json['pokemons'] ?? []),
    );
  }
}

// Model for the embedded BadgeSchema
class UserBadge {
  final String id;
  final String name;
  final String gym;
  final DateTime collectedAt;

  UserBadge({
    required this.id,
    required this.name,
    required this.gym,
    required this.collectedAt,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['_id'],
      name: json['name'],
      gym: json['gym'],
      collectedAt: DateTime.parse(json['collectedAt']),
    );
  }
}