enum Augmentation {
  none,
  echo,
  artigraph,
}

extension AugmentationExtension on Augmentation {
  String? get value {
    switch (this) {
      case Augmentation.none:
        return null;
      case Augmentation.echo:
        return 'Echo';
      case Augmentation.artigraph:
        return 'Artigraph';
    }
  }

  static Augmentation fromString(String? augmentLabel) {
    switch (augmentLabel) {
      case null:
      case '':
        return Augmentation.none;
      case 'echo':
        return Augmentation.echo;
      case 'artigraph':
        return Augmentation.artigraph;
      default:
        throw Exception('Unknown Augmentation: $augmentLabel');
    }
  }
}
