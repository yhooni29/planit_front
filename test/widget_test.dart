
import 'package:flutter_test/flutter_test.dart';
import 'package:meetsync/main.dart';

void main() {
  testWidgets('PlanIt 앱 실행 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(const MeetSyncApp());

    expect(find.text('로그인'), findsWidgets);
  });
}
