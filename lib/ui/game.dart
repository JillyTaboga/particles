import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:particles/entities/particle.dart';

class ParticlesScreen extends FlameGame with SingleGameInstance {
  double velocityInfluency = 0.1;

  ParticleConfig redConfig = ParticleConfig.random();
  ParticleConfig blueConfig = ParticleConfig.random();
  ParticleConfig yellowConfig = ParticleConfig.random();
  ParticleConfig greenConfig = ParticleConfig.random();

  ParticleConfig particleConfig(Particle type) => switch (type) {
        Particle.red => redConfig,
        Particle.blue => blueConfig,
        Particle.yellow => yellowConfig,
        Particle.green => greenConfig,
      };

  changeConfig(ParticleConfig config, Particle type) {
    switch (type) {
      case Particle.red:
        redConfig = config;
        break;
      case Particle.blue:
        blueConfig = config;
        break;
      case Particle.yellow:
        yellowConfig = config;
        break;
      case Particle.green:
        greenConfig = config;
        break;
    }
  }

  reset() {
    redConfig = ParticleConfig.random();
    blueConfig = ParticleConfig.random();
    yellowConfig = ParticleConfig.random();
    greenConfig = ParticleConfig.random();
    velocityInfluency = 0.1;
    start();
  }

  void addParticle(Particle type, {Vector2? position}) {
    final realPosition = position ??
        Vector2(
          Random().nextDouble() * size.x,
          Random().nextDouble() * size.y,
        );
    switch (type) {
      case Particle.yellow:
        add(YellowParticle(position: realPosition));
        break;
      case Particle.red:
        add(RedParticle(position: realPosition));
        break;
      case Particle.blue:
        add(BlueParticle(position: realPosition));
        break;
      case Particle.green:
        add(GreenParticle(position: realPosition));
        break;
    }
  }

  @override
  FutureOr<void> onLoad() {
    start();
    return super.onLoad();
  }

  start() {
    removeAll(children.query<ParticleEntity>());
    for (int n = 0; n < yellowConfig.startQuantity; n++) {
      addParticle(Particle.yellow);
    }
    for (int n = 0; n < redConfig.startQuantity; n++) {
      addParticle(Particle.red);
    }
    for (int n = 0; n < blueConfig.startQuantity; n++) {
      addParticle(Particle.blue);
    }
    for (int n = 0; n < greenConfig.startQuantity; n++) {
      addParticle(Particle.green);
    }
  }

  @override
  Color backgroundColor() {
    return Colors.black;
  }

  @override
  void update(double dt) {
    for (final yellow in children.query<YellowParticle>()) {
      yellow.update(dt);
    }
    for (final red in children.query<RedParticle>()) {
      red.update(dt);
    }

    super.update(dt);
  }

  void reload() {
    start();
  }
}
