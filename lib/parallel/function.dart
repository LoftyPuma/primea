class CardFunction {
  int id;
  String basename;
  String title;
  String parallel;
  String rarity;
  String? functionText;
  String? flavourText;
  String? passiveAbility;
  int cost;
  int attack;
  int health;
  String cardType;
  String? subtype;
  String expansion;

  CardFunction({
    required this.id,
    required this.basename,
    required this.title,
    required this.parallel,
    required this.rarity,
    this.functionText,
    this.flavourText,
    this.passiveAbility,
    required this.cost,
    required this.attack,
    required this.health,
    required this.cardType,
    this.subtype,
    required this.expansion,
  });

  factory CardFunction.fromJson(Map<String, dynamic> json) {
    return CardFunction(
      id: json['id'],
      basename: json['basename'],
      title: json['title'],
      parallel: json['parallel'],
      rarity: json['rarity'],
      functionText: json['functionText'],
      flavourText: json['flavourText'],
      passiveAbility: json['passiveAbility'],
      cost: json['cost'],
      attack: json['attack'],
      health: json['health'],
      cardType: json['cardType'],
      subtype: json['subtype'],
      expansion: json['expansion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'basename': basename,
      'title': title,
      'parallel': parallel,
      'rarity': rarity,
      'functionText': functionText,
      'flavourText': flavourText,
      'passiveAbility': passiveAbility,
      'cost': cost,
      'attack': attack,
      'health': health,
      'cardType': cardType,
      'subtype': subtype,
      'expansion': expansion,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
