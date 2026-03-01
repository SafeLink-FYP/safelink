import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String dateOfBirth;
  final String? phone;
  final File? profilePicture;

  const SignUpModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phone,
    required this.dateOfBirth,
    this.profilePicture,
  });

  Map<String, dynamic> toAuthMetadata() => {
    'firstName': firstName.trim(),
    'lastName': lastName.trim(),
    'phone': phone,
    'dateOfBirth': dateOfBirth,
    'role': 'citizen',
  };

  Map<String, dynamic> toProfileUpdate(String? avatarUrl) => {
    'phone': phone,
    'date_of_birth': dateOfBirth,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
  };
}

class SignInModel {
  final String email;
  final String password;
  final bool rememberMe;

  const SignInModel({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() => {
    'email': email.trim(),
    'password': password,
  };
}

class ResetPasswordModel {
  final String email;

  const ResetPasswordModel({required this.email});

  Map<String, dynamic> toJson() => {'email': email.trim()};
}

class OAuthSignInModel {
  final OAuthProvider provider;

  const OAuthSignInModel({required this.provider});
}
