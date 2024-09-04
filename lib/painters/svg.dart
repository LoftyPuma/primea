import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class SvgPainter extends CustomPainter {
  final Document document;

  SvgPainter({
    super.repaint,
    required String svg,
  }) : document = parse(svg);

  bool _isPathCommand(String segment) {
    // M/m = move to
    // L/l = line to
    // H/h = horizontal line to
    // V/v = vertical line to
    // C/c = curve to
    // S/s = smooth curve to
    // Q/q = quadratic Bézier curve
    // T/t = smooth quadratic Bézier curve to
    // A/a = elliptical arc to
    // Z/z = close path
    return "mlhvcsqtaz".contains(segment.toLowerCase());
  }

  Offset _parseOffset(String offset) {
    final coords = offset.split(',');
    return Offset(double.parse(coords[0]), double.parse(coords[1]));
  }

  Offset _reflectOffset(Offset point, Offset control) {
    final translated = control - point;
    final reflected = Offset(-translated.dx, -translated.dy);
    return reflected + point;
  }

  void _parseSvg(Canvas canvas, Paint paint, Element element) {
    switch (element.localName) {
      case 'g':
        final attrs = element.attributes;
        final transform = attrs['transform'];
        if (transform != null) {
          final transformation =
              transform.substring(0, transform.length - 1).split('(');
          switch (transformation[0]) {
            case 'translate':
              final matrix = transformation[1]
                  .split(',')
                  .map((e) => double.parse(e))
                  .toList();
              canvas.translate(matrix[0], matrix[1]);
              break;
            case 'matrix':
              break;
            default:
          }
        }
        final fill = attrs['fill'];
        if (fill != null && fill.isNotEmpty && fill[0] == '#') {
          paint.color = Color(int.parse(fill.substring(1), radix: 16));
        }
        final strokeWidth = attrs['stroke-width'];
        if (strokeWidth != null) {
          paint.strokeWidth = double.parse(strokeWidth);
        }
        for (var child in element.children) {
          _parseSvg(canvas, paint, child);
        }
        break;
      case 'path':
        final attrs = element.attributes;
        final d = attrs['d']!;
        final segments = d.split(' ');
        Paint fillPaint = Paint();
        final fill = attrs['fill'];
        if (fill != null && fill.isNotEmpty && fill[0] == '#') {
          // paint.color =
          //     Color(int.parse(fill.substring(1), radix: 16)).withAlpha(255);
          fillPaint
            ..color = const Color(0xFFFFFFFF)
            ..style = PaintingStyle.fill;
        }
        final path = Path();
        String lastCommand = '';
        Offset currentPoint = Offset.zero;
        for (var i = 0; i < segments.length; i++) {
          final command = segments[i];
          switch (command) {
            case 'M':
              final coords = _parseOffset(segments[++i]);
              path.moveTo(coords.dx, coords.dy);
              currentPoint = coords;
              while (!_isPathCommand(segments[i + 1])) {
                final coords = _parseOffset(segments[++i]);
                path.lineTo(coords.dx, coords.dy);
                currentPoint = coords;
              }
              lastCommand = command;
              break;
            case 'm':
              final coords = _parseOffset(segments[++i]);
              path.relativeMoveTo(coords.dx, coords.dy);
              currentPoint += coords;
              while (!_isPathCommand(segments[i + 1])) {
                final coords = _parseOffset(segments[++i]);
                path.relativeLineTo(coords.dx, coords.dy);
                currentPoint += coords;
              }
              lastCommand = command;
              break;
            case 'L':
              do {
                final coords = _parseOffset(segments[++i]);
                path.lineTo(coords.dx, coords.dy);
                currentPoint = coords;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'l':
              do {
                final coords = _parseOffset(segments[++i]);
                path.relativeLineTo(coords.dx, coords.dy);
                currentPoint += coords;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'H':
              do {
                final dx = double.parse(segments[++i]);
                path.lineTo(dx, currentPoint.dy);
                currentPoint = Offset(dx, currentPoint.dy);
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'h':
              do {
                final dx = double.parse(segments[++i]);
                path.relativeLineTo(dx, currentPoint.dy);
                currentPoint += Offset(dx, 0);
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'V':
              do {
                final dy = double.parse(segments[++i]);
                path.lineTo(currentPoint.dx, dy);
                currentPoint = Offset(currentPoint.dx, dy);
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'v':
              do {
                final dy = double.parse(segments[++i]);
                path.relativeLineTo(0, dy);
                currentPoint += Offset(0, dy);
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'C':
              do {
                final startControlOffset = _parseOffset(segments[++i]);
                final endControlOffset = _parseOffset(segments[++i]);
                final endOffset = _parseOffset(segments[++i]);

                path.cubicTo(
                  startControlOffset.dx,
                  startControlOffset.dy,
                  endControlOffset.dx,
                  endControlOffset.dy,
                  endOffset.dx,
                  endOffset.dy,
                );
                currentPoint = endOffset;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'c':
              do {
                final startControlOffset = _parseOffset(segments[++i]);
                final endControlOffset = _parseOffset(segments[++i]);
                final endOffset = _parseOffset(segments[++i]);

                path.relativeCubicTo(
                  startControlOffset.dx,
                  startControlOffset.dy,
                  endControlOffset.dx,
                  endControlOffset.dy,
                  endOffset.dx,
                  endOffset.dy,
                );
                currentPoint += endOffset;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'S':
              do {
                final endOffset = _parseOffset(segments[++i]);
                final endControlOffset = _parseOffset(segments[++i]);

                path.conicTo(
                  endControlOffset.dx,
                  endControlOffset.dy,
                  endOffset.dx,
                  endOffset.dy,
                  1,
                );
                currentPoint = endOffset;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 's':
              do {
                final endOffset = _parseOffset(segments[++i]);
                final endControlOffset = _parseOffset(segments[++i]);

                path.relativeConicTo(
                  endControlOffset.dx,
                  endControlOffset.dy,
                  endOffset.dx,
                  endOffset.dy,
                  1,
                );
                currentPoint += endOffset;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'Q':
              do {
                final endOffset = _parseOffset(segments[++i]);
                final endControlOffset = _parseOffset(segments[++i]);

                path.quadraticBezierTo(
                  endControlOffset.dx,
                  endControlOffset.dy,
                  endOffset.dx,
                  endOffset.dy,
                );
                currentPoint = endOffset;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'q':
              do {
                final endOffset = _parseOffset(segments[++i]);
                final endControlOffset = _parseOffset(segments[++i]);

                path.relativeQuadraticBezierTo(
                  endControlOffset.dx,
                  endControlOffset.dy,
                  endOffset.dx,
                  endOffset.dy,
                );
                currentPoint += endOffset;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'T':
              // TODO: review this implementation
              Offset controlPoint = currentPoint;
              if ("Qq".contains(lastCommand)) {
                // get the control point of the previous segment if it was a quadratic bezier curve
                controlPoint = _parseOffset(segments[i - 1]);
              }
              do {
                // continuously reflect the control point over the current point until the next segment is a new path command
                controlPoint = _reflectOffset(currentPoint, controlPoint);

                final endOffset = _parseOffset(segments[++i]);
                path.quadraticBezierTo(
                  controlPoint.dx,
                  controlPoint.dy,
                  endOffset.dx,
                  endOffset.dy,
                );
                currentPoint = endOffset;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 't':
              // TODO: review this implementation
              Offset controlPoint = currentPoint;
              if ("Qq".contains(lastCommand)) {
                // get the control point of the previous segment if it was a quadratic bezier curve
                controlPoint = _parseOffset(segments[i - 1]);
              }
              do {
                // continuously reflect the control point over the current point until the next segment is a new path command
                controlPoint = _reflectOffset(currentPoint, controlPoint);

                final endOffset = _parseOffset(segments[++i]);
                path.relativeQuadraticBezierTo(
                  controlPoint.dx,
                  controlPoint.dy,
                  endOffset.dx,
                  endOffset.dy,
                );
                currentPoint += endOffset;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'A':
              do {
                // TODO: review this implementation
                // draw an elliptical arc from the SVG command A 6 4 10 1 0 14,10
                // rx ry x-axis-rotation large-arc-flag sweep-flag x,y
                // where rx = 6, ry = 4, x-axis-rotation = 10, large-arc-flag = 1, sweep-flag = 0, x = 14, y = 10
                final double rx = double.parse(segments[++i]);
                final double ry = double.parse(segments[++i]);
                double angle = double.parse(segments[++i]);
                final bool largeArcFlag =
                    int.parse(segments[++i]) == 1 ? true : false;
                final bool sweepFlag =
                    int.parse(segments[++i]) == 1 ? true : false;
                final endOffset = _parseOffset(segments[++i]);
                // Step 3: Adjust angle based on flags
                if ((!largeArcFlag && !sweepFlag) ||
                    (largeArcFlag && sweepFlag)) {
                  angle = -angle;
                }

                // compute start and sweep angles from the current point and end point
                // Calculate start angle
                final startAngle = -atan2(
                  (currentPoint.dy - endOffset.dy) / 2 / ry,
                  (currentPoint.dx - endOffset.dx) / 2 / rx,
                );

                // Step 5: Calculate sweep angle
                var sweepAngle = angle;

                if (sweepFlag) {
                  if (sweepAngle < 0) {
                    sweepAngle += 2 * pi;
                  }
                } else {
                  if (sweepAngle > 0) {
                    sweepAngle -= 2 * pi;
                  }
                }

                path.addArc(
                  currentPoint & Size(rx, ry),
                  startAngle,
                  sweepAngle,
                );

                currentPoint = endOffset;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'a':
              do {
                // TODO: review this implementation
                // draw an elliptical arc from the SVG command A 6 4 10 1 0 14,10
                // rx ry x-axis-rotation large-arc-flag sweep-flag x,y
                // where rx = 6, ry = 4, x-axis-rotation = 10, large-arc-flag = 1, sweep-flag = 0, x = 14, y = 10
                final double rx = double.parse(segments[++i]);
                final double ry = double.parse(segments[++i]);
                double angle = double.parse(segments[++i]);
                final bool largeArcFlag =
                    int.parse(segments[++i]) == 1 ? true : false;
                final bool sweepFlag =
                    int.parse(segments[++i]) == 1 ? true : false;
                final endOffset = _parseOffset(segments[++i]) + currentPoint;
                // Step 3: Adjust angle based on flags
                if ((!largeArcFlag && !sweepFlag) ||
                    (largeArcFlag && sweepFlag)) {
                  angle = -angle;
                }

                // compute start and sweep angles from the current point and end point
                // Calculate start angle
                final startAngle = -atan2(
                  (currentPoint.dy - endOffset.dy) / 2 / ry,
                  (currentPoint.dx - endOffset.dx) / 2 / rx,
                );

                // Step 5: Calculate sweep angle
                var sweepAngle = angle;

                if (sweepFlag) {
                  if (sweepAngle < 0) {
                    sweepAngle += 2 * pi;
                  }
                } else {
                  if (sweepAngle > 0) {
                    sweepAngle -= 2 * pi;
                  }
                }

                path.addArc(
                  currentPoint & Size(rx, ry),
                  startAngle,
                  sweepAngle,
                );

                currentPoint += endOffset;
              } while (!_isPathCommand(segments[i + 1]));
              lastCommand = command;
              break;
            case 'Z':
            // fallthrough to 'z' because they are the same
            case 'z':
              path.close();
              lastCommand = command;
              break;
            default:
              throw UnimplementedError('Segment "$command" not implemented');
          }
        }
        if (fill != null) {
          canvas.drawPath(path, fillPaint);
        }
        break;
      case 'defs':
        break;
      default:
        throw UnimplementedError(
          'Element "${element.localName}" not implemented',
        );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (document.body == null ||
        document.body!.children.isEmpty ||
        document.body!.children[0].localName != 'svg') {
      return;
    }
    final svg = document.body!.children[0];
    final double width = double.parse(svg.attributes['width']!);
    final double height = double.parse(svg.attributes['height']!);
    final viewBoxLTWH = svg.attributes['viewBox']!.split(' ');

    // scale the canvas to the size of the svg
    final scaleX = size.width / width;
    final scaleY = size.height / height;
    canvas.scale(scaleX, scaleY);

    final Rect viewBox = Rect.fromLTWH(
      double.parse(viewBoxLTWH[0]),
      double.parse(viewBoxLTWH[1]),
      double.parse(viewBoxLTWH[2]),
      double.parse(viewBoxLTWH[3]),
    );

    // clip the canvas to the viewBox
    canvas.clipRect(viewBox, clipOp: ClipOp.intersect, doAntiAlias: true);

    final paint = Paint();

    for (var element in svg.children) {
      _parseSvg(canvas, paint, element);
    }
  }

  @override
  bool shouldRepaint(SvgPainter oldDelegate) {
    return oldDelegate.document != document;
  }
}
