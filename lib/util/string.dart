extension StringExtension on String {
  String toTitleCase({String delimiter = ' '}) {
    return split(delimiter).map((word) => word.capitalize()).join(' ');
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
