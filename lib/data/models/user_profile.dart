class UserProfile {
  final String id;
  final String email;
  final String username;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.avatarUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String,
    );
  }

  factory UserProfile.fromSupabase(
    Map<String, dynamic> userData,
    Map<String, dynamic> profileData,
  ) {
    return UserProfile(
      id: userData['id'] ?? '',
      email: userData['email'] ?? '',
      username: profileData['username'] ?? '',
      avatarUrl: profileData['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar_url': avatarUrl,
    };
  }

  @override
  String toString() {
    return 'UserProfile(username: $username)';
  }
}
