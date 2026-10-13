import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator State Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Authoritative calculator state.
  double accumulator = 0;
  String currentOperand = '0';
  String? pendingOperator;
  bool awaitingOperand = false;
  bool resultPhase = false;
  String? errorMessage;

  // Converts numbers into readable display strings.
  String formatNumber(double value) {
    if (!value.isFinite) return 'Error';
    if (value == 0) return '0';
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value
        .toStringAsPrecision(10)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  double? calculate(double first, double second, String op) {
    switch (op) {
      case '+':
        return first + second;
      case '-':
        return first - second;
      case '×':
        return first * second;
      case '÷':
        if (second == 0) return null;
        return first / second;
      default:
        return second;
    }
  }

  void resetAll() {
    setState(() {
      accumulator = 0;
      currentOperand = '0';
      pendingOperator = null;
      awaitingOperand = false;
      resultPhase = false;
      errorMessage = null;
    });
  }

  // C clears the current entry without deleting the pending operation.
  void clearEntry() {
    setState(() {
      currentOperand = '0';
      errorMessage = null;
      if (resultPhase) {
        accumulator = 0;
        pendingOperator = null;
        resultPhase = false;
      }
      awaitingOperand = false;
    });
  }

  void enterDigit(String digit) {
    setState(() {
      if (errorMessage != null) {
        accumulator = 0;
        pendingOperator = null;
        errorMessage = null;
        awaitingOperand = false;
        resultPhase = false;
        currentOperand = '0';
      }

      if (resultPhase) {
        accumulator = 0;
        pendingOperator = null;
        resultPhase = false;
        awaitingOperand = false;
        currentOperand = '0';
      }

      if (awaitingOperand) {
        currentOperand = digit;
        awaitingOperand = false;
      } else if (currentOperand == '0') {
        currentOperand = digit;
      } else if (currentOperand == '-0') {
        currentOperand = '-$digit';
      } else if (currentOperand.length < 14) {
        currentOperand += digit;
      }
    });
  }

  void toggleSign() {
    setState(() {
      if (errorMessage != null) return;
      if (awaitingOperand) {
        currentOperand = '0';
        awaitingOperand = false;
      }
      if (currentOperand == '0') return;
      if (currentOperand.startsWith('-')) {
        currentOperand = currentOperand.substring(1);
      } else {
        currentOperand = '-$currentOperand';
      }
      if (resultPhase) {
        accumulator = double.tryParse(currentOperand) ?? 0;
      }
    });
  }

  void chooseOperator(String op) {
    setState(() {
      if (errorMessage != null) return;

      // Repeated operators replace the pending operator.
      if (awaitingOperand) {
        pendingOperator = op;
        return;
      }

      final number = double.tryParse(currentOperand);
      if (number == null) {
        errorMessage = 'Invalid number. Press AC.';
        return;
      }

      if (pendingOperator != null && !resultPhase) {
        final answer = calculate(accumulator, number, pendingOperator!);
        if (answer == null || !answer.isFinite) {
          errorMessage = 'Cannot divide by zero. Press AC.';
          pendingOperator = null;
          return;
        }
        accumulator = answer;
      } else {
        accumulator = number;
      }

      currentOperand = formatNumber(accumulator);
      pendingOperator = op;
      awaitingOperand = true;
      resultPhase = false;
    });
  }

  void equals() {
    setState(() {
      if (errorMessage != null) return;

      // Equals without a new operand must not repeat an operation.
      if (pendingOperator == null || awaitingOperand) return;

      final number = double.tryParse(currentOperand);
      if (number == null) {
        errorMessage = 'Invalid number. Press AC.';
        return;
      }

      final answer = calculate(accumulator, number, pendingOperator!);
      if (answer == null || !answer.isFinite) {
        errorMessage = 'Cannot divide by zero. Press AC.';
        pendingOperator = null;
        return;
      }

      accumulator = answer;
      currentOperand = formatNumber(answer);
      pendingOperator = null;
      awaitingOperand = false;
      resultPhase = true;
    });
  }

  void handleButton(String value) {
    if (RegExp(r'^[0-9]$').hasMatch(value)) {
      enterDigit(value);
    } else if (value == 'AC') {
      resetAll();
    } else if (value == 'C') {
      clearEntry();
    } else if (value == '±') {
      toggleSign();
    } else if (value == '=') {
      equals();
    } else {
      chooseOperator(value);
    }
  }

  Widget calculatorButton(String label) {
    final isOperator = ['+', '-', '×', '÷', '='].contains(label);
    final isUtility = ['AC', 'C', '±'].contains(label);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox.expand(
          child: ElevatedButton(
            onPressed: () => handleButton(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: isOperator
                  ? Colors.deepOrange
                  : isUtility
                  ? Colors.orange.shade100
                  : Colors.white,
              foregroundColor: isOperator ? Colors.white : Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget buttonRow(List<String> labels) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: labels.map(calculatorButton).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final display = errorMessage ?? currentOperand;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator State Lab'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade50,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage != null
                            ? 'ERROR'
                            : pendingOperator != null
                            ? 'Running total: ${formatNumber(accumulator)}'
                                  '   $pendingOperator'
                            : resultPhase
                            ? 'RESULT'
                            : 'READY',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          display,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: errorMessage != null
                                ? Colors.red
                                : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Operations evaluate left to right',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    buttonRow(['AC', 'C', '±', '÷']),
                    buttonRow(['7', '8', '9', '×']),
                    buttonRow(['4', '5', '6', '-']),
                    buttonRow(['1', '2', '3', '+']),
                    buttonRow(['0', '=']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
