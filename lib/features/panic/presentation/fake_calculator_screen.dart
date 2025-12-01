import 'package:flutter/material.dart';

/// Fake calculator screen for panic mode
class FakeCalculatorScreen extends StatefulWidget {
  final VoidCallback onExit;

  const FakeCalculatorScreen({
    super.key,
    required this.onExit,
  });

  @override
  State<FakeCalculatorScreen> createState() => _FakeCalculatorScreenState();
}

class _FakeCalculatorScreenState extends State<FakeCalculatorScreen> {
  String _display = '0';
  String _currentNumber = '';
  String _operation = '';
  double _firstNumber = 0;
  bool _shouldResetDisplay = false;

  void _onDigitPressed(String digit) {
    setState(() {
      if (_shouldResetDisplay) {
        _display = digit;
        _currentNumber = digit;
        _shouldResetDisplay = false;
      } else {
        if (_display == '0' && digit != '.') {
          _display = digit;
        } else {
          _display += digit;
        }
        _currentNumber += digit;
      }
    });
  }

  void _onOperationPressed(String op) {
    setState(() {
      _firstNumber = double.tryParse(_currentNumber) ?? 0;
      _operation = op;
      _currentNumber = '';
      _shouldResetDisplay = true;
    });
  }

  void _onEquals() {
    if (_operation.isEmpty || _currentNumber.isEmpty) return;

    final secondNumber = double.tryParse(_currentNumber) ?? 0;
    double result = 0;

    switch (_operation) {
      case '+':
        result = _firstNumber + secondNumber;
        break;
      case '-':
        result = _firstNumber - secondNumber;
        break;
      case '×':
        result = _firstNumber * secondNumber;
        break;
      case '÷':
        if (secondNumber != 0) {
          result = _firstNumber / secondNumber;
        }
        break;
    }

    setState(() {
      _display = _formatResult(result);
      _currentNumber = _display;
      _operation = '';
      _shouldResetDisplay = true;
    });
  }

  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _currentNumber = '';
      _operation = '';
      _firstNumber = 0;
      _shouldResetDisplay = false;
    });
  }

  void _onPlusMinus() {
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
      _currentNumber = _display;
    });
  }

  void _onPercent() {
    final value = double.tryParse(_display) ?? 0;
    setState(() {
      _display = _formatResult(value / 100);
      _currentNumber = _display;
    });
  }

  // Secret exit: long press on "AC" button
  void _onSecretExit() {
    widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: Text(
                  _display,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Buttons
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildButtonRow([
                    _buildFunctionButton('AC', onLongPress: _onSecretExit),
                    _buildFunctionButton('±', onTap: _onPlusMinus),
                    _buildFunctionButton('%', onTap: _onPercent),
                    _buildOperationButton('÷'),
                  ]),
                  _buildButtonRow([
                    _buildDigitButton('7'),
                    _buildDigitButton('8'),
                    _buildDigitButton('9'),
                    _buildOperationButton('×'),
                  ]),
                  _buildButtonRow([
                    _buildDigitButton('4'),
                    _buildDigitButton('5'),
                    _buildDigitButton('6'),
                    _buildOperationButton('-'),
                  ]),
                  _buildButtonRow([
                    _buildDigitButton('1'),
                    _buildDigitButton('2'),
                    _buildDigitButton('3'),
                    _buildOperationButton('+'),
                  ]),
                  _buildButtonRow([
                    _buildDigitButton('0', flex: 2),
                    _buildDigitButton('.'),
                    _buildEqualsButton(),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<Widget> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons,
      ),
    );
  }

  Widget _buildDigitButton(String digit, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _onDigitPressed(digit),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF333333),
            foregroundColor: Colors.white,
            shape: digit == '0' && flex == 2
                ? const StadiumBorder()
                : const CircleBorder(),
            textStyle: const TextStyle(fontSize: 32),
          ),
          child: Text(digit),
        ),
      ),
    );
  }

  Widget _buildFunctionButton(String label,
      {VoidCallback? onTap, VoidCallback? onLongPress}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: GestureDetector(
          onLongPress: onLongPress,
          child: ElevatedButton(
            onPressed: label == 'AC' ? _onClear : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA5A5A5),
              foregroundColor: Colors.black,
              shape: const CircleBorder(),
              textStyle: const TextStyle(fontSize: 28),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildOperationButton(String op) {
    final isSelected = _operation == op;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _onOperationPressed(op),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.white : const Color(0xFFFF9F0A),
            foregroundColor:
                isSelected ? const Color(0xFFFF9F0A) : Colors.white,
            shape: const CircleBorder(),
            textStyle: const TextStyle(fontSize: 36),
          ),
          child: Text(op),
        ),
      ),
    );
  }

  Widget _buildEqualsButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: _onEquals,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9F0A),
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            textStyle: const TextStyle(fontSize: 36),
          ),
          child: const Text('='),
        ),
      ),
    );
  }
}
