import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

class DigitalSignatureWidget extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color penColor;
  final double strokeWidth;
  final Function(Uint8List?) onSignatureChanged;

  const DigitalSignatureWidget({
    super.key,
    this.width = 300,
    this.height = 150,
    this.backgroundColor = Colors.white,
    this.penColor = Colors.black,
    this.strokeWidth = 2.0,
    required this.onSignatureChanged,
  });

  @override
  State<DigitalSignatureWidget> createState() => _DigitalSignatureWidgetState();
}

class _DigitalSignatureWidgetState extends State<DigitalSignatureWidget> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: widget.strokeWidth,
      penColor: widget.penColor,
      exportBackgroundColor: widget.backgroundColor,
    );

    // 👇 listen to changes in strokes
    _controller.addListener(() async {
      if (_controller.isNotEmpty) {
        Uint8List? data = await _controller.toPngBytes();
        widget.onSignatureChanged(data);
      } else {
        widget.onSignatureChanged(null);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSignatureChanged(null);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSignature() {
    _controller.clear();
    widget.onSignatureChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: widget.backgroundColor,
      ),
      child: Column(
        children: [
          // Signature pad
          Expanded(
            child: Signature(
              controller: _controller,
              backgroundColor: widget.backgroundColor,
              width: widget.width,
              height: widget.height - 40,
            ),
          ),
          // Footer row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'sign_here'.tr,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, _, __) {
                    return _controller.isNotEmpty
                        ? TextButton(
                      onPressed: _clearSignature,
                      child: Text(
                        'clear_signature'.tr,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 12),
                      ),
                    )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
