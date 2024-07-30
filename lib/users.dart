class AppUser {
  String id;
  String firstName;
  String lastName;
  String address;
  String userType; // "Teacher", "Student", "Parent"
  String emailOrPhone;
  String password;
  List<String>? subject; // Only for teachers

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.userType,
    required this.emailOrPhone,
    required this.password,
    this.subject,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'userType': userType,
      'emailOrPhone': emailOrPhone,
      'password': password,
      'subject': subject,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      firstName: map['firstName'],
      lastName: map['lastName'],
      address: map['address'],
      userType: map['userType'],
      emailOrPhone: map['emailOrPhone'],
      password: map['password'],
      subject: map['subject'],
    );
  }
}
