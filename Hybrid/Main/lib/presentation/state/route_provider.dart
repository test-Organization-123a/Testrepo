import 'package:flutter/foundation.dart';
import '../../core/locator.dart' as di;
import '../../data/models/route.dart';
import '../../data/repositories/route_repository.dart';

class RouteProvider extends ChangeNotifier {
  final RouteRepository _repo = di.Locator.routeRepository;

  List<RouteModel> _routes = [];
  bool _loading = false;
  String? _error;

  List<RouteModel> get routes => _routes;
  bool get isLoading => _loading;
  String? get error => _error;

  /// Load all routes
  Future<void> loadRoutes() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _routes = await _repo.fetchAll();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  /// Create a new route (admin)
  Future<void> createRoute({
    required String name,
    required String grade,
    required String locationId,
    String? description,
  }) async {
    try {
      final route = await _repo.create(
        name: name,
        grade: grade,
        locationId: locationId,
        description: description,
      );
      _routes.add(route);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update route (admin)
  Future<void> updateRoute(String id, Map<String, dynamic> fields) async {
    try {
      final updated = await _repo.update(id, fields);
      final index = _routes.indexWhere((r) => r.id == id);
      if (index != -1) _routes[index] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete route (admin)
  Future<void> deleteRoute(String id) async {
    try {
      await _repo.delete(id);
      _routes.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Submit or update user rating
  Future<void> rateRoute(String id, String grade) async {
    try {
      final rating = await _repo.rate(id, grade);
      final index = _routes.indexWhere((r) => r.id == id);
      if (index != -1) {
        final route = _routes[index];
        _routes[index] = RouteModel(
          id: route.id,
          name: route.name,
          grade: route.grade,
          description: route.description,
          locationId: route.locationId,
          createdAt: route.createdAt,
          ratings: [...route.ratings, rating],
        );
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
