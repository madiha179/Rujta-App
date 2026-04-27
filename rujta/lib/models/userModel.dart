class Usermodel {
  final String name;
  final String email;
  final String phone;

  Usermodel({required this.name, required this.email, required this.phone});

  factory Usermodel.fromJson(Map<String, dynamic> json) {
    return Usermodel(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}