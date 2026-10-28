import 'package:flutter/material.dart';

import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dateController = TextEditingController();

  static const Color orange = Color(0xFFE66A00);
  static const Color darkOrange = Color(0xFFB84A00);
  static const Color lightOrange = Color(0xFFFFF0DA);

  bool _obscurePassword = true;
  DateTime? _birthDate;
  bool _submitting = false;

  // Local Signup Coach from Activity 10.
  bool _isLoading = false;
  String? _currentTip;
  String? _errorMessage;
  bool _simulateError = false;
  int _tipIndex = 0;

  final List<String> _passwordTips = [
    'Use a password that is hard to guess and avoid personal information.',
    'Try using a mix of letters, numbers, and symbols.',
    'Avoid using the same password for multiple accounts.',
    'A longer password or passphrase is usually harder to guess.',
  ];

  Future<void> _getSignupTip() async {
    setState(() {
      _isLoading = true;
      _currentTip = null;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      if (_simulateError) {
        _errorMessage = 'Could not load a sample tip. Please try again.';
      } else {
        _currentTip = _passwordTips[_tipIndex];
        _tipIndex = (_tipIndex + 1) % _passwordTips.length;
      }
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2003),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: orange,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _birthDate = picked;
        _dateController.text = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    // Simulate signup processing.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(userName: _nameController.text.trim()),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: darkOrange),
      prefixIcon: Icon(icon, color: orange),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: orange),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightOrange,
      appBar: AppBar(
        title: const Text('Haunted Signup Laboratory'),
        backgroundColor: orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Join the Mansion',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: darkOrange,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your details to join our haunted guest book.',
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 24),

              // Full name field.
              TextFormField(
                controller: _nameController,
                decoration: _fieldDecoration('Full Name', Icons.person),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email field.
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration('Email Address', Icons.email),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password visibility toggle.
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _fieldDecoration('Password', Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    color: orange,
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Birth-date picker.
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: _fieldDecoration('Birth Date', Icons.cake).copyWith(
                  suffixIcon: const Icon(Icons.calendar_month, color: orange),
                ),
                validator: (_) =>
                    _birthDate == null ? 'Pick your birth date' : null,
                onTap: _pickBirthDate,
              ),
              const SizedBox(height: 24),

              // Loading spinner and signup button.
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: darkOrange,
                  padding: const EdgeInsets.all(16),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Join the Mansion',
                        style: TextStyle(fontSize: 18),
                      ),
              ),

              const SizedBox(height: 32),
              const Divider(color: orange),
              const SizedBox(height: 16),

              // Signup Coach from Activity 10.
              const Text(
                'Signup Coach',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkOrange,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Get a sample password tip. This is a local demo and does not use AI or the internet.',
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                activeThumbColor: orange,
                title: const Text('Simulate an error'),
                subtitle: const Text('Turn on to test retry'),
                value: _simulateError,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _simulateError = value;
                        });
                      },
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _isLoading ? null : _getSignupTip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Get a signup tip'),
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: orange),
                      SizedBox(height: 8),
                      Text('Loading sample tip...'),
                    ],
                  ),
                ),

              if (_currentTip != null && !_isLoading)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: orange),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Local demo tip (not AI-generated)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_currentTip!),
                    ],
                  ),
                ),

              if (_errorMessage != null && !_isLoading)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _getSignupTip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: darkOrange,
                      ),
                      child: const Text('Retry'),
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
