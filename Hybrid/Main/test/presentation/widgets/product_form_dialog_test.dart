import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:prototype/data/models/product.dart';
import 'package:prototype/data/models/category.dart';
import 'package:prototype/presentation/widgets/form_dialogs/product_form_dialog.dart';
import 'package:prototype/presentation/state/product_provider.dart';
import 'package:prototype/presentation/state/category_provider.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockProductProvider mockProductProvider;
  late MockCategoryProvider mockCategoryProvider;

  setUp(() {
    mockProductProvider = MockProductProvider();
    mockCategoryProvider = MockCategoryProvider();
    when(mockCategoryProvider.categories).thenReturn([
      Category(id: 'cat1', name: 'Cat 1', description: ''),
      Category(id: 'cat2', name: 'Cat 2', description: ''),
    ]);
    when(mockCategoryProvider.isLoading).thenReturn(false);
    when(
      mockCategoryProvider.loadCategories(),
    ).thenAnswer((_) async => Future.value());
  });

  Widget createTestWidget({Product? product}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductProvider>.value(
          value: mockProductProvider,
        ),
        ChangeNotifierProvider<CategoryProvider>.value(
          value: mockCategoryProvider,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ProductFormDialog(existingProduct: product),
          ),
        ),
      ),
    );
  }

  final testProduct = Product(
    id: 'prod1',
    name: 'Product 1',
    price: 10,
    stock: 5,
    description: 'desc',
    categoryId: 'cat1',
    imageUrls: [''],
  );

  testWidgets('renders in add mode', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Add Product'), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Add Product'), findsOneWidget);
    expect(find.text('Save Changes'), findsNothing);
  });

  testWidgets('renders in edit mode', (tester) async {
    await tester.pumpWidget(createTestWidget(product: testProduct));
    expect(find.text('Edit Product'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('shows validation errors for empty fields', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
    await tester.pumpAndSettle();
    expect(find.text('Enter product name'), findsOneWidget);
    expect(find.text('Enter valid price'), findsOneWidget);
    expect(find.text('Enter valid stock'), findsOneWidget);
    expect(find.text('Please select a category'), findsOneWidget);
    verifyNever(
      mockProductProvider.createProduct(
        name: anyNamed('name'),
        description: anyNamed('description'),
        price: anyNamed('price'),
        stock: anyNamed('stock'),
        categoryId: anyNamed('categoryId'),
        images: anyNamed('images'),
        webImageBytes: anyNamed('webImageBytes'),
        webImageName: anyNamed('webImageName'),
      ),
    );
  });

  testWidgets('calls createProduct and closes dialog on valid add', (
    tester,
  ) async {
    when(
      mockProductProvider.createProduct(
        name: anyNamed('name'),
        description: anyNamed('description'),
        price: anyNamed('price'),
        stock: anyNamed('stock'),
        categoryId: anyNamed('categoryId'),
        images: anyNamed('images'),
        webImageBytes: anyNamed('webImageBytes'),
        webImageName: anyNamed('webImageName'),
      ),
    ).thenAnswer((_) async => Future.value());
    await tester.pumpWidget(createTestWidget());
    await tester.enterText(find.byType(TextFormField).at(0), 'New Product');
    await tester.enterText(find.byType(TextFormField).at(1), 'A description');
    await tester.enterText(find.byType(TextFormField).at(2), '12.5');
    await tester.enterText(find.byType(TextFormField).at(3), '7');
    final dropdown = find.byType(DropdownButtonFormField<String>);
    final dynamic dropdownState = tester.state(dropdown);
    dropdownState.didChange('cat1');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
    await tester.pumpAndSettle();
    verify(
      mockProductProvider.createProduct(
        name: 'New Product',
        description: 'A description',
        price: 12.5,
        stock: 7,
        categoryId: 'cat1',
        images: null,
        webImageBytes: null,
        webImageName: null,
      ),
    ).called(1);
    expect(find.byType(ProductFormDialog), findsNothing);
  });

  testWidgets('calls updateProduct and closes dialog on valid edit', (
    tester,
  ) async {
    when(
      mockProductProvider.updateProduct(
        id: anyNamed('id'),
        name: anyNamed('name'),
        description: anyNamed('description'),
        price: anyNamed('price'),
        stock: anyNamed('stock'),
        categoryId: anyNamed('categoryId'),
        images: anyNamed('images'),
        webImageBytes: anyNamed('webImageBytes'),
        webImageName: anyNamed('webImageName'),
        existingImages: anyNamed('existingImages'),
      ),
    ).thenAnswer((_) async => Future.value());
    await tester.pumpWidget(createTestWidget(product: testProduct));
    await tester.enterText(find.byType(TextFormField).at(0), 'Updated Product');
    await tester.enterText(find.byType(TextFormField).at(1), 'Updated desc');
    await tester.enterText(find.byType(TextFormField).at(2), '15');
    await tester.enterText(find.byType(TextFormField).at(3), '9');
    final dropdown = find.byType(DropdownButtonFormField<String>);
    final dynamic dropdownState = tester.state(dropdown);
    dropdownState.didChange('cat2');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    verify(
      mockProductProvider.updateProduct(
        id: 'prod1',
        name: 'Updated Product',
        description: 'Updated desc',
        price: 15.0,
        stock: 9,
        categoryId: 'cat2',
        images: null,
        webImageBytes: null,
        webImageName: null,
        existingImages: [''],
      ),
    ).called(1);
    expect(find.byType(ProductFormDialog), findsNothing);
  });

  testWidgets('shows snackbar on createProduct failure', (tester) async {
    when(
      mockProductProvider.createProduct(
        name: anyNamed('name'),
        description: anyNamed('description'),
        price: anyNamed('price'),
        stock: anyNamed('stock'),
        categoryId: anyNamed('categoryId'),
        images: anyNamed('images'),
        webImageBytes: anyNamed('webImageBytes'),
        webImageName: anyNamed('webImageName'),
      ),
    ).thenThrow(Exception('fail'));
    await tester.pumpWidget(createTestWidget());
    await tester.enterText(find.byType(TextFormField).at(0), 'New Product');
    await tester.enterText(find.byType(TextFormField).at(1), 'A description');
    await tester.enterText(find.byType(TextFormField).at(2), '12.5');
    await tester.enterText(find.byType(TextFormField).at(3), '7');
    final dropdown = find.byType(DropdownButtonFormField<String>);
    final dynamic dropdownState = tester.state(dropdown);
    dropdownState.didChange('cat1');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('Failed to save product: Exception: fail'),
      findsOneWidget,
    );
    expect(find.byType(ProductFormDialog), findsOneWidget);
  });

  testWidgets('cancel button closes dialog', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductFormDialog), findsNothing);
  });
}
