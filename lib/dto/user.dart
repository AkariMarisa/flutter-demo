class User {
  final int? id;
  final String? username;
  final String? token;

  User(this.id, this.username, this.token);

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        username = json['username'] as String?,
        token = json['token'] as String?;

  Map<String, dynamic> toJson() =>
      {'id': id, 'username': username, 'token': token};
}
