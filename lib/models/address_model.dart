class Address {
  final String id;
  final String fullName;
  final String phone;
  final String addressLine;
  final String city;

  Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.city,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      fullName: json['fullName'],
      phone: json['phone'],
      addressLine: json['addressLine'],
      city: json['city'],
    );
  }
}
