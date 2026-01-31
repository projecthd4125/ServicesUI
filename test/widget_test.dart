import 'package:flutter_test/flutter_test.dart';
import 'package:myservice_ui_prj/main.dart';

void main() {
  testWidgets('App starts with login screen', (WidgetTester tester) async {
    // Pump the MyServiceApp widget
    await tester.pumpWidget(const MyServiceApp());
    
    // Verify the login screen appears
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
