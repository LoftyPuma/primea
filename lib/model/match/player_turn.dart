enum PlayerTurn {
  going1st(value: true),
  going2nd(value: false);

  final bool value;

  const PlayerTurn({required this.value});
}
