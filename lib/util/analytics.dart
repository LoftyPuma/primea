import 'package:primea/main.dart';

class Analytics {
  static const String tableName = 'analytics';

  Analytics._();
  static final instance = Analytics._();

  Future<void> trackEvent(String name, Map<String, dynamic> properties) async {
    await supabase.from(Analytics.tableName).insert({
      'event': name,
      'data': properties,
    });
  }
}
