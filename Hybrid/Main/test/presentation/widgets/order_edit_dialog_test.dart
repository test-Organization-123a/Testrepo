import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:prototype/data/models/order.dart';
import 'package:prototype/presentation/widgets/form_dialogs/order_edit_dialog.dart';
import 'package:prototype/presentation/state/order_provider.dart';
import 'package:prototype/presentation/state/product_provider.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockOrderProvider mockOrderProvider;
  late MockProductProvider mockProductProvider;

  setUp(() {
    mockOrderProvider = MockOrderProvider();
    mockProductProvider = MockProductProvider();
    when(mockProductProvider.products).thenReturn([]);
    when(mockProductProvider.loadProducts()).thenAnswer((_) async => Future.value());
  });

  Widget createTestWidget(Order order) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
        ChangeNotifierProvider<ProductProvider>.value(value: mockProductProvider),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => OrderEditDialog(order: order),
          ),
        ),
      ),
    );
  }


  final testOrder = Order(
    id: '123e4567-order1',
    customerId: 'customer1',
    createdAt: DateTime.now(),
    items: [
      OrderItem(
        id: 'item1',
        orderId: '123e4567-order1',
        productId: 'prod1',
        quantity: 2,
        product: null,
      ),
    ],
  );

  testWidgets('renders with order data', (tester) async {
    await tester.pumpWidget(createTestWidget(testOrder));
    expect(find.textContaining('Edit Order #123e4567'), findsOneWidget);
    expect(find.text('Test Product'), findsNothing);
    expect(find.text('Unknown Product'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('shows empty state if no items', (tester) async {
    final emptyOrder = Order(
      id: '123e4567-order2',
      customerId: 'customer2',
      createdAt: DateTime.now(),
      items: [],
    );
    await tester.pumpWidget(createTestWidget(emptyOrder));
    expect(find.text('No items in this order'), findsOneWidget);
  });

  testWidgets('increments and decrements quantity', (tester) async {
    await tester.pumpWidget(createTestWidget(testOrder));
    await tester.pumpAndSettle();
    final addBtn = find.widgetWithIcon(IconButton, Icons.add);
    final removeBtn = find.widgetWithIcon(IconButton, Icons.remove);
    expect(removeBtn, findsOneWidget);
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    await tester.tap(removeBtn);
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('removes item from order', (tester) async {
    await tester.pumpWidget(createTestWidget(testOrder));
    await tester.pumpAndSettle();
    final deleteBtn = find.widgetWithIcon(IconButton, Icons.delete).last;
    await tester.tap(deleteBtn);
    await tester.pump();
    expect(find.text('Unknown Product'), findsNothing);
    expect(find.text('No items in this order'), findsOneWidget);
  });

  testWidgets('shows validation error for invalid quantity', (tester) async {
    await tester.pumpWidget(createTestWidget(testOrder));
    await tester.pumpAndSettle();
    final qtyField = find.byType(TextFormField).first;
    await tester.enterText(qtyField, '0');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid'), findsOneWidget);
    verifyNever(mockOrderProvider.updateOrder(any, any));
  });

  testWidgets('calls updateOrder and closes dialog on save', (tester) async {
    when(mockOrderProvider.updateOrder(any, any)).thenAnswer((_) async => Future.value());
    await tester.pumpWidget(createTestWidget(testOrder));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '5');
    await tester.tap(find.text('Save Changes'));
    await tester.pump();
    await tester.pumpAndSettle();
    verify(mockOrderProvider.updateOrder('123e4567-order1', [{'productId': 'prod1', 'quantity': 5}])).called(1);
    expect(find.byType(OrderEditDialog), findsNothing);
  });

  testWidgets('cancel button closes dialog', (tester) async {
    await tester.pumpWidget(createTestWidget(testOrder));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(OrderEditDialog), findsNothing);
  });
}
