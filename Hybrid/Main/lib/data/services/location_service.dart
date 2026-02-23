import 'dart:io';
import 'dart:typed_data';
import '../../core/locator.dart' as di;
import 'api_service.dart';
import '../models/location.dart';

class LocationService {
  final ApiService _api = di.Locator.api;

  /// Get all locations
  Future<List<Location>> getLocations() async {
    final data = await _api.get('locations');
    if (data is List) {
      return data.map((e) => Location.fromJson(e)).toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }

  /// Get a single location by ID
  Future<Location> getLocationById(String id) async {
    final data = await _api.get('locations/$id');
    return Location.fromJson(data);
  }

  /// Create a new location (admin only)
  Future<Location> createLocation({
    required String name,
    required String description,
    required String address,
    List<File>? imageFiles,
    Uint8List? webImageBytes,
    String? webImageName,
  }) async {
    final data = await _api.postMultipart(
      'locations',
      fields: {
        'name': name,
        'description': description,
        'address': address,
      },
      files: imageFiles,
      webImageBytes: webImageBytes,
      webImageName: webImageName,
    );
    return Location.fromJson(data);
  }

  /// Update location (admin only)
  Future<Location> updateLocation(
    String id, 
    Map<String, dynamic> fields, {
    File? imageFile,
    Uint8List? webImageBytes,
    String? webImageName,
    List<String>? existingImages,
  }) async {
    // Convert fields to String values and include existing images
    final stringFields = <String, String>{};
    fields.forEach((key, value) {
      stringFields[key] = value.toString();
    });

    if (existingImages != null && existingImages.isNotEmpty) {
      for (int i = 0; i < existingImages.length; i++) {
        stringFields['existingImages[$i]'] = existingImages[i];
      }
    }

    final data = await _api.putMultipart(
      'locations/$id',
      fields: stringFields,
      files: imageFile != null ? [imageFile] : null,
      webImageBytes: webImageBytes,
      webImageName: webImageName,
    );
    return Location.fromJson(data);
  }

  /// Delete location (admin only)
  Future<void> deleteLocation(String id) async {
    await _api.delete('locations/$id');
  }
}
