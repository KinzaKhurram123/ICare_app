class Lab {
  final String? id;
  final String? title;
  final String? photo;
  final List<String>? tests;
  final dynamic appointmentFee;
  final String? address;
  final String? delivery;
  final dynamic rating;

  const Lab({
    this.id,
    this.title,
    this.photo,
    this.tests,
    this.appointmentFee,
    this.address,
    this.delivery,
    this.rating,
  });

  factory Lab.fromJson(Map<String, dynamic> json) {
    return Lab(
      id: json['id']?.toString(),
      title: json['title'],
      photo: json['photo'],
      tests: json['tests'] != null ? List<String>.from(json['tests']) : null,
      appointmentFee: json['appointmentFee'],
      address: json['address'],
      delivery: json['delivery'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'photo': photo,
      'tests': tests,
      'appointmentFee': appointmentFee,
      'address': address,
      'delivery': delivery,
      'rating': rating,
    };
  }
}
