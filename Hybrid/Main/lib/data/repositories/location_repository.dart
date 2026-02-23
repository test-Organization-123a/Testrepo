import 'dart:io';
import 'dart:typed_data';
import '../models/location.dart';
import '../services/location_service.dart';
import '../../core/locator.dart' as di;

class LocationRepository {
  final LocationService _service = di.Locator.locationService;

  Future<List<Location>> fetchAll() => _service.getLocations();
  Future<Location> fetchById(String id) => _service.getLocationById(id);

  Future<Location> create({
    required String name,
    required String description,
    required String address,
    List<File>? imageFiles,
    Uint8List? webImageBytes,
    String? webImageName,
  }) =>
      _service.createLocation(
        name: name,
        description: description,
        address: address,
        imageFiles: imageFiles,
        webImageBytes: webImageBytes,
        webImageName: webImageName,
      );

  Future<Location> update(
    String id, 
    Map<String, dynamic> fields, {
    File? imageFile,
    Uint8List? webImageBytes,
    String? webImageName,
    List<String>? existingImages,
  }) =>
      _service.updateLocation(
        id, 
        fields,
        imageFile: imageFile,
        webImageBytes: webImageBytes,
        webImageName: webImageName,
        existingImages: existingImages,
      );

  Future<void> delete(String id) => _service.deleteLocation(id);
}
