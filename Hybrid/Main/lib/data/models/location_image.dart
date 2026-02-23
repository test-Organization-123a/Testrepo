import '../../config/api_config.dart';

class LocationImage {
  final String id;
  final String url;
  final String locationId;

  LocationImage({
    required this.id,
    required this.url,
    required this.locationId,
  });

  factory LocationImage.fromJson(Map<String, dynamic> json) {
    final String rawUrl = json['url'] ?? '';
    final String fullUrl = rawUrl.startsWith('http') 
        ? rawUrl 
        : '${ApiConfig.baseUrl}$rawUrl';

    return LocationImage(
      id: json['id'] ?? '',
      url: fullUrl,
      locationId: json['locationId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url.replaceFirst(ApiConfig.baseUrl, ''),
    'locationId': locationId,
  };
}