import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RunMyApp());
}

// Extra colors that can be used with the themes
class AppColors extends ThemeExtension<AppColors> {
  final Color success;

  const AppColors({required this.success});

  @override
  AppColors copyWith({Color? success}) {
    return AppColors(success: success ?? this.success);
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors(
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

class RunMyApp extends StatefulWidget {
  const RunMyApp({super.key});

  @override
  State<RunMyApp> createState() => _RunMyAppState();
}

class _RunMyAppState extends State<RunMyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();

    // Loads the theme that was used last time
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode');

    if (!mounted) return;

    setState(() {
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedTheme == 'system') {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  // Saves the theme so it stays the same after closing the app
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  // Changes the theme and saves the new choice
  void _changeTheme(bool darkMode) {
    final newMode = darkMode ? ThemeMode.dark : ThemeMode.light;

    setState(() {
      _themeMode = newMode;
    });

    _saveThemeMode(newMode);
  }

  @override
  Widget build(BuildContext context) {
    // Light theme colors and styling
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey.shade200,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFF7FF),
        foregroundColor: Colors.black87,
      ),
      extensions: const [
        AppColors(success: Colors.amber),
      ],
    );

    // Dark theme colors and styling
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF211F23),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF211F23),
        foregroundColor: Colors.white,
      ),
      extensions: const [
        AppColors(success: Colors.teal),
      ],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Card Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,

      // Sends the theme change function to the home screen
      home: HomeScreen(
        themeMode: _themeMode,
        changeTheme: _changeTheme,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<bool> changeTheme;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.changeTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Gets my extra status color from the current theme
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Card Demo'),
      ),

      // Animates the whole screen when the theme changes
      body: AnimatedTheme(
        data: Theme.of(context),
        duration: const Duration(milliseconds: 500),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor:
                isDark ? Colors.teal : Colors.blueGrey.shade400,
                child: const Icon(
                  Icons.person,
                  size: 42,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Flutter Theme Lab',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // The status card changes color with the theme
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 220,
                height: 64,
                decoration: BoxDecoration(
                  color: appColors.success,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // The icon also changes between light and dark mode
                    Icon(
                      isDark
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isDark ? Colors.white : Colors.black87,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      'Status: Online',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'Choose the Theme:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 12),

              // Switch used to change between the two themes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Light'),

                  const SizedBox(width: 10),

                  Switch(
                    value: isDark,
                    onChanged: (bool value) {
                      changeTheme(value);
                    },
                  ),

                  const SizedBox(width: 10),

                  const Text('Dark'),
                ],
              ),

              const SizedBox(height: 25),

              // Shows which theme is being used
              Text(
                isDark ? 'Dark Mode Active' : 'Light Mode Active',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}