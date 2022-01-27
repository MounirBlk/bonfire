import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

abstract class LightingInterface {
  Color? color;
  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  });
}

/// Layer component responsible for adding lighting to the game.
class LightingComponent extends GameComponent implements LightingInterface {
  Color? color;
  late Paint _paintFocus;
  Paint _paintLighting = Paint();
  Iterable<Lighting> _visibleLight = [];
  double _dtUpdate = 0.0;
  ColorTween? _tween;
  bool _containColor = false;

  @override
  PositionType get positionType => PositionType.viewport;

  LightingComponent({this.color}) {
    _paintFocus = Paint()..blendMode = BlendMode.clear;
  }

  @override
  int get priority {
    return LayerPriority.getLightingPriority(gameRef.highestPriority);
  }

  Path getWheelPath(double wheelSize, double fromRadius, double toRadius) {
    return new Path()
      ..moveTo(wheelSize, wheelSize)
      ..arcTo(
        Rect.fromCircle(
          radius: wheelSize,
          center: Offset(wheelSize, wheelSize),
        ),
        fromRadius,
        toRadius,
        false,
      )
      ..close();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!_containColor) return;
    Vector2 size = gameRef.camera.canvasSize;
    canvas.saveLayer(Offset.zero & Size(size.x, size.y), Paint());
    canvas.drawColor(color!, BlendMode.dstATop);
    _visibleLight.forEach((light) {
      final config = light.lightingConfig;
      if (config == null) return;
      config.update(_dtUpdate);
      canvas.save();

      canvas.scale(gameRef.camera.zoom);
      canvas.translate(
        -(gameRef.camera.position.x),
        -(gameRef.camera.position.y),
      );

      double nbElem = 6;
      double endRadius = (2 * pi) / nbElem;
      double startRadius = 0;
      canvas.drawPath(
        Path()
          ..moveTo(light.center.x, light.center.y)
          ..arcTo(
            Rect.fromCircle(
              radius: config.radius * 2,
              center: Offset(
                light.center.x,
                light.center.y,
              ),
            ),
            startRadius,
            endRadius,
            false,
          )
          ..close(),
        _paintFocus
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            5,
          ),
      );
      // canvas.drawCircle(
      //   Offset(
      //     light.center.x,
      //     light.center.y,
      //   ),
      //   config.radius *
      //       (config.withPulse
      //           ? (1 - config.valuePulse * config.pulseVariation)
      //           : 1),
      //   _paintFocus
      //     ..maskFilter = MaskFilter.blur(
      //       BlurStyle.normal,
      //       config.blurSigma,
      //     ),
      // );

      // _paintLighting
      //   ..color = config.color
      //   ..maskFilter = MaskFilter.blur(
      //     BlurStyle.normal,
      //     config.blurSigma,
      //   );
      // canvas.drawCircle(
      //   light.center.toOffset(),
      //   config.radius *
      //       (config.withPulse
      //           ? (1 - config.valuePulse * config.pulseVariation)
      //           : 1),
      //   _paintLighting,
      // );

      canvas.restore();
    });
    canvas.restore();
  }

  @override
  // ignore: must_call_super
  void update(double dt) {
    _containColor = _containsColor();
    if (!_containColor) return;
    _dtUpdate = dt;
    _visibleLight = gameRef.visibleLighting();
  }

  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  }) {
    _tween = ColorTween(
      begin: this.color ?? Color(0x00000000),
      end: color,
    );

    gameRef.getValueGenerator(
      duration,
      onChange: (value) {
        this.color = _tween?.transform(value);
      },
      onFinish: () {
        this.color = color;
      },
      curve: curve,
    ).start();
  }

  bool _containsColor() {
    return color != null && color != Color(0x00000000);
  }
}
