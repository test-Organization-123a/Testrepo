import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:prototype/data/models/order.dart';
import 'package:prototype/presentation/screens/admin_screens/admin_orders_screen.dart';
import 'package:prototype/presentation/state/order_provider.dart';
import 'package:prototype/presentation/state/auth_provider.dart';
import 'package:prototype/presentation/widgets/admin_cards/admin_order_card.dart';
import 'package:prototype/presentation/widgets/form_dialogs/order_edit_dialog.dart';
import 'package:prototype/presentation/state/product_provider.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockOrderProvider mockOrderProvider;
  late MockAuthProvider mockAuthProvider;
  late MockProductProvider mockProductProvider;

  setUp(() {
    mockOrderProvider = MockOrderProvider();
    mockAuthProvider = MockAuthProvider();
    mockProductProvider = MockProductProvider();
    when(mockAuthProvider.isAuthenticated).thenReturn(true);
    when(mockProductProvider.products).thenReturn([]);
    when(mockProductProvider.loadProducts()).thenAnswer((_) async => Future.value());
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ProductProvider>.value(value: mockProductProvider),
      ],
      child: const MaterialApp(
        home: AdminOrdersScreen(),
      ),
    );
  }

  final testOrders = [
    Order(id: '123e4567-order1', customerId: 'customer1', createdAt: DateTime.now()),
    Order(id: '123e4567-order2', customerId: 'customer2', createdAt: DateTime.now()),
  ];

  testWidgets('displays loading indicator when loading', (tester) async {
    when(mockOrderProvider.isLoading).thenReturn(true);
    when(mockOrderProvider.orders).thenReturn([]);
    when(mockOrderProvider.error).thenReturn(null);

    await tester.pumpWidget(createTestWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays error message when there is an error', (tester) async {
    when(mockOrderProvider.isLoading).thenReturn(false);
    when(mockOrderProvider.orders).thenReturn([]);
    when(mockOrderProvider.error).thenReturn('Failed to load');

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Error: Failed to load'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('displays no orders message when list is empty', (tester) async {
    when(mockOrderProvider.isLoading).thenReturn(false);
    when(mockOrderProvider.orders).thenReturn([]);
    when(mockOrderProvider.error).thenReturn(null);
    when(mockOrderProvider.loadOrders()).thenAnswer((_) async => Future.value());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('No orders yet'), findsOneWidget);
  });

  testWidgets('displays list of orders', (tester) async {
    when(mockOrderProvider.isLoading).thenReturn(false);
    when(mockOrderProvider.orders).thenReturn(testOrders);
    when(mockOrderProvider.error).thenReturn(null);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(AdminOrderCard), findsNWidgets(2));
    expect(find.text('Order #123e4567'), findsNWidgets(2));
  });

  testWidgets('opens edit order dialog on edit tap', (tester) async {
    when(mockOrderProvider.isLoading).thenReturn(false);
    when(mockOrderProvider.orders).thenReturn(testOrders);
    when(mockOrderProvider.error).thenReturn(null);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    expect(find.byType(OrderEditDialog), findsOneWidget);
  });

  testWidgets('shows delete confirmation dialog on delete tap', (tester) async {
    when(mockOrderProvider.isLoading).thenReturn(false);
    when(mockOrderProvider.orders).thenReturn(testOrders);
    when(mockOrderProvider.error).thenReturn(null);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Order'), findsOneWidget);
    expect(find.textContaining('Are you sure you want to delete order'), findsOneWidget);
  });

  testWidgets('deletes order on confirmation', (tester) async {
    when(mockOrderProvider.isLoading).thenReturn(false);
    when(mockOrderProvider.orders).thenReturn(testOrders);
    when(mockOrderProvider.error).thenReturn(null);
  when(mockOrderProvider.deleteOrder('123e4567-order2')).thenAnswer((_) async => Future.value());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(mockOrderProvider.deleteOrder('123e4567-order2')).called(1);
  });
}
