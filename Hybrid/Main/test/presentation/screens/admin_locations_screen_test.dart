import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prototype/data/models/location.dart';
import 'package:prototype/presentation/state/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:prototype/presentation/screens/admin_screens/admin_locations_screen.dart';
import 'package:prototype/presentation/state/location_provider.dart';
import '../../mocks.mocks.dart';

void main() {
  late MockLocationProvider mockLocationProvider;
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockLocationProvider = MockLocationProvider();
    mockAuthProvider = MockAuthProvider();
    when(mockAuthProvider.isAuthenticated).thenReturn(true);
    when(mockLocationProvider.isLoading).thenReturn(false);
    when(mockLocationProvider.error).thenReturn(null);
    when(mockLocationProvider.locations).thenReturn([]);
    when(mockLocationProvider.loadLocations()).thenAnswer((_) async => Future.value());
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocationProvider>.value(value: mockLocationProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
      ],
      child: const MaterialApp(
        home: AdminLocationsScreen(),
      ),
    );
  }

  final testLocations = [
    Location(
      id: 'loc1',
      name: 'Location 1',
      description: 'Description 1',
      address: 'Address 1',
      createdAt: DateTime(2023, 1, 1),
      images: [],
    ),
    Location(
      id: 'loc2',
      name: 'Location 2',
      description: 'Description 2',
      address: 'Address 2',
      createdAt: DateTime(2023, 1, 2),
      images: [],
    ),
  ];

  testWidgets('shows loading indicator when loading', (tester) async {
    when(mockLocationProvider.isLoading).thenReturn(true);
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message when error occurs', (tester) async {
    when(mockLocationProvider.error).thenReturn('Failed to load');
    await tester.pumpWidget(createTestWidget());
    expect(find.textContaining('Error: Failed to load'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
    await tester.pump();
    verify(mockLocationProvider.loadLocations()).called(2);
  });

  testWidgets('shows empty state when no locations', (tester) async {
    when(mockLocationProvider.locations).thenReturn([]);
    await tester.pumpWidget(createTestWidget());
    expect(find.text('No locations yet'), findsOneWidget);
    expect(find.text('Add your first climbing location!'), findsOneWidget);
  });

  testWidgets('shows list of locations', (tester) async {
    when(mockLocationProvider.locations).thenReturn(testLocations);
    await tester.pumpWidget(createTestWidget());
    for (final loc in testLocations) {
      expect(find.text(loc.name), findsOneWidget);
      expect(find.text(loc.address), findsOneWidget);
    }
  });

  testWidgets('tapping add button opens dialog', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('tapping edit calls dialog', (tester) async {
    when(mockLocationProvider.locations).thenReturn(testLocations);
    await tester.pumpWidget(createTestWidget());
    final editButton = find.descendant(
      of: find.byType(Card).first,
      matching: find.byIcon(Icons.edit),
    );
    await tester.tap(editButton);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('tapping delete shows confirmation and calls delete', (tester) async {
    when(mockLocationProvider.locations).thenReturn(testLocations);
    when(mockLocationProvider.deleteLocation(any)).thenAnswer((_) async => Future.value());
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
    verify(mockLocationProvider.deleteLocation('loc1')).called(1);
  });
}
