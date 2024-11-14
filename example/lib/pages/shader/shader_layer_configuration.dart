import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';

import 'shader_config_controller.dart';

class ShaderConfiguration extends GameComponent {
  late ui.FragmentShader shader;

  late ui.Image noiseGradiente;
  late ui.Image valueGradiente;

  final Color toneColor = const Color(0xFF5ca4ec);
  final Color lightColor = const Color(0xFFffffff);
  final ShaderConfigController controller;

  ShaderConfiguration({required this.controller});

  @override
  Future<void> onLoad() async {
    final progam = await ui.FragmentProgram.fromAsset(
      'shaders/waterShaderV2.frag',
    );
    shader = progam.fragmentShader();
    noiseGradiente = await Flame.images.load('noise/gradiente_noise.png');
    valueGradiente = await Flame.images.load('noise/value_noise.png');

    ShaderSetter(
      values: [
        SetterImage(noiseGradiente),
        SetterImage(valueGradiente),
        SetterDouble(0.05),
        SetterVector2(Vector2.all(0.04)),
        SetterColor(toneColor),
        SetterColor(lightColor),
      ],
    ).apply(shader);

    return super.onLoad();
  }

  @override
  void onMount() {
    _loadShader();
    super.onMount();
  }

  @override
  void onRemove(){
    super.onRemove();
  controller.removeListener(_controllerListener);

  }

  Future<void> _loadShader() async {
    await Future.delayed(Duration.zero);
    final layer = gameRef.map.layersComponent.elementAtOrNull(1);
    layer?.shader = shader;
    layer?.shaderComponentStatic = true;
    controller.addListener(_controllerListener);
  }

  void _controllerListener() {
    ShaderSetter(
      values: [
        SetterDouble(controller.config.distortionStrength),
        SetterVector2(Vector2.all(controller.config.speed)),
        SetterColor(controller.config.toneColor),
        SetterColor(controller.config.lightColor),
      ],
    ).apply(shader);
  }
}
