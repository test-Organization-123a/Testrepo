import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prototype/presentation/state/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:prototype/data/models/product.dart';
import 'package:prototype/presentation/screens/admin_screens/admin_products_screen.dart';
import 'package:prototype/presentation/state/product_provider.dart';
import 'package:prototype/presentation/state/category_provider.dart';
import 'package:prototype/presentation/widgets/admin_cards/admin_product_card.dart';
import 'package:prototype/presentation/widgets/form_dialogs/product_form_dialog.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockProductProvider mockProductProvider;
  late MockCategoryProvider mockCategoryProvider;
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockProductProvider = MockProductProvider();
    mockCategoryProvider = MockCategoryProvider();
    mockAuthProvider = MockAuthProvider();
    when(mockCategoryProvider.categories).thenReturn([]);
    when(mockCategoryProvider.isLoading).thenReturn(false);
    when(mockCategoryProvider.loadCategories()).thenAnswer((_) async => Future.value());
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductProvider>.value(value: mockProductProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<CategoryProvider>.value(value: mockCategoryProvider),
      ],
      child: const MaterialApp(
        home: AdminProductsScreen(),
      ),
    );
  }

  final testProducts = [
    Product(id: 'prod1', name: 'Product 1', price: 10, stock: 5, description: 'desc', categoryId: 'cat1', imageUrls: ['']),
    Product(id: 'prod2', name: 'Product 2', price: 20, stock: 10, description: 'desc', categoryId: 'cat2', imageUrls: ['']),
  ];

  testWidgets('displays loading indicator when loading', (tester) async {
    when(mockProductProvider.isLoading).thenReturn(true);
    when(mockProductProvider.products).thenReturn([]);
    when(mockProductProvider.error).thenReturn(null);
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays error message when there is an error', (tester) async {
    when(mockProductProvider.isLoading).thenReturn(false);
    when(mockProductProvider.products).thenReturn([]);
    when(mockProductProvider.error).thenReturn('Failed to load');
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('Error: Failed to load'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('displays no products message when list is empty', (tester) async {
    when(mockProductProvider.isLoading).thenReturn(false);
    when(mockProductProvider.products).thenReturn([]);
    when(mockProductProvider.error).thenReturn(null);
    when(mockProductProvider.loadProducts()).thenAnswer((_) async => Future.value());
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('No products yet'), findsOneWidget);
  });

  testWidgets('displays list of products', (tester) async {
    when(mockProductProvider.isLoading).thenReturn(false);
    when(mockProductProvider.products).thenReturn(testProducts);
    when(mockProductProvider.error).thenReturn(null);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.byType(AdminProductCard), findsNWidgets(2));
    expect(find.text('Product 1'), findsOneWidget);
    expect(find.text('Product 2'), findsOneWidget);
  });

  testWidgets('opens add product dialog on add butotn tap', (tester) async {
    when(mockProductProvider.isLoading).thenReturn(false);
    when(mockProductProvider.products).thenReturn([]);
    when(mockProductProvider.error).thenReturn(null);
    when(mockCategoryProvider.categories).thenReturn([]);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(ProductFormDialog), findsOneWidget);
  });

  testWidgets('opens edit product dialog on edit tap', (tester) async {
    when(mockProductProvider.isLoading).thenReturn(false);
    when(mockProductProvider.products).thenReturn(testProducts);
    when(mockProductProvider.error).thenReturn(null);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();
    expect(find.byType(ProductFormDialog), findsOneWidget);
  });

  testWidgets('shows delete confirmation dialog on delete tap', (tester) async {
    when(mockProductProvider.isLoading).thenReturn(false);
    when(mockProductProvider.products).thenReturn(testProducts);
    when(mockProductProvider.error).thenReturn(null);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
    expect(find.text('Delete Product'), findsOneWidget);
    expect(find.textContaining('Are you sure you want to delete'), findsOneWidget);
  });

  testWidgets('deletes product on confirmation', (tester) async {
    when(mockProductProvider.isLoading).thenReturn(false);
    when(mockProductProvider.products).thenReturn(testProducts);
    when(mockProductProvider.error).thenReturn(null);
    when(mockProductProvider.deleteProduct('prod1')).thenAnswer((_) async => Future.value());
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    verify(mockProductProvider.deleteProduct('prod1')).called(1);
  });
}
