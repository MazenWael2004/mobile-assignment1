

class User{
  String fullName;
  String universityEmail;
  int studentID;
  String ?gender;
  int ?level;
  String password;
  String ?profilePictureUrl;
  User({required this.fullName, required this.universityEmail,required this.studentID,this.gender, this.level, this.profilePictureUrl, required this.password});
}

// Convert a User object into a Map.
Map<String, dynamic> userToMap(User user) {
  return {
    'fullName': user.fullName,
    'universityEmail': user.universityEmail,
    'studentID': user.studentID,
    'gender': user.gender,
    'level': user.level,
    'profilePictureUrl': user.profilePictureUrl,
    'password': user.password,
    
  };
}

// Extract a User object from a Map.
User userFromMap(Map<String, dynamic> map) {
  return User(
    fullName: map['fullName'],
    universityEmail: map['universityEmail'],
    studentID: map['studentID'],
    gender: map['gender'],
    level: map['level'],
    profilePictureUrl: map['profilePictureUrl'],
    password: map['password'],
  );
}

