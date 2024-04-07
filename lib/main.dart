import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:particles/entities/particle.dart';
import 'package:particles/ui/game.dart';

const settingsMenuTag = 'Settings';
const showSettingsButtonTag = 'ShowSettings';

void main() {
  final gameI = GameWidget(
    game: ParticlesScreen(),
    initialActiveOverlays: const [showSettingsButtonTag],
    overlayBuilderMap: {
      settingsMenuTag: (BuildContext context, ParticlesScreen game) {
        return SettingsMenu(
          game: game,
        );
      },
      showSettingsButtonTag: (BuildContext context, ParticlesScreen game) {
        return Positioned(
          bottom: 20,
          right: 20,
          child: ShowSettingsButton(
            onTap: () {
              game.overlays.add(settingsMenuTag);
              game.overlays.remove(showSettingsButtonTag);
            },
            onTapReset: () {
              game.reset();
            },
          ),
        );
      }
    },
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      home: gameI,
    ),
  );
}

class ShowSettingsButton extends StatelessWidget {
  const ShowSettingsButton({
    super.key,
    required this.onTap,
    required this.onTapReset,
  });

  final void Function() onTap;
  final void Function() onTapReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FloatingActionButton(
          onPressed: onTap,
          child: const Icon(Icons.settings),
        ),
        const SizedBox(
          width: 20,
        ),
        FloatingActionButton(
          onPressed: onTapReset,
          child: const Icon(Icons.restart_alt),
        ),
      ],
    );
  }
}

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key, required this.game});

  final ParticlesScreen game;

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  late Map<Particle, ParticleConfig> configs;
  late double speed;

  @override
  void initState() {
    super.initState();
    speed = widget.game.velocityInfluency;
    configs = {
      for (var element in Particle.values)
        element: widget.game.particleConfig(element)
    };
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: kElevationToShadow[5],
          ),
          child: Column(
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Scrollbar(
                  scrollbarOrientation: ScrollbarOrientation.right,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    primary: true,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: speed,
                                min: 0.01,
                                max: 1,
                                onChanged: (value) {
                                  widget.game.velocityInfluency = value;
                                  setState(() {
                                    speed = value;
                                  });
                                },
                              ),
                            ),
                            const Text('Velocidade: '),
                            Text(widget.game.velocityInfluency
                                .toStringAsFixed(2)),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        for (final particle in Particle.values)
                          Builder(builder: (context) {
                            final config = configs[particle]!;
                            return Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black54,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(particle.name.toUpperCase()),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        width: config.radius * 5,
                                        height: config.radius * 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: particle.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Slider(
                                          value: config.startQuantity / 1,
                                          min: 0,
                                          max: 500,
                                          onChanged: (value) {
                                            final newConfig = config.copyWith(
                                              startQuantity: value.floor(),
                                            );
                                            widget.game.changeConfig(
                                              newConfig,
                                              particle,
                                            );
                                            setState(() {
                                              configs[particle] = newConfig;
                                            });
                                          },
                                        ),
                                      ),
                                      const Text('Quantidade: '),
                                      Text(config.startQuantity.toString()),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Slider(
                                          value: config.radius,
                                          min: 1,
                                          max: 10,
                                          onChanged: (value) {
                                            final newConfig = config.copyWith(
                                              radius: value,
                                            );
                                            widget.game.changeConfig(
                                              newConfig,
                                              particle,
                                            );
                                            setState(() {
                                              configs[particle] = newConfig;
                                            });
                                          },
                                        ),
                                      ),
                                      const Text('Raio: '),
                                      Text(config.radius.toStringAsFixed(2)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Slider(
                                          value: config.sphereOfInfluency,
                                          min: 10,
                                          max: max(
                                            widget.game.size.x,
                                            widget.game.size.y,
                                          ),
                                          onChanged: (value) {
                                            final newConfig = config.copyWith(
                                              sphereOfInfluency: value,
                                            );
                                            widget.game.changeConfig(
                                              newConfig,
                                              particle,
                                            );
                                            setState(() {
                                              configs[particle] = newConfig;
                                            });
                                          },
                                        ),
                                      ),
                                      const Text('Influência: '),
                                      Text(config.sphereOfInfluency
                                          .toStringAsFixed(2)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text('Forças:'),
                                  LayoutBuilder(
                                      builder: (context, constraints) {
                                    final width =
                                        (constraints.maxWidth / 2) - 10;
                                    return Wrap(
                                      children: Particle.values.map(
                                        (e) {
                                          final force = config.forces[e]!;
                                          return SizedBox(
                                            width: width,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Slider(
                                                    value: force,
                                                    min: -1,
                                                    max: 1,
                                                    onChanged: (value) {
                                                      var newForce =
                                                          config.forces;
                                                      newForce[e] = value;
                                                      final newConfig =
                                                          config.copyWith(
                                                        forces: newForce,
                                                      );
                                                      widget.game.changeConfig(
                                                        newConfig,
                                                        particle,
                                                      );
                                                      setState(() {
                                                        configs[particle] =
                                                            newConfig;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  width: 15,
                                                  height: 15,
                                                  decoration: BoxDecoration(
                                                    color: e.color,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(force.toStringAsFixed(2)),
                                              ],
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        widget.game.overlays.remove(settingsMenuTag);
                        widget.game.overlays.add(showSettingsButtonTag);
                      },
                      child: const Text('Fechar'),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {
                        widget.game.reset();
                        widget.game.overlays.remove(settingsMenuTag);
                        widget.game.overlays.add(showSettingsButtonTag);
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.game.reload();
                        widget.game.overlays.remove(settingsMenuTag);
                        widget.game.overlays.add(showSettingsButtonTag);
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
