import 'package:flutter/material.dart';

class TurnIndicator extends StatelessWidget {
  final bool playerOne;
  final Function(bool) updatePlayerOne;

  const TurnIndicator({
    super.key,
    required this.playerOne,
    required this.updatePlayerOne,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('On the Play'),
        ),
        Tooltip(
          message: !playerOne ? 'You play first' : 'Opponent plays first',
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Switch(
              value: !playerOne,
              onChanged: (value) => updatePlayerOne,
              trackColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              thumbColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('On the Draw'),
        ),
      ],
    );
  }
}
