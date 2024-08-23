class AppUser {
  String id;
  String firstName;
  String lastName;
  String address;
  String userType; // "Teacher", "Student", "Parent"
  String emailOrPhone;
  String password;
  List<String>? subject;
  String? studentClass;// Only for teachers

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.userType,
    required this.emailOrPhone,
    required this.password,
    this.subject,
    this.studentClass,
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
      'studentClass': studentClass??''
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      firstName: map['firstName'],
      lastName: map['lastName'],
      address: map['address'],
      userType: map['userType']??'admin',
      emailOrPhone: map['emailOrPhone']??'',
      password: map['password'],
      studentClass: map['studentClass']??'',
      subject: map['subject'] != null ? List<String>.from(map['subject']) : null,
    );
  }
}

