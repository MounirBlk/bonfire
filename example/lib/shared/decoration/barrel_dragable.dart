import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/movement_v2.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

class BarrelDraggable extends GameDecoration
    with DragGesture, BlockMovementCollision, MovementV2, Pushable {
  late TextPaint _textConfig;
  String text = 'Drag here';
  double xCenter = 0;
  double yCenter = 0;

  BarrelDraggable(Vector2 position)
      : super.withSprite(
          sprite: CommonSpriteSheet.barrelSprite,
          position: position,
          size: Vector2.all(DungeonMap.tileSize),
        ) {
    _textConfig = TextPaint(
      style: TextStyle(color: Colors.white, fontSize: width / 4),
    );
  }

  @override
  void onMount() {
    final textSize = _textConfig.measureText(text);
    xCenter = (width - textSize.x) / 2;
    yCenter = (height - textSize.y) / 2;
    super.onMount();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _textConfig.render(
      canvas,
      text,
      Vector2(xCenter, 2.5 * yCenter),
    );
  }

  @override
  Future<void> onLoad() {
    add(RectangleHitbox(size: size / 1.5, position: size / 8.5, isSolid: true));
    return super.onLoad();
  }
}
