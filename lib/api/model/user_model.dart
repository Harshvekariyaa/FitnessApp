class User {
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userCity;
  final String userPassword;
  final String userConfirmPassword;
  final String userBirthdate;
  final int userHeight;
  final int userWeight;
  final int userTargetWeight;
  final String userGender;
  final int userGoal;
  final String userBodyType;
  final String? userImage;

  User({
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userCity,
    required this.userPassword,
    required this.userConfirmPassword,
    required this.userBirthdate,
    required this.userHeight,
    required this.userWeight,
    required this.userTargetWeight,
    required this.userGender,
    required this.userGoal,
    required this.userBodyType,
    this.userImage,
  });

  /// Factory constructor from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userName: json['user_name'],
      userEmail: json['user_email'],
      userPhone: json['user_phone'],
      userCity: json['user_city'],
      userPassword: json['user_password'] ?? '', // optional in response
      userConfirmPassword: json['user_confirm_password'] ?? '', // optional in response
      userBirthdate: json['user_birthdate'],
      userHeight: json['user_height'],
      userWeight: json['user_weight'],
      userTargetWeight: json['user_target_weight'],
      userGender: json['user_gender'],
      userGoal: json['user_goal'],
      userBodyType: json['user_body_type'],
      userImage: json['user_image'],
    );
  }

  /// Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'user_city': userCity,
      'user_password': userPassword,
      'user_confirm_password': userConfirmPassword,
      'user_birthdate': userBirthdate,
      'user_height': userHeight,
      'user_weight': userWeight,
      'user_target_weight': userTargetWeight,
      'user_gender': userGender.toLowerCase(),
      'user_goal': userGoal,
      'user_body_type': userBodyType.toLowerCase(),
      'user_image': userImage,
    };
  }
}
