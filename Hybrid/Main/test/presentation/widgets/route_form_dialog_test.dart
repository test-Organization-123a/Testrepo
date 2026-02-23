import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:prototype/presentation/widgets/form_dialogs/route_form_dialog.dart';
import 'package:prototype/presentation/state/route_provider.dart';
import 'package:prototype/data/models/route.dart';
import '../../mocks.mocks.dart';

void main() {
  late MockRouteProvider mockRouteProvider;

  setUp(() {
    mockRouteProvider = MockRouteProvider();
    when(mockRouteProvider.isLoading).thenReturn(false);
    when(mockRouteProvider.error).thenReturn(null);
    when(mockRouteProvider.routes).thenReturn([]);
    when(
      mockRouteProvider.loadRoutes(),
    ).thenAnswer((_) async => Future.value());
  });

  Widget createTestWidget({RouteModel? route, required String locationId}) {
    return ChangeNotifierProvider<RouteProvider>.value(
      value: mockRouteProvider,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) =>
                RouteFormDialog(existingRoute: route, locationId: locationId),
          ),
        ),
      ),
    );
  }

  final testRoute = RouteModel(
    id: 'route1',
    name: 'Test Route',
    description: 'A test route.',
    grade: '6a',
    locationId: 'loc1',
    createdAt: DateTime(2023, 1, 1),
  );

  testWidgets('renders in add mode', (tester) async {
    await tester.pumpWidget(createTestWidget(locationId: 'loc1'));
    expect(find.text('Add New Route'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Create'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Update'), findsNothing);
  });

  testWidgets('renders in edit mode', (tester) async {
    await tester.pumpWidget(
      createTestWidget(route: testRoute, locationId: 'loc1'),
    );
    expect(find.text('Edit Route'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Update'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Create'), findsNothing);
  });

  testWidgets('shows validation errors for empty fields', (tester) async {
    await tester.pumpWidget(createTestWidget(locationId: 'loc1'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();
    expect(find.text('Route name is required'), findsOneWidget);
    expect(find.text('Grade is required'), findsOneWidget);
  });

  testWidgets('shows validation errors for short fields', (tester) async {
    await tester.pumpWidget(createTestWidget(locationId: 'loc1'));
    await tester.enterText(find.byType(TextFormField).at(0), 'A');
    await tester.enterText(find.byType(TextFormField).at(1), 'B');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();
    expect(find.textContaining('at least 2 characters'), findsNWidgets(2));
  });

  testWidgets('calls createRoute and closes dialog on valid add', (
    tester,
  ) async {
    when(
      mockRouteProvider.createRoute(
        name: anyNamed('name'),
        grade: anyNamed('grade'),
        locationId: anyNamed('locationId'),
        description: anyNamed('description'),
      ),
    ).thenAnswer((_) async => Future.value());
    await tester.pumpWidget(createTestWidget(locationId: 'loc1'));
    await tester.enterText(find.byType(TextFormField).at(0), 'New Route');
    await tester.enterText(find.byType(TextFormField).at(1), '6b+');
    await tester.enterText(find.byType(TextFormField).at(2), 'A nice route.');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();
    verify(
      mockRouteProvider.createRoute(
        name: 'New Route',
        grade: '6b+',
        locationId: 'loc1',
        description: 'A nice route.',
      ),
    ).called(1);
    expect(find.byType(RouteFormDialog), findsNothing);
  });

  testWidgets('calls updateRoute and closes dialog on valid edit', (
    tester,
  ) async {
    when(
      mockRouteProvider.updateRoute(any, any),
    ).thenAnswer((_) async => Future.value());
    await tester.pumpWidget(
      createTestWidget(route: testRoute, locationId: 'loc1'),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'Updated Route');
    await tester.enterText(find.byType(TextFormField).at(1), '7a');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'A much better description.',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Update'));
    await tester.pumpAndSettle();
    verify(
      mockRouteProvider.updateRoute('route1', {
        'name': 'Updated Route',
        'description': 'A much better description.',
        'grade': '7a',
      }),
    ).called(1);
    expect(find.byType(RouteFormDialog), findsNothing);
  });

  testWidgets('shows snackbar on createRoute failure', (tester) async {
    when(
      mockRouteProvider.createRoute(
        name: anyNamed('name'),
        grade: anyNamed('grade'),
        locationId: anyNamed('locationId'),
        description: anyNamed('description'),
      ),
    ).thenThrow(Exception('fail'));
    await tester.pumpWidget(createTestWidget(locationId: 'loc1'));
    await tester.enterText(find.byType(TextFormField).at(0), 'New Route');
    await tester.enterText(find.byType(TextFormField).at(1), '6b+');
    await tester.enterText(find.byType(TextFormField).at(2), 'A nice route.');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Failed to save route'), findsOneWidget);
    expect(find.byType(RouteFormDialog), findsOneWidget);
  });

  testWidgets('cancel button closes dialog', (tester) async {
    await tester.pumpWidget(createTestWidget(locationId: 'loc1'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(RouteFormDialog), findsNothing);
  });
}
