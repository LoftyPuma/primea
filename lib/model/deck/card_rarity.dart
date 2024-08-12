enum CardRarity {
  common,
  uncommon,
  rare,
  legendary,
  prime;

  String get title {
    switch (this) {
      case CardRarity.common:
        return 'Common';
      case CardRarity.uncommon:
        return 'Uncommon';
      case CardRarity.rare:
        return 'Rare';
      case CardRarity.legendary:
        return 'Legendary';
      case CardRarity.prime:
        return 'Prime';
    }
  }
}
