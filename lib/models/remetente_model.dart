class Remetente {
  final int id;
  final String name;
  final String email;

  Remetente({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Remetente.fromJson(Map<String, dynamic> json) {
    return Remetente(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}