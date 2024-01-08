class SignupData {
  final String email;
  final String name;
  final String password;

  SignupData({
    required this.email,
    required this.name,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': password,
    };
  }
}
