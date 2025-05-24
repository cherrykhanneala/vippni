class Validators {
  // Basic required field validator
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
          ? '$fieldName is required' 
          : 'This field is required';
    }
    return null;
  }
  
  // Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Price validator
  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    
    try {
      final price = double.parse(value);
      if (price < 0) {
        return 'Price cannot be negative';
      }
    } catch (e) {
      return 'Please enter a valid price';
    }
    
    return null;
  }
  
  // Integer validator
  static String? integer(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    try {
      final number = int.parse(value);
      
      if (min != null && number < min) {
        return 'Value must be at least $min';
      }
      
      if (max != null && number > max) {
        return 'Value cannot exceed $max';
      }
    } catch (e) {
      return 'Please enter a valid whole number';
    }
    
    return null;
  }
  
  // Phone number validator
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Simple regex for international phone formats
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{8,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  // URL validator
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  // Date validator
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      
      if (date.isAfter(now)) {
        return 'Date cannot be in the future';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }
    
    return null;
  }
  
  // Custom validator with min/max length
  static String? Function(String?) minLength(int length, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'This field is required';
      }
      
      if (value.length < length) {
        return message ?? 'Must be at least $length characters long';
      }
      
      return null;
    };
  }
  
  static String? Function(String?) maxLength(int length, [String? message]) {
    return (String? value) {
      if (value != null && value.length > length) {
        return message ?? 'Cannot exceed $length characters';
      }
      
      return null;
    };
  }
  
  // Combined validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      
      return null;
    };
  }
}