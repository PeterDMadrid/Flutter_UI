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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Set up a listener that will check the value immediately
    _controller.addListener(() {
      // Only validate for two-digit mode
      if (!widget.isTwoDigit) return;

      final text = _controller.text;

      // Skip empty text
      if (text.isEmpty) {
        setState(() {
          _errorMessage = null;
        });
        return;
      }

      // Try to parse the input as an integer
      final number = int.tryParse(text);

      // Invalid number (non-numeric)
      if (number == null) {
        setState(() {
          _errorMessage = 'Please enter a valid number.';
        });
        return;
      }

      // Check if the number is outside the valid range (10-99)
      if (number < 10) {
        setState(() {
          _errorMessage = 'Please enter a two-digit number (10-99).';
        });
      } else if (number > 99) {
        setState(() {
          _errorMessage = 'Number must be between 10 and 99.';
        });
      } else {
        // Valid number
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  void _submitNumber() {
    final input = _controller.text;

    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a two-digit number (10-99).';
      });
      return;
    }

    final number = int.tryParse(input);
    if (number == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number.';
      });
      return;
    }

    if (number < 10 || number > 99) {
      setState(() {
        _errorMessage = 'Please enter a two-digit number (10-99).';
      });
      return;
    }

    widget.onNumberSelected?.call(number);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1F4B7A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        // Clear previous input and error
        _controller.clear();
        setState(() {
          _errorMessage = null;
        });

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFF102A43),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    height: 250,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Select a number:",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (widget.isTwoDigit) ...[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF0D1B2A).withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              maxLength: 2,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Enter a two-digit number (10-99)',
                                labelStyle: const TextStyle(
                                  color: Color(0xFF4E6E8E),
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                counterText: '',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() {
                                      _errorMessage = null;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _errorMessage != null
                                        ? Colors.red.withOpacity(0.5)
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _errorMessage != null
                                        ? Colors.red
                                        : const Color(0xFF4A90E2),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              onSubmitted: (_) => _submitNumber(),
                              // Directly update on every change, forcing rebuild
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setModalState(() {
                                    _errorMessage = null;
                                  });
                                  return;
                                }

                                final number = int.tryParse(value);
                                if (number == null) {
                                  setModalState(() {
                                    _errorMessage =
                                        'Please enter a valid number.';
                                  });
                                  return;
                                }

                                if (number < 10) {
                                  setModalState(() {
                                    _errorMessage =
                                        'Please enter a two-digit number (10-99).';
                                  });
                                } else if (number > 99) {
                                  setModalState(() {
                                    _errorMessage =
                                        'Number must be between 10 and 99.';
                                  });
                                } else {
                                  setModalState(() {
                                    _errorMessage = null;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 24,
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: _errorMessage != null
                                ? Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 200,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _submitNumber,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Single digit grid view (unchanged)
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
        );
      },
      child: const Text('Select Number'),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }
}
