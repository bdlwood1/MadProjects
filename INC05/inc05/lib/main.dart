// BLOCK 1: Import Flutter's Material widgets and start the app.
import 'package:flutter/material.dart';

void main() => runApp(const CounterApp());

// BLOCK 2: This part of the app does not change, so it is a StatelessWidget.
class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterPage(),
    );
  }
}

// BLOCK 3: This page changes when the user interacts with it, so it is stateful.
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // BLOCK 4: These variables keep track of the values being used on the screen.
  int _counter = 40;
  int _increment = 7;

  final List<int> _history = [];

  final TextEditingController _incrementController = TextEditingController(
    text: '7',
  );

  @override
  void dispose() {
    // Dispose the controller when the page is no longer being used.
    _incrementController.dispose();
    super.dispose();
  }

  // BLOCK 5: These methods handle the rules and changes for the counter.
  bool _isValidValue(int value) {
    return value >= 10 && value <= 150;
  }

  // Changes the counter color depending on its current value.
  Color _counterColor() {
    if (_counter == 10) {
      return Colors.red;
    }

    if (_counter > 90) {
      return Colors.green;
    }

    return Colors.black;
  }

  // Shows a message at the bottom of the screen.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Moves the counter to a new value if it is inside the allowed range.
  void _moveTo(int nextValue) {
    if (!_isValidValue(nextValue)) {
      _showMessage('Counter must stay between 10 and 150.');
      return;
    }

    setState(() {
      // Save the current counter so the user can undo the change.
      _history.add(_counter);
      _counter = nextValue;
    });
  }

  // Reads the increment typed by the user.
  void _readIncrement(String input) {
    // Let the user temporarily clear the box while typing a new number.
    if (input.isEmpty) {
      return;
    }

    final value = int.tryParse(input);

    // Only positive whole numbers are accepted.
    if (value == null || value <= 0) {
      _showMessage('Please enter a positive whole number like 1, 5, or 10.');

      // Put the last valid increment back in the box.
      _incrementController.text = _increment.toString();
      _incrementController.selection = TextSelection.fromPosition(
        TextPosition(offset: _incrementController.text.length),
      );

      return;
    }

    // Save the new increment if it is valid.
    setState(() {
      _increment = value;
    });
  }

  // Goes back to the most recent counter value.
  void _undo() {
    if (_history.isEmpty) {
      _showMessage('There is no earlier value to restore.');
      return;
    }

    setState(() {
      _counter = _history.removeLast();
    });
  }

  // Resets the counter back to 10.
  void _reset() {
    if (_counter != 10) {
      _moveTo(10);
    }
  }

  @override
  Widget build(BuildContext context) {
    // BLOCK 6: Build creates the screen using the current counter state.
    return Scaffold(
      appBar: AppBar(title: const Text('Activity 05 Counter')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$_counter',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge
                  ?.copyWith(color: _counterColor()),
            ),

            Slider(
              value: _counter.toDouble(),
              min: 10,
              max: 150,
              divisions: 140,

              // Slider changes are saved so they can also be undone.
              onChanged: (value) {
                _moveTo(value.round());
              },
            ),

            TextField(
              controller: _incrementController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Increment amount (starts at 7)',
              ),
              onChanged: _readIncrement,
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _moveTo(_counter - _increment);
                  },
                  child: const Text('Decrease'),
                ),

                ElevatedButton(
                  onPressed: () {
                    _moveTo(_counter + _increment);
                  },
                  child: const Text('Increase'),
                ),

                OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset to 10'),
                ),

                OutlinedButton(onPressed: _undo, child: const Text('Undo')),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              _history.isEmpty
                  ? 'History: none'
                  : 'History: ${_history.join(', ')}',
            ),
          ],
        ),
      ),
    );
  }
}
