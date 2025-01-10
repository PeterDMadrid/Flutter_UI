import 'package:flutter/material.dart';

class NumberSelection extends StatefulWidget {
  final Function(int)? onNumberSelected;

  const NumberSelection({
    super.key,
    this.onNumberSelected,
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
          backgroundColor: const Color(0xFF102A43),
          builder: (BuildContext context) {
            return Container(
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
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
