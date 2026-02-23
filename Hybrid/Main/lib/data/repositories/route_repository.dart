import '../models/route.dart';
import '../services/route_service.dart';
import '../../core/locator.dart' as di;

class RouteRepository {
  final RouteService _service = di.Locator.routeService;

  Future<List<RouteModel>> fetchAll() => _service.getRoutes();
  Future<RouteModel> fetchById(String id) => _service.getRouteById(id);

  Future<RouteModel> create({
    required String name,
    required String grade,
    required String locationId,
    String? description,
  }) =>
      _service.createRoute(
        name: name,
        grade: grade,
        locationId: locationId,
        description: description,
      );

  Future<RouteModel> update(String id, Map<String, dynamic> fields) =>
      _service.updateRoute(id, fields);

  Future<void> delete(String id) => _service.deleteRoute(id);

  Future<RouteRating> rate(String routeId, String grade) =>
      _service.rateRoute(routeId, grade);
}
