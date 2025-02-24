class Destinatario {
  final int id;
  final String name;
  final String email;

  Destinatario({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Destinatario.fromJson(Map<String, dynamic> json) {
    return Destinatario(
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