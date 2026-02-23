import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:prototype/data/models/category.dart';
import 'package:prototype/presentation/screens/admin_screens/admin_categories_screen.dart';
import 'package:prototype/presentation/state/auth_provider.dart';
import 'package:prototype/presentation/state/category_provider.dart';
import 'package:prototype/presentation/widgets/admin_cards/admin_category_card.dart';
import 'package:prototype/presentation/widgets/form_dialogs/category_form_dialog.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockCategoryProvider mockCategoryProvider;
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockCategoryProvider = MockCategoryProvider();
    mockAuthProvider = MockAuthProvider();
    when(mockAuthProvider.isAuthenticated).thenReturn(true);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CategoryProvider>.value(
          value: mockCategoryProvider,
        ),
        ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
        ),
      ],
      child: const MaterialApp(
        home: AdminCategoriesScreen(),
      ),
    );
  }

  final testCategories = [
    Category(id: '1', name: 'Category 1', description: 'Description 1'),
    Category(id: '2', name: 'Category 2', description: 'Description 2'),
  ];

  testWidgets('displays loading indicator when loading', (tester) async {
    when(mockCategoryProvider.isLoading).thenReturn(true);
    when(mockCategoryProvider.categories).thenReturn([]);
    when(mockCategoryProvider.error).thenReturn(null);

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays error message when there is an error', (tester) async {
    when(mockCategoryProvider.isLoading).thenReturn(false);
    when(mockCategoryProvider.categories).thenReturn([]);
    when(mockCategoryProvider.error).thenReturn('Failed to load');

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Error: Failed to load'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('displays no categories message when list is empty', (tester) async {
    when(mockCategoryProvider.isLoading).thenReturn(false);
    when(mockCategoryProvider.categories).thenReturn([]);
    when(mockCategoryProvider.error).thenReturn(null);
    when(mockCategoryProvider.loadCategories()).thenAnswer((_) async => {});

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('No categories yet'), findsOneWidget);
  });

  testWidgets('displays list of categories', (tester) async {
    when(mockCategoryProvider.isLoading).thenReturn(false);
    when(mockCategoryProvider.categories).thenReturn(testCategories);
    when(mockCategoryProvider.error).thenReturn(null);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(AdminCategoryCard), findsNWidgets(2));
    expect(find.text('Category 1'), findsOneWidget);
    expect(find.text('Category 2'), findsOneWidget);
  });

  testWidgets('opens add category dialog on FAB tap', (tester) async {
    when(mockCategoryProvider.isLoading).thenReturn(false);
    when(mockCategoryProvider.categories).thenReturn([]);
    when(mockCategoryProvider.error).thenReturn(null);
    when(mockCategoryProvider.loadCategories()).thenAnswer((_) async => {});

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(CategoryFormDialog), findsOneWidget);
  });

  testWidgets('opens edit category dialog on edit tap', (tester) async {
    when(mockCategoryProvider.isLoading).thenReturn(false);
    when(mockCategoryProvider.categories).thenReturn(testCategories);
    when(mockCategoryProvider.error).thenReturn(null);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    expect(find.byType(CategoryFormDialog), findsOneWidget);
  });

  testWidgets('shows delete confirmation dialog on delete tap', (tester) async {
    when(mockCategoryProvider.isLoading).thenReturn(false);
    when(mockCategoryProvider.categories).thenReturn(testCategories);
    when(mockCategoryProvider.error).thenReturn(null);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Category'), findsOneWidget);
    expect(find.text('Are you sure you want to delete "Category 1"? This action cannot be undone and will affect all products in this category.'), findsOneWidget);
  });

  testWidgets('deletes category on confirmation', (tester) async {
    when(mockCategoryProvider.isLoading).thenReturn(false);
    when(mockCategoryProvider.categories).thenReturn(testCategories);
    when(mockCategoryProvider.error).thenReturn(null);
    when(mockCategoryProvider.deleteCategory('1')).thenAnswer((_) async => {});

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(mockCategoryProvider.deleteCategory('1')).called(1);
  });
}
