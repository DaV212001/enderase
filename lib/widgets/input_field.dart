import 'package:flutter/material.dart';

class InputFieldWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final FocusNode? focusNode;
  final String? Function(String? val) validator;
  final void Function(String? val)? onChanged;
  final void Function(String? val)? onSaved;
  bool obscureText;
  final Widget? prefixIcon;
  final String? label;
  final bool passwordInput;
  final TextInputType? textInputType;
  final String? hint;
  final int? maxLength;

  InputFieldWidget({
    super.key,
    required this.textEditingController,
    required this.focusNode,
    required this.obscureText,
    required this.validator,
    required this.passwordInput,
    this.label,
    this.textInputType,
    this.prefixIcon,
    this.onChanged,
    this.hint,
    this.maxLength,
    this.onSaved,
  });

  @override
  State<InputFieldWidget> createState() => _InputFieldWidgetState();
}

class _InputFieldWidgetState extends State<InputFieldWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.passwordInput) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
        child: SizedBox(
          width: double.infinity,
          child: TextFormField(
            controller: widget.textEditingController,
            // style: const TextStyle(color: Colors.black),
            focusNode: widget.focusNode,
            autofocus: false,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            keyboardType: widget.textInputType,
            onSaved: widget.onSaved,
            autofillHints: const [AutofillHints.password],
            obscureText: !widget.obscureText,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: const TextStyle(fontSize: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF4B39EF),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              suffixIcon: InkWell(
                onTap: () =>
                    setState(() => widget.obscureText = !widget.obscureText),
                focusNode: FocusNode(skipTraversal: true),
                child: Icon(
                  widget.obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
              errorMaxLines: 2,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validator,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
        child: SizedBox(
          width: double.infinity,
          child: TextFormField(
            controller: widget.textEditingController,
            focusNode: widget.focusNode,
            // style: const TextStyle(color: Colors.black),
            autofocus: false,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            autofillHints: const [AutofillHints.password],
            obscureText: widget.obscureText,

            onSaved: widget.onSaved,
            keyboardType: widget.textInputType,
            decoration: InputDecoration(
              icon: widget.prefixIcon,
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: const TextStyle(fontSize: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF4B39EF),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validator,
          ),
        ),
      );
    }
  }
}
