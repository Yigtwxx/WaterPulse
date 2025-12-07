class User {
  final int id;
  final String email;
  final String? name;
  final String? surname;
  final double? weightKg;
  final double? heightCm;
  final int? age;
  final String? gender;
  final String? activityLevel;
  final int dailyGoalMl;
  final int preferredCupMl;
  final int quickAdd1Ml;
  final int quickAdd2Ml;
  final String language;
  final String subscriptionPlan;
  final bool isVerified;
  final String? friendCode;

  User({
    required this.id,
    required this.email,
    this.name,
    this.surname,
    this.weightKg,
    this.heightCm,
    this.age,
    this.gender,
    this.activityLevel,
    required this.dailyGoalMl,
    required this.preferredCupMl,
    required this.quickAdd1Ml,
    required this.quickAdd2Ml,
    required this.language,
    required this.subscriptionPlan,
    required this.isVerified,
    this.friendCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      surname: json['surname'],
      weightKg: json['weight_kg']?.toDouble(),
      heightCm: json['height_cm']?.toDouble(),
      age: json['age'],
      gender: json['gender'],
      activityLevel: json['activity_level'],
      dailyGoalMl: json['daily_goal_ml'] ?? 2000,
      preferredCupMl: json['preferred_cup_ml'] ?? 250,
      quickAdd1Ml: json['quick_add_1_ml'] ?? 250,
      quickAdd2Ml: json['quick_add_2_ml'] ?? 500,
      language: json['language'] ?? 'en',
      subscriptionPlan: json['subscription_plan'] ?? 'basic',
      isVerified: json['is_verified'] ?? false,
      friendCode: json['friend_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'surname': surname,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'age': age,
      'gender': gender,
      'activity_level': activityLevel,
      'daily_goal_ml': dailyGoalMl,
      'preferred_cup_ml': preferredCupMl,
      'quick_add_1_ml': quickAdd1Ml,
      'quick_add_2_ml': quickAdd2Ml,
      'language': language,
      'subscription_plan': subscriptionPlan,
      'is_verified': isVerified,
      'friend_code': friendCode,
    };
  }
}
