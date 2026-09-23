/*
Activity 04 - Flutter Widget Wars

Team Name: BN

Team Members:
[Bryce Leidgertwood] - [002681668]
[Nour Khoulani] - [002811396]
*/

import 'package:flutter/material.dart';

void main() {
  runApp(const DJStudioApp());
}

// Controls the light and dark theme
class DJStudioApp extends StatefulWidget {
  const DJStudioApp({super.key});

  @override
  State<DJStudioApp> createState() => _DJStudioAppState();
}

class _DJStudioAppState extends State<DJStudioApp> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DJ Soundboard',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: DJSoundboardScreen(
        isDark: isDarkMode,
        onToggleTheme: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      ),
    );
  }
}

// Main screen for the DJ controls
class DJSoundboardScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const DJSoundboardScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<DJSoundboardScreen> createState() => _DJSoundboardScreenState();
}

class _DJSoundboardScreenState extends State<DJSoundboardScreen> {
  int bpm = 120;
  int dropsTriggered = 0;
  int loopCount = 0;
  bool isPlaying = false;
  String activeTrack = 'NONE';

  // Changes the current track and counts each sound
  void _playSound(String track) {
    setState(() {
      activeTrack = track;
      isPlaying = true;

      if (track == 'SYNTH DROP' || track == 'BASS KICK') {
        dropsTriggered++;
      }

      if (track == 'LOOP') {
        loopCount++;
      }
    });
  }

  // Stops the current sound
  void _stopSound() {
    setState(() {
      activeTrack = 'NONE';
      isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool crowdHype = dropsTriggered >= 4;

    final screenBg = crowdHype
        ? (widget.isDark ? const Color(0xFF301934) : const Color(0xFFFFE4F2))
        : (widget.isDark ? const Color(0xFF1E1F29) : const Color(0xFFE0E5EC));

    final cardBg = widget.isDark ? const Color(0xFF282A36) : Colors.white;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        title: const Text(
          'DJ SOUNDBOARD',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const DJTitle(),

            const SizedBox(height: 18),

            // Shows the current DJ stats
            DJStatsCard(
              bpm: bpm,
              dropsTriggered: dropsTriggered,
              loopCount: loopCount,
              cardColor: cardBg,
            ),

            const SizedBox(height: 18),

            Text(
              isPlaying ? 'NOW PLAYING: $activeTrack' : 'NOW PLAYING: NONE',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.cyanAccent : Colors.blue.shade700,
              ),
            ),

            const SizedBox(height: 12),

            // Appears after four drops have been triggered
            if (crowdHype)
              const Text(
                '🔥 CROWD HYPE! 🔥',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),

            const SizedBox(height: 28),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                TactileButton(
                  icon: Icons.flash_on,
                  label: 'SYNTH DROP',
                  accentColor: Colors.pinkAccent,
                  isDark: widget.isDark,
                  onPressed: () => _playSound('SYNTH DROP'),
                ),
                TactileButton(
                  icon: Icons.speaker,
                  label: 'BASS KICK',
                  accentColor: Colors.cyanAccent,
                  isDark: widget.isDark,
                  onPressed: () => _playSound('BASS KICK'),
                ),
                TactileButton(
                  icon: Icons.loop,
                  label: 'LOOP',
                  accentColor: Colors.purpleAccent,
                  isDark: widget.isDark,
                  onPressed: () => _playSound('LOOP'),
                ),
                TactileButton(
                  icon: Icons.stop,
                  label: 'STOP',
                  accentColor: Colors.redAccent,
                  isDark: widget.isDark,
                  onPressed: _stopSound,
                ),
              ],
            ),

            const SizedBox(height: 36),

            Text(
              'BPM: $bpm',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            // Updates the BPM while the slider moves
            Slider(
              value: bpm.toDouble(),
              min: 60,
              max: 180,
              divisions: 120,
              label: '$bpm BPM',
              activeColor: Colors.pinkAccent,
              inactiveColor: Colors.grey.withOpacity(0.3),
              onChanged: (newValue) {
                setState(() {
                  bpm = newValue.round();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Simple title widget
class DJTitle extends StatelessWidget {
  const DJTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.headphones, size: 52, color: Colors.pinkAccent),
        SizedBox(height: 8),
        Text(
          'LIVE DJ CONTROL PANEL',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Displays the BPM, drops, and loops
class DJStatsCard extends StatelessWidget {
  final int bpm;
  final int dropsTriggered;
  final int loopCount;
  final Color cardColor;

  const DJStatsCard({
    super.key,
    required this.bpm,
    required this.dropsTriggered,
    required this.loopCount,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DJStat(label: 'BPM', value: '$bpm'),
          _DJStat(label: 'DROPS', value: '$dropsTriggered'),
          _DJStat(label: 'LOOPS', value: '$loopCount'),
        ],
      ),
    );
  }
}

// Small reusable widget for each stat
class _DJStat extends StatelessWidget {
  final String label;
  final String value;

  const _DJStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Button keeps track of its own pressed animation
class TactileButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onPressed;

  const TactileButton({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.isDark,
    required this.onPressed,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDark
        ? const Color(0xFF222430)
        : const Color(0xFFE0E5EC);

    final darkShadow = widget.isDark ? Colors.black87 : const Color(0xFFA3B1C6);

    final lightShadow = widget.isDark ? const Color(0xFF2F3244) : Colors.white;

    return GestureDetector(
      // Pushes the button down
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },

      // Releases the button and performs the sound action
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });

        widget.onPressed();
      },

      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: darkShadow.withOpacity(0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: lightShadow.withOpacity(0.5),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: darkShadow.withOpacity(0.7),
                    offset: const Offset(8, 8),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: lightShadow.withOpacity(0.9),
                    offset: const Offset(-8, -8),
                    blurRadius: 16,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: isPressed ? 40 : 46,
              color: isPressed
                  ? widget.accentColor
                  : (widget.isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.1,
                color: isPressed
                    ? widget.accentColor
                    : (widget.isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
