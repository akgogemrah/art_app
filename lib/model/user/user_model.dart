class UserModel {
  String authType;
  String creationTime;
  String email;
  String lastSignedIn;
  String name;
  String platform;

  String userId;

  UserModel({
    required this.authType,
    required this.creationTime,
    required this.email,
    required this.lastSignedIn,
    required this.name,
    required this.platform,

    required this.userId,
  });

  // JSON'dan UserModel'e dönüştürmek için factory metod
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      authType: json['auth_type']??"",
      creationTime: json['creation_time']??"",
      email: json['email']??"",
      lastSignedIn: json['last_signed_in']??"",
      name: json['name']??"",
      platform: json['platform']??"",

      userId: json['user_id']??"",
    );
  }

  // UserModel'i JSON'a dönüştürmek için metod
  Map<String, dynamic> toJson() {
    return {
      'auth_type': authType,
      'creation_time': creationTime,
      'email': email,
      'last_signed_in': lastSignedIn,
      'name': name,
      'platform': platform,

      'user_id': userId,
    };
  }
}
