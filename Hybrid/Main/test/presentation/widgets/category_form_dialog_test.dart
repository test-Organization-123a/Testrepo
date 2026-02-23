import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:prototype/data/models/category.dart';
import 'package:prototype/presentation/state/category_provider.dart';
import 'package:prototype/presentation/widgets/form_dialogs/category_form_dialog.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockCategoryProvider mockCategoryProvider;

  setUp(() {
    mockCategoryProvider = MockCategoryProvider();
  });

  Widget createTestWidget({Category? category}) {
    return ChangeNotifierProvider<CategoryProvider>.value(
      value: mockCategoryProvider,
      child: MaterialApp(
        home: Scaffold(
          body: CategoryFormDialog(existingCategory: category),
        ),
      ),
    );
  }

  final testCategory = Category(id: '1', name: 'Existing Category', description: 'Existing Description');

  group('CategoryFormDialog in Create Mode', () {
    testWidgets('renders correctly with "Add New Category" title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Add New Category'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, ''), findsNWidgets(2));
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Category name is required'), findsOneWidget);
      expect(find.text('Description is required'), findsOneWidget);
      verifyNever(mockCategoryProvider.addCategory(any, any));
    });

    testWidgets('shows validation errors for short input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.enterText(find.byType(TextFormField).last, 'Short');
      
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
      expect(find.text('Description must be at least 10 characters'), findsOneWidget);
      verifyNever(mockCategoryProvider.addCategory(any, any));
    });

    testWidgets('calls addCategory and pops on valid submission', (tester) async {
      when(mockCategoryProvider.addCategory(any, any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'New Category');
      await tester.enterText(find.byType(TextFormField).last, 'A valid description');

      await tester.tap(find.text('Create'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      verify(mockCategoryProvider.addCategory('New Category', 'A valid description')).called(1);
      expect(find.byType(CategoryFormDialog), findsNothing);
    });

    testWidgets('shows snackbar on addCategory failure', (tester) async {
      when(mockCategoryProvider.addCategory(any, any)).thenThrow(Exception('Failed to add'));

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'New Category');
      await tester.enterText(find.byType(TextFormField).last, 'A valid description');

      await tester.tap(find.text('Create'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to save category: Exception: Failed to add'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CategoryFormDialog), findsOneWidget);
    });
  });

  group('CategoryFormDialog in Edit Mode', () {
    testWidgets('renders correctly with "Edit Category" title and pre-filled data', (tester) async {
      await tester.pumpWidget(createTestWidget(category: testCategory));

      expect(find.text('Edit Category'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Existing Category'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Existing Description'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('calls updateCategory and pops on valid submission', (tester) async {
      when(mockCategoryProvider.updateCategory(any, any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpWidget(createTestWidget(category: testCategory));

      await tester.enterText(find.byType(TextFormField).first, 'Updated Category');
      await tester.enterText(find.byType(TextFormField).last, 'An updated description');

      await tester.tap(find.text('Update'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      final expectedUpdate = {
        'name': 'Updated Category',
        'description': 'An updated description',
      };
      verify(mockCategoryProvider.updateCategory(testCategory.id, expectedUpdate)).called(1);
      expect(find.byType(CategoryFormDialog), findsNothing); // Dialog should be popped
    });
  });
}
