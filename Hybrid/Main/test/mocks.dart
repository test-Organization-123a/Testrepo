import 'package:mockito/annotations.dart';
import 'package:prototype/presentation/state/category_provider.dart';
import 'package:prototype/presentation/state/auth_provider.dart';
import 'package:prototype/presentation/state/order_provider.dart';
import 'package:prototype/presentation/state/product_provider.dart';
import 'package:prototype/presentation/state/location_provider.dart';
import 'package:prototype/presentation/state/route_provider.dart';

@GenerateMocks([
  CategoryProvider,
  AuthProvider,
  OrderProvider,
  ProductProvider,
  LocationProvider,
  RouteProvider,
])
void main() {
  // This file is used to generate mocks for testing.
  // It should not contain any tests.
}
