import 'package:flutter/material.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final bool switchable;

  const BaseCard({
    super.key,
    required this.child,
    required this.height,
    required this.width,
    this.switchable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // color: switchable ? Theme.of(context).colorScheme.onSurface : null,
        gradient: switchable
            ? const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topLeft,
                colors: [
                  Color(0xffff7c22),
                  Color(0xFFDEF141),
                ],
              )
            : null,
      ),
      child: Badge(
        isLabelVisible: switchable,
        label: Icon(
          Icons.arrow_outward,
          size: 20,
          color: Theme.of(context).colorScheme.onError,
        ),
        largeSize: 28,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor:
              switchable ? Theme.of(context).colorScheme.onSurface : null,
          child: SizedBox(
            height: height,
            width: width,
            child: Center(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
