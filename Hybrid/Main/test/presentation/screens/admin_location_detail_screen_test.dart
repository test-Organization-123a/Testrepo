import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prototype/presentation/state/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:prototype/presentation/screens/admin_screens/admin_location_detail_screen.dart';
import 'package:prototype/presentation/state/route_provider.dart';
import 'package:prototype/data/models/location.dart';
import 'package:prototype/data/models/route.dart';
import '../../mocks.mocks.dart';

void main() {
  late MockRouteProvider mockRouteProvider;
  late MockAuthProvider mockAuthProvider;

  final testLocation = Location(
    id: 'loc1',
    name: 'Test Location',
    description: 'A test location for climbing.',
    address: '123 Test St',
    createdAt: DateTime(2023, 1, 1),
    images: [],
  );

  setUp(() {
    mockRouteProvider = MockRouteProvider();
    mockAuthProvider = MockAuthProvider();
    when(mockAuthProvider.isAuthenticated).thenReturn(true);
    when(mockRouteProvider.isLoading).thenReturn(false);
    when(mockRouteProvider.error).thenReturn(null);
    when(mockRouteProvider.routes).thenReturn([]);
    when(
      mockRouteProvider.loadRoutes(),
    ).thenAnswer((_) async => Future.value());
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RouteProvider>.value(value: mockRouteProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
      ],
      child: MaterialApp(
        home: AdminLocationDetailScreen(location: testLocation),
      ),
    );
  }

  testWidgets('shows loading indicator when loading', (tester) async {
    when(mockRouteProvider.isLoading).thenReturn(true);
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message when error occurs', (tester) async {
    when(mockRouteProvider.error).thenReturn('Failed to load');
    await tester.pumpWidget(createTestWidget());
    expect(find.textContaining('Error: Failed to load'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
    await tester.pump();
    verify(mockRouteProvider.loadRoutes()).called(greaterThan(0));
  });

  testWidgets('shows empty state when no routes', (tester) async {
    when(mockRouteProvider.routes).thenReturn([]);
    await tester.pumpWidget(createTestWidget());
    expect(find.text('No routes yet'), findsOneWidget);
    expect(
      find.text('Add the first climbing route for this location!'),
      findsOneWidget,
    );
  });

  testWidgets('shows list of routes for this location', (tester) async {
    final testRoutes = [
      RouteModel(
        id: 'route1',
        name: 'Route 1',
        description: 'Desc 1',
        grade: '6a',
        locationId: 'loc1',
        createdAt: DateTime(2023, 1, 1),
      ),
      RouteModel(
        id: 'route2',
        name: 'Route 2',
        description: 'Desc 2',
        grade: '6b',
        locationId: 'loc1',
        createdAt: DateTime(2023, 1, 2),
      ),
      // Route for another location (should not show)
      RouteModel(
        id: 'route3',
        name: 'Other',
        description: 'Other',
        grade: '5c',
        locationId: 'other',
        createdAt: DateTime(2023, 1, 3),
      ),
    ];
    when(mockRouteProvider.routes).thenReturn(testRoutes);
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Route 1'), findsOneWidget);
    expect(find.text('Route 2'), findsOneWidget);
    expect(find.text('Other'), findsNothing);
  });

  testWidgets('tapping add button opens dialog', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('tapping edit calls dialog', (tester) async {
    final testRoutes = [
      RouteModel(
        id: 'route1',
        name: 'Route 1',
        description: 'Desc 1',
        grade: '6a',
        locationId: 'loc1',
        createdAt: DateTime(2023, 1, 1),
      ),
    ];
    when(mockRouteProvider.routes).thenReturn(testRoutes);
    await tester.pumpWidget(createTestWidget());
    final editButton = find.descendant(
      of: find.byType(Card).first,
      matching: find.byIcon(Icons.edit),
    );
    await tester.tap(editButton);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('tapping delete shows confirmation and calls delete', (
    tester,
  ) async {
    final testRoutes = [
      RouteModel(
        id: 'route1',
        name: 'Route 1',
        description: 'Desc 1',
        grade: '6a',
        locationId: 'loc1',
        createdAt: DateTime(2023, 1, 1),
      ),
    ];
    when(mockRouteProvider.routes).thenReturn(testRoutes);
    when(
      mockRouteProvider.deleteRoute(any),
    ).thenAnswer((_) async => Future.value());
    await tester.pumpWidget(createTestWidget());
    final deleteButton = find.descendant(
      of: find.byType(Card).first,
      matching: find.byIcon(Icons.delete),
    );
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();
    verify(mockRouteProvider.deleteRoute('route1')).called(1);
  });
}
