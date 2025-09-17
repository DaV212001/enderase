import 'package:flutter/material.dart';

class BookingStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const BookingStepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isEven) {
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < currentStep;
              final isCurrent = stepIndex == currentStep;
              return CircleAvatar(
                radius: 14,
                backgroundColor: isCompleted || isCurrent
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        "${stepIndex + 1}",
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.black,
                        ),
                      ),
              );
            } else {
              return Expanded(
                child: Divider(
                  color: index ~/ 2 < currentStep
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  thickness: 2,
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps
              .map(
                (s) => Expanded(
                  child: Text(
                    s,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
