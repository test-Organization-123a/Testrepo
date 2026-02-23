import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prototype/data/models/location.dart';
import 'package:provider/provider.dart';
import 'package:prototype/presentation/widgets/form_dialogs/location_form_dialog.dart';
import 'package:prototype/presentation/state/location_provider.dart';
import '../../mocks.mocks.dart';

void main() {
  late MockLocationProvider mockLocationProvider;

  setUp(() {
    mockLocationProvider = MockLocationProvider();
    when(mockLocationProvider.isLoading).thenReturn(false);
    when(mockLocationProvider.error).thenReturn(null);
    when(mockLocationProvider.locations).thenReturn([]);
    when(mockLocationProvider.loadLocations()).thenAnswer((_) async => Future.value());
  });

  Widget createTestWidget({location}) {
    return ChangeNotifierProvider<LocationProvider>.value(
      value: mockLocationProvider,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => LocationFormDialog(existingLocation: location),
          ),
        ),
      ),
    );
  }

  final testLocation = Location(
    id: 'loc1',
    name: 'Test Location',
    description: 'A test location for climbing.',
    address: '123 Test St',
    createdAt: DateTime(2023, 1, 1),
    images: [],
  );

  testWidgets('renders in add mode', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Add New Location'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Create'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Update'), findsNothing);
  });

  testWidgets('renders in edit mode', (tester) async {
    await tester.pumpWidget(createTestWidget(location: testLocation));
    expect(find.text('Edit Location'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Update'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Create'), findsNothing);
  });

  testWidgets('shows validation errors for empty fields', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();
    expect(find.text('Location name is required'), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
    expect(find.text('Address is required'), findsOneWidget);
  });

  testWidgets('shows validation errors for short fields', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.enterText(find.byType(TextFormField).at(0), 'A');
    await tester.enterText(find.byType(TextFormField).at(1), 'Short');
    await tester.enterText(find.byType(TextFormField).at(2), '123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();
    expect(find.textContaining('at least 2 characters'), findsOneWidget);
    expect(find.textContaining('at least 10 characters'), findsOneWidget);
    expect(find.textContaining('at least 5 characters'), findsOneWidget);
  });

  testWidgets('calls createLocation and closes dialog on valid add', (tester) async {
    when(mockLocationProvider.createLocation(
      name: anyNamed('name'),
      description: anyNamed('description'),
      address: anyNamed('address'),
      imageFiles: anyNamed('imageFiles'),
      webImageBytes: anyNamed('webImageBytes'),
      webImageName: anyNamed('webImageName'),
    )).thenAnswer((_) async => Future.value());
    await tester.pumpWidget(createTestWidget());
    await tester.enterText(find.byType(TextFormField).at(0), 'New Location');
    await tester.enterText(find.byType(TextFormField).at(1), 'A great place to climb rocks.');
    await tester.enterText(find.byType(TextFormField).at(2), '456 Climb Ave');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();
    verify(mockLocationProvider.createLocation(
      name: 'New Location',
      description: 'A great place to climb rocks.',
      address: '456 Climb Ave',
      imageFiles: null,
      webImageBytes: null,
      webImageName: null,
    )).called(1);
    expect(find.byType(LocationFormDialog), findsNothing);
  });

  testWidgets('calls updateLocation and closes dialog on valid edit', (tester) async {
    when(mockLocationProvider.updateLocation(
      any,
      any,
      imageFile: anyNamed('imageFile'),
      webImageBytes: anyNamed('webImageBytes'),
      webImageName: anyNamed('webImageName'),
      existingImages: anyNamed('existingImages'),
    )).thenAnswer((_) async => Future.value());
    await tester.pumpWidget(createTestWidget(location: testLocation));
    await tester.enterText(find.byType(TextFormField).at(0), 'Updated Location');
    await tester.enterText(find.byType(TextFormField).at(1), 'A much better description for the location.');
    await tester.enterText(find.byType(TextFormField).at(2), '789 New Address');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Update'));
    await tester.pumpAndSettle();
    verify(mockLocationProvider.updateLocation(
      'loc1',
      {
        'name': 'Updated Location',
        'description': 'A much better description for the location.',
        'address': '789 New Address',
      },
      imageFile: null,
      webImageBytes: null,
      webImageName: null,
      existingImages: [],
    )).called(1);
    expect(find.byType(LocationFormDialog), findsNothing);
  });

  testWidgets('shows snackbar on createLocation failure', (tester) async {
    when(mockLocationProvider.createLocation(
      name: anyNamed('name'),
      description: anyNamed('description'),
      address: anyNamed('address'),
      imageFiles: anyNamed('imageFiles'),
      webImageBytes: anyNamed('webImageBytes'),
      webImageName: anyNamed('webImageName'),
    )).thenThrow(Exception('fail'));
    await tester.pumpWidget(createTestWidget());
    await tester.enterText(find.byType(TextFormField).at(0), 'New Location');
    await tester.enterText(find.byType(TextFormField).at(1), 'A great place to climb rocks.');
    await tester.enterText(find.byType(TextFormField).at(2), '456 Climb Ave');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Failed to save location'), findsOneWidget);
    expect(find.byType(LocationFormDialog), findsOneWidget);
  });

  testWidgets('cancel button closes dialog', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(LocationFormDialog), findsNothing);
  });
}
