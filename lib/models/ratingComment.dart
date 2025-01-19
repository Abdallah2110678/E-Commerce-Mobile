class RatingComment {
  String userId; // Unique identifier for the user
  String userName; // Name of the user
  double rating; // Rating value (e.g., 1 to 5)
  String comment; // Comment text
  DateTime timestamp; // Time when the rating/comment was added

  RatingComment({
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  // Convert a RatingComment to a Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }
factory RatingComment.fromMap(Map<String, dynamic> map) {
  return RatingComment(
    userId: map['userId'] ?? 'Unknown User', // Default value if null
    userName: map['userName'] ?? 'Anonymous', // Default value if null
    rating: (map['rating'] as num?)?.toDouble() ?? 0.0, // Default to 0.0 if null
    comment: map['comment'] ?? 'No Comment', // Default value if null
    timestamp: map['timestamp'] != null
        ? DateTime.parse(map['timestamp'])
        : DateTime.now(), // Default to current time if null
  );
}
}