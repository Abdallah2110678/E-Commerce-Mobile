import 'package:cloud_firestore/cloud_firestore.dart';


// First, let's create the Brand model
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
}
