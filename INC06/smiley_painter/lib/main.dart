// In-Class Activity 06 — Drawing with Flutter
// Student: Bryce Leidgertwood
// Date: September 26, 2026

import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

enum FaceType { classic, sleepy, surprised }

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  // Values that control the CustomPainter.
  double mood = 0.8;
  double eyeRadius = 0.08;
  double eyeGap = 0.35;

  FaceType faceType = FaceType.classic;

  Color faceColor = Colors.yellow.shade600;

  bool showBlush = true;

  // Tap cycles through the three required faces.
  void cycleFace() {
    setState(() {
      final next = (faceType.index + 1) % FaceType.values.length;

      faceType = FaceType.values[next];
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Face changed to ${faceType.name}'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  // Long press randomizes mood and face color.
  void randomizeFace() {
    final random = Random();

    final colors = <Color>[
      Colors.yellow.shade600,
      Colors.lightBlue.shade300,
      Colors.orange.shade300,
      Colors.green.shade300,
      Colors.pink.shade200,
    ];

    setState(() {
      mood = random.nextDouble();
      faceColor = colors[random.nextInt(colors.length)];
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Mood and color randomized!'),
          duration: Duration(seconds: 1),
        ),
      );
  }

  // Changes the face color with preset buttons.
  void changeFaceColor(Color color) {
    setState(() {
      faceColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),

      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: cycleFace,
                onLongPress: randomizeFace,

                child: CustomPaint(
                  size: const Size(300, 300),

                  painter: SmileyPainter(
                    mood: mood,
                    faceType: faceType,
                    faceColor: faceColor,
                    eyeRadius: eyeRadius,
                    eyeGap: eyeGap,
                    showBlush: showBlush,
                  ),
                ),
              ),
            ),
          ),

          // Controls
          Container(
            constraints: const BoxConstraints(maxHeight: 285),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),

              child: Column(
                children: [
                  Text(
                    'Face: ${faceType.name.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  // -----------------------------
                  // MOOD
                  // -----------------------------
                  Text('Mood: ${mood.toStringAsFixed(2)}'),

                  Slider(
                    value: mood,
                    min: 0,
                    max: 1,

                    onChanged: (double value) {
                      setState(() {
                        mood = value;

                        // Required mood color bands.
                        if (mood < 0.35) {
                          faceColor = Colors.lightBlue.shade300;
                        } else if (mood <= 0.7) {
                          faceColor = Colors.yellow.shade600;
                        } else {
                          faceColor = Colors.orange.shade300;
                        }
                      });
                    },
                  ),

                  // -----------------------------
                  // EYE RADIUS
                  // -----------------------------
                  Text(
                    'Eye Radius: '
                    '${(eyeRadius * 100).toStringAsFixed(0)}',
                  ),

                  Slider(
                    value: eyeRadius,
                    min: 0.04,
                    max: 0.14,

                    onChanged: (double value) {
                      setState(() {
                        eyeRadius = value;
                      });
                    },
                  ),

                  // -----------------------------
                  // EYE GAP
                  // -----------------------------
                  Text(
                    'Eye Gap: '
                    '${(eyeGap * 100).toStringAsFixed(0)}',
                  ),

                  Slider(
                    value: eyeGap,
                    min: 0.20,
                    max: 0.55,

                    onChanged: (double value) {
                      setState(() {
                        eyeGap = value;
                      });
                    },
                  ),

                  // -----------------------------
                  // BLUSH
                  // -----------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Checkbox(
                        value: showBlush,

                        onChanged: (bool? value) {
                          setState(() {
                            showBlush = value ?? false;
                          });
                        },
                      ),

                      const Text('Show Blush'),
                    ],
                  ),

                  // -----------------------------
                  // FACE COLOR PRESETS
                  // -----------------------------
                  const Text(
                    'Face Color',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,

                    children: [
                      ElevatedButton(
                        onPressed: () {
                          changeFaceColor(Colors.yellow.shade600);
                        },
                        child: const Text('Yellow'),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          changeFaceColor(Colors.lightBlue.shade300);
                        },
                        child: const Text('Blue'),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          changeFaceColor(Colors.green.shade300);
                        },
                        child: const Text('Green'),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          changeFaceColor(Colors.pink.shade200);
                        },
                        child: const Text('Pink'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Tap face to change style • '
                    'Long press to randomize',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CUSTOM PAINTER
// =====================================================

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    required this.faceType,
    required this.faceColor,
    required this.eyeRadius,
    required this.eyeGap,
    required this.showBlush,
  });

  final double mood;
  final FaceType faceType;
  final Color faceColor;

  final double eyeRadius;
  final double eyeGap;

  final bool showBlush;

  @override
  void paint(Canvas canvas, Size size) {
    // Responsive coordinate system.
    final center = Offset(size.width / 2, size.height / 2);

    // shortestSide keeps the face inside the
    // available area in portrait or landscape.
    final radius = size.shortestSide * 0.4;

    // =================================================
    // 1. FACE
    // =================================================

    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, facePaint);

    // =================================================
    // 2. FACE BORDER
    // =================================================

    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, borderPaint);

    // =================================================
    // 3. EYES
    // =================================================

    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyeY = center.dy - radius * 0.18;

    final eyeDx = radius * eyeGap;

    final currentEyeRadius = faceType == FaceType.surprised
        ? radius * (eyeRadius + 0.03)
        : radius * eyeRadius;

    // Sleepy face uses closed line eyes.
    if (faceType == FaceType.sleepy) {
      final sleepyPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(center.dx - eyeDx - radius * 0.10, eyeY),
        Offset(center.dx - eyeDx + radius * 0.10, eyeY),
        sleepyPaint,
      );

      canvas.drawLine(
        Offset(center.dx + eyeDx - radius * 0.10, eyeY),
        Offset(center.dx + eyeDx + radius * 0.10, eyeY),
        sleepyPaint,
      );
    } else {
      canvas.drawCircle(
        Offset(center.dx - eyeDx, eyeY),
        currentEyeRadius,
        eyePaint,
      );

      canvas.drawCircle(
        Offset(center.dx + eyeDx, eyeY),
        currentEyeRadius,
        eyePaint,
      );
    }

    // =================================================
    // 4. MOUTH
    // =================================================

    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Surprised face has an open mouth.
    if (faceType == FaceType.surprised) {
      canvas.drawCircle(
        Offset(center.dx, center.dy + radius * 0.35),
        radius * 0.16,
        mouthPaint,
      );
    } else {
      // Mouth measurements are based on radius
      // rather than fixed pixels.
      final mouthRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.15),
        width: radius * 1.0,
        height: radius * (0.4 + mood * 0.5),
      );

      if (mood >= 0.5) {
        // Happy smile.
        canvas.drawArc(mouthRect, 0.15 * pi, 0.70 * pi, false, mouthPaint);
      } else {
        // Sad frown.
        final frownRect = mouthRect.translate(0, radius * 0.25);

        canvas.drawArc(frownRect, 1.15 * pi, 0.70 * pi, false, mouthPaint);
      }
    }

    // =================================================
    // 5. BLUSH
    // =================================================

    if (showBlush) {
      final blushPaint = Paint()
        ..color = Colors.pinkAccent.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;

      final leftBlush = Rect.fromCenter(
        center: Offset(center.dx - radius * 0.52, center.dy + radius * 0.15),
        width: radius * 0.30,
        height: radius * 0.15,
      );

      final rightBlush = Rect.fromCenter(
        center: Offset(center.dx + radius * 0.52, center.dy + radius * 0.15),
        width: radius * 0.30,
        height: radius * 0.15,
      );

      canvas.drawOval(leftBlush, blushPaint);

      canvas.drawOval(rightBlush, blushPaint);
    }

    // =================================================
    // 6. HAT / PAINT ORDER
    // =================================================
    //
    // The hat is intentionally drawn AFTER the face.
    // Later canvas calls appear on top of earlier ones.

    final hatPaint = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.fill;

    final hatBrim = Rect.fromCenter(
      center: Offset(center.dx, center.dy - radius * 0.93),
      width: radius * 1.0,
      height: radius * 0.25,
    );

    canvas.drawRect(hatBrim, hatPaint);

    final hatTop = Rect.fromCenter(
      center: Offset(center.dx, center.dy - radius * 1.15),
      width: radius * 0.60,
      height: radius * 0.45,
    );

    canvas.drawRect(hatTop, hatPaint);
  }

  // Only repaint when one of the painter's inputs changes.
  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.faceType != faceType ||
        oldDelegate.faceColor != faceColor ||
        oldDelegate.eyeRadius != eyeRadius ||
        oldDelegate.eyeGap != eyeGap ||
        oldDelegate.showBlush != showBlush;
  }
}
