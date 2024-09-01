import 'package:primea/tracker/paragon.dart';

class Season extends Object {
  final int id;
  final String name;
  final String title;
  final ParallelType parallel;
  final DateTime startDate;
  final DateTime endDate;

  Season({
    required this.id,
    required this.name,
    required this.title,
    required this.parallel,
    required this.startDate,
    required this.endDate,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      parallel: ParallelType.values.byName(json['parallel']),
      startDate: DateTime.parse(json['season_start'] + "z"),
      endDate: DateTime.parse(json['season_end'] + "z"),
    );
  }

  @override
  operator ==(Object other) {
    return other is Season &&
        other.id == id &&
        other.name == name &&
        other.title == title &&
        other.parallel == parallel &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  bool get isCurrent {
    final now = DateTime.now().toUtc();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        title,
        parallel,
        startDate,
        endDate,
      );

  @override
  String toString() {
    return 'Season{id: $id, name: $name, title: $title, parallel: $parallel, startDate: $startDate, endDate: $endDate}';
  }
}
