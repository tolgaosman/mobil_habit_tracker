import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 2)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String passwordHash;

  @HiveField(4)
  String? profileImagePath;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
    this.profileImagePath,
  });

  UserModel copyWith({
    String? email,
    String? name,
    String? passwordHash,
    String? profileImagePath,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      passwordHash: passwordHash ?? this.passwordHash,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
