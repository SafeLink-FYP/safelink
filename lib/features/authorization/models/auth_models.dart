import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String dateOfBirth;
  final String phone;
  final String? cnic;
  final String? region;
  final String? city;
  final File? profilePicture;

  const SignUpModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.dateOfBirth,
    this.cnic,
    this.region,
    this.city,
    this.profilePicture,
  });

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  Map<String, dynamic> toAuthMetadata() => {
    'role': 'citizen',
    'full_name': fullName,
    'phone': phone,
    'date_of_birth': dateOfBirth,
    if (cnic != null && cnic!.isNotEmpty) 'cnic': cnic,
    if (region != null && region!.isNotEmpty) 'region': region,
    if (city != null && city!.isNotEmpty) 'city': city,
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
