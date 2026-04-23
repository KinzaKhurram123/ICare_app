class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String? profilePicture;
  final String? cnic;
  final String? height;
  final String? weight;
  final String? address;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profilePicture,
    this.cnic,
    this.height,
    this.weight,
    this.address,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      profilePicture: json['profileImage'] ?? json['profilePicture'],
      cnic: json['cnic'],
      height: json['height']?.toString(),
      weight: json['weight']?.toString(),
      address: json['address'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'profilePicture': profilePicture,
      'cnic': cnic,
      'height': height,
      'weight': weight,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    String? profilePicture,
    String? cnic,
    String? height,
    String? weight,
    String? address,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      cnic: cnic ?? this.cnic,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
