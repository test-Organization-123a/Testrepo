import '../../core/locator.dart' as di;
import 'api_service.dart';
import '../models/route.dart';

class RouteService {
  final ApiService _api = di.Locator.api;

  /// Get all routes
  Future<List<RouteModel>> getRoutes() async {
    final data = await _api.get('routes');
    if (data is List) {
      return data.map((e) => RouteModel.fromJson(e)).toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }

  /// Get a single route by ID
  Future<RouteModel> getRouteById(String id) async {
    final data = await _api.get('routes/$id');
    return RouteModel.fromJson(data);
  }

  /// Create a new route (admin only)
  Future<RouteModel> createRoute({
    required String name,
    required String grade,
    required String locationId,
    String? description,
  }) async {
    final data = await _api.post('routes', {
      'name': name,
      'grade': grade,
      'locationId': locationId,
      if (description != null) 'description': description,
    });
    return RouteModel.fromJson(data);
  }

  /// Update a route (admin only)
  Future<RouteModel> updateRoute(String id, Map<String, dynamic> fields) async {
    final data = await _api.put('routes/$id', fields);
    return RouteModel.fromJson(data);
  }

  /// Delete a route (admin only)
  Future<void> deleteRoute(String id) async {
    await _api.delete('routes/$id');
  }

  /// Submit or update user rating
  Future<RouteRating> rateRoute(String id, String grade) async {
    final data = await _api.post('routes/$id/rate', {'grade': grade});
    return RouteRating.fromJson(data);
  }
}
