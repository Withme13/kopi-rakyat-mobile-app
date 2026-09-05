import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kopi_rakyat_app/main.dart';

void main() {
  testWidgets('shows a setup prompt when Supabase env vars are missing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KopiRakyatApp()));

    expect(find.textContaining('Supabase belum dikonfigurasi'), findsOneWidget);
  });
}
