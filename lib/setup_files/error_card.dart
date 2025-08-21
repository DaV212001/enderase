import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'error_data.dart';

class ErrorCard extends StatelessWidget {
  final ErrorData errorData;
  final VoidCallback? refresh;
  final double? imageHeight;
  final double? imageWidth;
  final double? buttonHeight;
  final double? buttonWidth;

  const ErrorCard({
    super.key,
    this.refresh,
    required this.errorData,
    this.imageHeight,
    this.imageWidth,
    this.buttonHeight,
    this.buttonWidth,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          errorData.image,
          width: imageWidth ?? MediaQuery.of(context).size.width * 0.4,
          height: imageHeight ?? MediaQuery.of(context).size.width * 0.4,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            errorData.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (errorData.body.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Text(
              errorData.body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.unselectedWidgetColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 10),
        buildButton(errorData.buttonText),
      ],
    );
  }

  Widget buildButton(String? text) {
    if (text == null || refresh == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: buttonWidth ?? 300,
      height: buttonHeight ?? 40,
      child: ElevatedButton(
        onPressed: refresh,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
