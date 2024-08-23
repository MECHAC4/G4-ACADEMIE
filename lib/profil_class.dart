class ProfilClass {
  String id;
  //bool isGroup;
  String firstName;
  String lastName;
  //String? groupName;
  String studentClass;
  //String? studentCount;
  String adresse;

  ProfilClass(
      {//required this.isGroup,
        required this.id,
        required this.firstName,
        required this.lastName,
        //this.groupName,
        required this.studentClass,
        //this.studentCount,
        required this.adresse});



  factory ProfilClass.fromMap(Map<String, dynamic> map) {
    return ProfilClass(
      id: map['id'],
      //isGroup: map['isGroup'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      //groupName: map['groupName'],
      studentClass: map['studentClass'],
      //studentCount: map['studentCount'],
      adresse: map['adresse'],
    );
  }


}

