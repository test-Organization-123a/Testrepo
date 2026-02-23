import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/presentation/widgets/generic_page_items/admin_bottom_navigation.dart';

void main() {
  Widget createTestWidget(AdminDestination currentDestination) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: AdminBottomNavigationWidget(
          currentDestination: currentDestination,
        ),
      ),
    );
  }

  testWidgets('renders all navigation items', (tester) async {
    await tester.pumpWidget(createTestWidget(AdminDestination.products));
    
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Locations'), findsOneWidget);
  });

  testWidgets('highlights correct item for products destination', (tester) async {
    await tester.pumpWidget(createTestWidget(AdminDestination.products));
    
    final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNav.currentIndex, equals(0));
  });

  testWidgets('highlights correct item for categories destination', (tester) async {
    await tester.pumpWidget(createTestWidget(AdminDestination.categories));
    
    final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNav.currentIndex, equals(1));
  });

  testWidgets('highlights correct item for orders destination', (tester) async {
    await tester.pumpWidget(createTestWidget(AdminDestination.orders));
    
    final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNav.currentIndex, equals(2));
  });

  testWidgets('highlights correct item for locations destination', (tester) async {
    await tester.pumpWidget(createTestWidget(AdminDestination.locations));
    
    final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNav.currentIndex, equals(3));
  });

  testWidgets('tapping current item does not trigger navigation', (tester) async {
    await tester.pumpWidget(createTestWidget(AdminDestination.products));
    
    // Tap on currently selected Products tab
    await tester.tap(find.text('Products'));
    await tester.pumpAndSettle();
    
    // Should remain on the same screen
    expect(find.byType(AdminBottomNavigationWidget), findsOneWidget);
  });
}