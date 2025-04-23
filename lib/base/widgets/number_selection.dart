import 'package:flutter/material.dart';

class NumberSelection extends StatefulWidget {
  final Function(int)? onNumberSelected;
  final bool isTwoDigit;

  const NumberSelection({
    super.key,
    this.onNumberSelected,
    required this.isTwoDigit,
  });

  @override
  State<NumberSelection> createState() => _NumberSelectionState();
}

class _NumberSelectionState extends State<NumberSelection> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage; // Variable to hold the error message

  void _submitNumber() {
    final input = _controller.text;
    if (input.isEmpty) {
      // Show an error message if the input is empty
      setState(() {
        _errorMessage = 'Please enter a two-digit number (10-99).';
      });
      _clearErrorMessageAfterDelay();
      return;
    }

    final number = int.tryParse(input);
    if (number == null) {
      // Show an error message if the input is not a number
      setState(() {
        _errorMessage = 'Please enter a two-digit number (10-99).';
      });
      _clearErrorMessageAfterDelay();
      return;
    }

    if (number < 10 || number > 99) {
      // Show an error message if the number is not a two-digit number
      setState(() {
        _errorMessage = 'Please enter a two-digit number (10-99).';
      });
      _clearErrorMessageAfterDelay();
      return;
    }

    // If the number is valid, call the callback and close the modal
    widget.onNumberSelected?.call(number);
    Navigator.pop(context);
  }

  void _clearErrorMessageAfterDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _errorMessage = null; // Clear the error message after 5 seconds
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1F4B7A),
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFF102A43),
          builder: (BuildContext context) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 250, // Increased height for the modal
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Select a number:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (widget.isTwoDigit) ...[
                      Container(
                        height: 40, // Fixed height for the input area
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter a two-digit number (10-99)',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          onSubmitted: (_) => _submitNumber(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_errorMessage !=
                          null) // Display error message if it exists
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submitNumber,
                        child: const Text('Submit'),
                      ),
                    ] else ...[
                      Expanded(
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                widget.onNumberSelected?.call(index);
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F4B7A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF4A90E2),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    index.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
      child: const Text('Select Number'),
    );
  }
}
