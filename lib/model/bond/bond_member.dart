import 'package:primea/model/bond/bond_status.dart';

class BondMember {
  final int bondId;
  final String? sponsorId;
  final DateTime dateInitiated;
  final DateTime? dateJoined;
  final BondStatus status;

  BondMember({
    required this.bondId,
    required this.sponsorId,
    required this.dateInitiated,
    required this.dateJoined,
    required this.status,
  });

  BondMember.fromJson(Map<String, dynamic> json)
      : bondId = json['bond'],
        sponsorId = json['sponsor'],
        dateInitiated = DateTime.parse(json['date_initiated']),
        dateJoined = json['date_joined'] == null
            ? null
            : DateTime.parse(json['date_joined']),
        status = BondStatus.values.byName(json['status']);
}
