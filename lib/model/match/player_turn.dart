enum PlayerTurn {
  onThePlay(value: true),
  onTheDraw(value: false);

  final bool value;

  const PlayerTurn({required this.value});
}
