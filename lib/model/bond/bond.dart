import 'package:primea/main.dart';

class Bond {
  static const bondTable = 'bonds';
  static const bondMemberTable = 'bond_members';

  final int id;
  final String name;
  final DateTime createdAt;
  final String createdBy;

  const Bond({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
  });

  static Future<Iterable<Bond>> fetchAll() async {
    final bondsJson =
        await supabase.from(bondMemberTable).select('bond,$bondTable(id)');
    // TODO: Implement fetchAll
    print("bonds $bondsJson");
    return [];
  }
}
