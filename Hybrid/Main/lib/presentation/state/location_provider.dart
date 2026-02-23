import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/locator.dart' as di;
import '../../data/models/location.dart';
import '../../data/repositories/location_repository.dart';

class LocationProvider extends ChangeNotifier {
  final LocationRepository _repo = di.Locator.locationRepository;

  List<Location> _locations = [];
  bool _loading = false;
  String? _error;

  List<Location> get locations => _locations;
  bool get isLoading => _loading;
  String? get error => _error;

  /// Load all locations
  Future<void> loadLocations() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _locations = await _repo.fetchAll();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  /// Create a new location (admin)
  Future<void> createLocation({
    required String name,
    required String description,
    required String address,
    List<File>? imageFiles,
    Uint8List? webImageBytes,
    String? webImageName,
  }) async {
    try {
      final location = await _repo.create(
        name: name,
        description: description,
        address: address,
        imageFiles: imageFiles,
        webImageBytes: webImageBytes,
        webImageName: webImageName,
      );
      _locations.add(location);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update location (admin)
  Future<void> updateLocation(
    String id, 
    Map<String, dynamic> fields, {
    File? imageFile,
    Uint8List? webImageBytes,
    String? webImageName,
    List<String>? existingImages,
  }) async {
    try {
      final updated = await _repo.update(
        id, 
        fields,
        imageFile: imageFile,
        webImageBytes: webImageBytes,
        webImageName: webImageName,
        existingImages: existingImages,
      );
      final index = _locations.indexWhere((l) => l.id == id);
      if (index != -1) _locations[index] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete location (admin)
  Future<void> deleteLocation(String id) async {
    try {
      await _repo.delete(id);
      _locations.removeWhere((l) => l.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
