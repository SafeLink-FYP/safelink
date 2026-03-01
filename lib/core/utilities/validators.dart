class Validators {
  // NAME VALIDATION
  static String? validateName(String? name) {
    final n = name?.trim() ?? '';
    if (n.isEmpty) {
      return 'Name is required';
    }
    if (n.length < 2) {
      return 'Name is too short';
    }
    if (!RegExp(r"^[a-zA-Z\s'.-]+$").hasMatch(n)) {
      return 'Please enter a valid name';
    }
    return null;
  }

  // EMAIL VALIDATION
  static String? validateEmail(String? email) {
    final e = email?.trim() ?? '';
    if (e.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(e)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // PASSWORD VALIDATION
  static String? validatePassword(String? password) {
    final p = password?.trim() ?? '';
    if (p.isEmpty) {
      return 'Password is required';
    }
    if (p.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(p)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(p)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // CONFIRM PASSWORD VALIDATION
  static String? validateConfirmPassword(
      String? confirmPassword,
      String? originalPassword,
      ) {
    final confirm = confirmPassword?.trim() ?? '';
    final original = originalPassword?.trim() ?? '';

    if (confirm.isEmpty) {
      return 'Please enter your Password again';
    }
    if (confirm != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  // PHONE NUMBER VALIDATION
  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null;
    }

    final regex = RegExp(r'^\+?[0-9]{10,15}$');

    if (!regex.hasMatch(phoneNumber)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  // CNIC VALIDATION (Pakistan)
  static String? validateCNIC(String? cnic) {
    final value = cnic?.trim() ?? '';

    if (value.isEmpty) {
      return 'CNIC is required';
    }

    // Format: 35202-1234567-1
    final regex = RegExp(r'^[0-9]{5}-[0-9]{7}-[0-9]{1}$');

    if (!regex.hasMatch(value)) {
      return 'Enter a valid CNIC (XXXXX-XXXXXXX-X)';
    }

    return null;
  }

  // DATE OF BIRTH VALIDATION
  static String? validateDOB(String? dateOfBirth) {
    if (dateOfBirth == null || dateOfBirth.isEmpty) {
      return 'Please enter your date of birth';
    }

    final parts = dateOfBirth.split(' ');
    final day = int.parse(parts[0]);
    final monthStr = parts[1].replaceAll(',', '');
    final year = int.parse(parts[2]);

    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final month = monthNames.indexOf(monthStr) + 1;
    final dob = DateTime(year, month, day);

    final today = DateTime.now();
    final age =
        today.year -
            dob.year -
            ((today.month < dob.month ||
                (today.month == dob.month && today.day < dob.day))
                ? 1
                : 0);

    if (dob.isAfter(today)) {
      return 'Date of birth cannot be in the future';
    }
    if (age < 18) {
      return 'You must be at least 18 years old';
    }

    return null;
  }
}
