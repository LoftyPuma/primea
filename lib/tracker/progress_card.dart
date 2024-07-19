import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final double winRate;
  final String title;

  const ProgressCard({
    super.key,
    required this.winRate,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox.square(
        dimension: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  value: winRate,
                  strokeWidth: 16,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    winRate > 0.5 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                  text: '${(winRate * 100).toStringAsFixed(0)}%\n',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                TextSpan(
                  text: title,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
