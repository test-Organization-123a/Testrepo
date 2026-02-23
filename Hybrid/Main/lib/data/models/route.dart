class RouteModel {
  final String id;
  final String name;
  final String grade;
  final String description;
  final String locationId;
  final DateTime createdAt;
  final List<RouteRating> ratings;

  RouteModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.description,
    required this.locationId,
    required this.createdAt,
    this.ratings = const [],
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'],
      name: json['name'],
      grade: json['grade'],
      description: json['description'] ?? '',
      locationId: json['locationId'],
      createdAt: DateTime.parse(json['createdAt']),
      ratings: (json['ratings'] as List<dynamic>?)
          ?.map((r) => RouteRating.fromJson(r))
          .toList() ??
          [],
    );
  }
}

class RouteRating {
  final String id;
  final String grade;
  final String userId;
  final String routeId;
  final DateTime createdAt;

  RouteRating({
    required this.id,
    required this.grade,
    required this.userId,
    required this.routeId,
    required this.createdAt,
  });

  factory RouteRating.fromJson(Map<String, dynamic> json) {
    return RouteRating(
      id: json['id'],
      grade: json['grade'],
      userId: json['userId'],
      routeId: json['routeId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
