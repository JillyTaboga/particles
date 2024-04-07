import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:particles/ui/game.dart';
import 'package:uuid/uuid.dart';

sealed class ParticleEntity extends CircleComponent
    with HasGameRef<ParticlesScreen> {
  Vector2 velocity;
  final String uid;
  final Particle particle;
  ParticleEntity({
    required super.position,
    required this.velocity,
    required super.radius,
    required this.uid,
    required this.particle,
  }) : super(
          anchor: Anchor.center,
          paint: Paint()
            ..color = particle.color
            ..style = PaintingStyle.fill,
        );

  @override
  void update(double dt) {
    double forceX = 0;
    double forceY = 0;
    final config = game.particleConfig(particle);
    for (final p in game.children.query<ParticleEntity>()) {
      final targetConfig = game.particleConfig(p.particle);
      final distanceX = position.x - p.position.x;
      final distanceY = position.y - p.position.y;
      final distance = sqrt(distanceX * distanceX + distanceY * distanceY);
      if (distance > 10 && distance < targetConfig.sphereOfInfluency) {
        double force = (targetConfig.forces[particle] ?? 0 / distance);
        forceX += force * distanceX;
        forceY += force * distanceY;
      }
    }
    velocity.x = (velocity.x + forceX) * game.velocityInfluency;
    velocity.y = (velocity.y + forceY) * game.velocityInfluency;
    if (position.x <= config.radius * 2 ||
        position.x >= game.size.x - config.radius) {
      velocity.x *= -1;
    }
    if (position.y <= config.radius * 2 ||
        position.y >= game.size.y - config.radius) {
      velocity.y *= -1;
    }

    position.x = position.x + velocity.x * dt;
    position.y = position.y + velocity.y * dt;

    radius = config.radius;
    super.update(dt);
  }

  @override
  String toString() =>
      'ParticleEntity(position: $position, velocity: $velocity, size: $size, uid: $uid, particle: $particle)';
}

class YellowParticle extends ParticleEntity {
  YellowParticle({
    required super.position,
  }) : super(
          particle: Particle.yellow,
          radius: 0,
          uid: const Uuid().v4(),
          velocity: Vector2.zero(),
        );
}

class RedParticle extends ParticleEntity {
  RedParticle({
    required super.position,
  }) : super(
          particle: Particle.red,
          radius: 0,
          uid: const Uuid().v4(),
          velocity: Vector2.zero(),
        );
}

class BlueParticle extends ParticleEntity {
  BlueParticle({
    required super.position,
  }) : super(
          particle: Particle.blue,
          radius: 0,
          uid: const Uuid().v4(),
          velocity: Vector2.zero(),
        );
}

class GreenParticle extends ParticleEntity {
  GreenParticle({
    required super.position,
  }) : super(
          particle: Particle.green,
          radius: 0,
          uid: const Uuid().v4(),
          velocity: Vector2.zero(),
        );
}

enum Particle {
  yellow(Colors.yellow),
  blue(Colors.blue),
  green(Colors.green),
  red(Colors.red);

  final Color color;

  const Particle(this.color);
}

class ParticleConfig {
  int startQuantity = Random().nextInt(kIsWeb ? 30 : 300) + 100;
  double sphereOfInfluency = Random().nextInt(200) + 20;
  double radius = Random().nextDouble() + 2;
  ParticleConfig.random();
  ParticleConfig._({
    required this.startQuantity,
    required this.sphereOfInfluency,
    required this.radius,
    required this.forces,
  });
  Map<Particle, double> forces = {
    for (final element in Particle.values)
      element: switch (element) {
        Particle.yellow =>
          Random().nextDouble() * (Random().nextBool() ? -1 : 1),
        Particle.red => Random().nextDouble() * (Random().nextBool() ? -1 : 1),
        Particle.blue => Random().nextDouble() * (Random().nextBool() ? -1 : 1),
        Particle.green =>
          Random().nextDouble() * (Random().nextBool() ? -1 : 1),
      }
  };

  ParticleConfig copyWith({
    int? startQuantity,
    double? sphereOfInfluency,
    double? radius,
    Map<Particle, double>? forces,
  }) {
    return ParticleConfig._(
      startQuantity: startQuantity ?? this.startQuantity,
      sphereOfInfluency: sphereOfInfluency ?? this.sphereOfInfluency,
      radius: radius ?? this.radius,
      forces: forces ?? this.forces,
    );
  }
}
