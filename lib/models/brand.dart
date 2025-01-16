import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  String id;
  String name;
  String logoUrl;

  Brand({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  factory Brand.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Brand(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logoUrl': logoUrl,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
    };
  }

  
@override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Brand &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logoUrl'],
    );
  }

  // Static method to return an empty Brand
  static Brand empty() {
    return Brand(
      id: '',
      name: '',
      logoUrl: '',
    );
  }
}