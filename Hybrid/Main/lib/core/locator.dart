import '../data/services/api_service.dart';
import '../data/services/product_service.dart';
import '../data/services/token_storage.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/category_service.dart';
import '../data/repositories/category_repository.dart';
import '../data/services/location_service.dart';
import '../data/repositories/location_repository.dart';
import '../data/services/route_service.dart';
import '../data/repositories/route_repository.dart';
import '../data/services/order_service.dart';
import '../data/repositories/order_repository.dart';

class Locator {
  static late final ApiService api;

  static late final CategoryService categoryService;
  static late final ProductService productService;
  static late final LocationService locationService;
  static late final RouteService routeService;
  static late final OrderService orderService;

  static late final OrderRepository orderRepository;
  static late final RouteRepository routeRepository;
  static late final LocationRepository locationRepository;
  static late final ProductRepository productRepository;
  static late final CategoryRepository categoryRepository;

  static late final AuthRepository authRepository;

  static Future<void> initAuthToken() async {
    api = ApiService();

    final token = await TokenStorage.loadToken();
    if (token != null && token.isNotEmpty) {
      api.setAuthToken(token);
    }

    productService = ProductService();
    productRepository = ProductRepository();

    categoryService = CategoryService();
    categoryRepository = CategoryRepository();

    locationService = LocationService();
    locationRepository = LocationRepository();

    routeService = RouteService();
    routeRepository = RouteRepository();

    orderService = OrderService();
    orderRepository = OrderRepository();

    authRepository = AuthRepository();
  }

  /// Clears stored token
  static Future<void> clearAuth() async {
    await TokenStorage.clear();
    api.setAuthToken(null);
  }
}
