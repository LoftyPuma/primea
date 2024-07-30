import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';

class RadialOverlay extends StatefulWidget {
  final ParagonAvatar child;
  final ParallelType parallel;
  final bool isSelected;
  final Function(Paragon paragon) onTap;
  final List<ParagonAvatar> overlayChildren;
  final AnimationController controller;
  final Alignment alignment;

  const RadialOverlay({
    super.key,
    required this.controller,
    required this.parallel,
    required this.isSelected,
    required this.onTap,
    required this.overlayChildren,
    required this.child,
    required this.alignment,
  });

  @override
  State<RadialOverlay> createState() => _RadialOverlayState();
}

class _RadialOverlayState extends State<RadialOverlay> {
  late final Animation<double> _mainAnimation;
  late final Iterable<Animation<double>> _fadeAnimations;
  late final Iterable<Animation<double>> _scaleAnimations;

  bool isHovering = false;
  Timer? _hoverTimer;
  OverlayEntry? overlayEntry;

  late ParagonAvatar main;
  late List<ParagonAvatar> overlayChildren;

  late Paragon selectedParagon;

  @override
  void initState() {
    main = widget.child;
    overlayChildren = widget.overlayChildren;
    selectedParagon = widget.parallel.paragon;

    _mainAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.linear,
        reverseCurve: Curves.linear,
      ),
    );

    _fadeAnimations = Iterable.generate(widget.overlayChildren.length, (index) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: widget.controller,
          curve: Curves.easeIn,
          reverseCurve: Curves.easeIn,
        ),
      );
    });

    _scaleAnimations =
        Iterable.generate(widget.overlayChildren.length, (index) {
      return Tween<double>(
        begin: .2,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: widget.controller,
          curve: Curves.linear,
          reverseCurve: Curves.linear,
        ),
      );
    });

    super.initState();
  }

  @override
  dispose() {
    _hoverTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _animationListener(status) {
    if (status == AnimationStatus.dismissed) {
      _removeOverlay();
    }
  }

  void _handleOnHover(hovering, [delay = const Duration(milliseconds: 100)]) {
    if (!hovering) {
      _hoverTimer?.cancel();
      _hoverTimer = Timer(delay, () {
        if (isHovering) {
          widget.controller.animateBack(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInCubic,
          );
          widget.controller.addStatusListener(_animationListener);
          setState(() {
            isHovering = false;
          });
        }
      });
    } else {
      widget.controller.animateTo(
        1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
      widget.controller.removeStatusListener(_animationListener);
      if (overlayEntry == null) _addOverlay();
      setState(() {
        _hoverTimer?.cancel();
        isHovering = hovering;
      });
    }
  }

  void _handleRadialOnTap(int index) {
    setState(() {
      final tmp = main;
      main = overlayChildren.elementAt(index);
      overlayChildren[index] = tmp;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeOverlay();
  }

  void _addOverlay() {
    _removeOverlay();
    RenderBox? renderBox = context.findAncestorRenderObjectOfType<RenderBox>();
    var parentSize = renderBox!.size;
    var parentPosition = renderBox.localToGlobal(Offset.zero);

    overlayEntry = _entryBuilder(parentPosition, parentSize);
    Overlay.of(context).insert(overlayEntry!);
  }

  void _removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSelected) {
      setState(() {
        // reset the overlay to the initial state
        main = widget.child;
        overlayChildren = widget.overlayChildren;
      });
    }
    return AnimatedBuilder(
      animation: _mainAnimation,
      builder: (context, child) {
        return ScaleTransition(
          scale: _mainAnimation,
          child: InkWell(
            customBorder: const CircleBorder(),
            onHover: _handleOnHover,
            onTap: () {
              _addOverlay();

              widget.onTap(selectedParagon);
              if (widget.isSelected) {
                _handleOnHover(false, const Duration(milliseconds: 0));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.parallel.color,
                  width: widget.isSelected ? 6 : 0,
                  style:
                      widget.isSelected ? BorderStyle.solid : BorderStyle.none,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                    widget.parallel.color,
                    Colors.transparent,
                  ],
                  stops: const [
                    .1,
                    .9,
                  ],
                ),
              ),
              child: child,
            ),
          ),
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        // TODO: fix bug where deselecting a paragon doesn't change the base selection paragon
        child: main,
      ),
    );
  }

  OverlayEntry _entryBuilder(Offset parentPosition, Size parentSize) {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          clipBehavior: Clip.none,
          children: List.generate(
            overlayChildren.length,
            (index) {
              final childElement = overlayChildren.elementAt(index);
              final fadeAnimation = _fadeAnimations.elementAt(index);
              final scaleAnimation = _scaleAnimations.elementAt(index);
              final Offset offset = Offset.fromDirection(
                _degreesToRadians((180 / (widget.overlayChildren.length + 1)) *
                        (index + 1)) *
                    -widget.alignment.y,
                parentSize.width * 1.5,
              );
              return Positioned(
                left: parentPosition.dx + offset.dx,
                top: parentPosition.dy - offset.dy,
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: fadeAnimation,
                        child: ScaleTransition(
                          scale: scaleAnimation,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: isHovering
                                ? () {
                                    _handleOnHover(
                                      false,
                                      const Duration(milliseconds: 0),
                                    );
                                    _handleRadialOnTap(index);
                                    final k = child?.key as ValueKey<Paragon>;
                                    selectedParagon = k.value;
                                    widget.onTap(selectedParagon);
                                    setState(() {});
                                  }
                                : null,
                            onHover: isHovering ? _handleOnHover : null,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 1000),
                              child: SizedBox(
                                width: parentSize.width,
                                height: parentSize.height,
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: childElement,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
