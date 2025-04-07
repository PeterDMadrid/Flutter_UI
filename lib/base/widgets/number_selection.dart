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
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    (widget.isTwoDigit ? 0.7 : 0.3),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select a Number",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: widget.isTwoDigit ? 89 : 10,
                      itemBuilder: (context, index) {
                        final number = widget.isTwoDigit ? index + 11 : index;
                        return InkWell(
                          onTap: () {
                            widget.onNumberSelected?.call(number);
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
                                number.toString(),
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
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
      child: const Text('Select Number'),
    );
  }
}
