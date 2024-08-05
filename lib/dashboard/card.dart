import 'package:flutter/material.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final bool switchable;
  final Color? primaryColor;
  final Color? secondaryColor;

  const BaseCard({
    super.key,
    required this.child,
    required this.height,
    required this.width,
    this.switchable = false,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
          Icons.swap_horiz_rounded,
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
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor?.withAlpha(150) ?? Colors.transparent,
                  secondaryColor?.withAlpha(150) ?? Colors.transparent,
                ],
              ),
            ),
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
