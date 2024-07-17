abstract class KeyModel {
  final String name;
  double get multiplier;

  KeyModel({
    required this.name,
  });
}

enum GravityBoost {
  fifty(amount: .5),
  oneHundredAndFifty(amount: 1.5),
  threeHundred(amount: 3);

  const GravityBoost({
    required this.amount,
  });

  final double amount;
}

class GravityKey extends KeyModel {
  final GravityBoost boost;
  GravityKey(this.boost)
      : super(
          name: 'Gravity Key',
        );

  @override
  double get multiplier => boost.amount;
}

class OverclockKey extends KeyModel {
  final double amount = 0.5;
  OverclockKey()
      : super(
          name: 'Overclock Key',
        );

  @override
  double get multiplier => amount;
}

class PrismaticKey extends KeyModel {
  final double amount = 0.5;
  PrismaticKey()
      : super(
          name: 'Prismatic Key',
        );

  @override
  double get multiplier => amount;
}

class SolarKey extends KeyModel {
  final double amount = 0.4;
  SolarKey()
      : super(
          name: 'Solar Key',
        );

  @override
  double get multiplier => amount;
}

class GalaxyKey extends KeyModel {
  final double amount = 0.2;
  GalaxyKey()
      : super(
          name: 'Galaxy Key',
        );

  @override
  double get multiplier => amount;
}

class BountyCache extends KeyModel {
  final double amount = 0.3;
  BountyCache()
      : super(
          name: 'Bounty Cache',
        );

  @override
  double get multiplier => amount;
}
