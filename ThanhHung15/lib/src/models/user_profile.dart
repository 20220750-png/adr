class UserProfile {
  final String id;
  final String username;
  final bool isGuest;

  const UserProfile({
    required this.id,
    required this.username,
    required this.isGuest,
  });

  Map<String, Object?> toJson() => {
        'id': id,
        'username': username,
        'isGuest': isGuest,
      };

  static UserProfile fromJson(Map<String, Object?> json) => UserProfile(
        id: (json['id'] as String?) ?? '',
        username: (json['username'] as String?) ?? 'Guest',
        isGuest: (json['isGuest'] as bool?) ?? true,
      );
}

