class User {
  int? id;
  String username;
  String? password;
  User({this.id, required this.username, this.password});

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'],
    password: json['password'],
  );

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'password': password};
  }
}
