extension StringExtension on String {
  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
