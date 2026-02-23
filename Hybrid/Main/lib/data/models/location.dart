import 'route.dart';
import 'location_image.dart';

class Location {
  final String id;
  final String name;
  final String description;
  final String address;
  final DateTime createdAt;
  final List<RouteModel> routes;
  final List<LocationImage> images;

  Location({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.createdAt,
    this.routes = const [],
    this.images = const [],
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      createdAt: DateTime.parse(json['createdAt']),
      routes: (json['routes'] as List<dynamic>?)
          ?.map((r) => RouteModel.fromJson(r))
          .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => LocationImage.fromJson(img))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'address': address,
    'images': images.map((img) => img.toJson()).toList(),
  };

  String get firstImageUrl => images.isNotEmpty 
      ? images.first.url 
      : 'https://via.placeholder.com/400x300?text=No+Image';

  List<String> get imageUrls => images.map((img) => img.url).toList();

  bool get hasImages => images.isNotEmpty;

  int get imageCount => images.length;
}
