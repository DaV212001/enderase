import 'package:enderase/screen/main/provider_detail/layout/booking_form.dart';
import 'package:enderase/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/category.dart';

class DynamicForm extends StatefulWidget {
  final List<RuleSchema> rules;
  final BookingController bookingController;
  final void Function(Map<String, dynamic> values, String notes) onSubmit;

  const DynamicForm({
    super.key,
    required this.rules,
    required this.onSubmit,
    required this.bookingController,
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final Map<String, dynamic> values = {};

  /// Persist text controllers for all inputs
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController _getController(String key, [String? initial]) {
    if (_controllers.containsKey(key)) return _controllers[key]!;
    _controllers[key] = TextEditingController(text: initial ?? '');
    return _controllers[key]!;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    notesController.dispose();
    super.dispose();
  }

  TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: Form(
          key: widget.bookingController.formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const Text(
                    //   'Job Details',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(height: 20),
                    ...widget.rules.where((r) => !r.isItemRule).map((rule) {
                      RuleSchema? itemRule;
                      try {
                        itemRule = widget.rules.firstWhere(
                          (r) => r.key == '${rule.baseKey}.*',
                        );
                      } catch (_) {
                        itemRule = null;
                      }

                      final mergedOptions = rule.options.isNotEmpty
                          ? rule.options
                          : (itemRule?.options ?? []);

                      // ✅ Boolean → Switch
                      if (rule.isBoolean) {
                        values[rule.baseKey] = values[rule.baseKey] ?? false;
                        widget.bookingController.formAnswers[rule.baseKey] =
                            values[rule.baseKey] ?? false;
                        return SwitchListTile(
                          title: Text(rule.label),
                          value: values[rule.baseKey],
                          onChanged: (val) {
                            setState(() => values[rule.baseKey] = val);
                            widget.bookingController.formAnswers[rule.baseKey] =
                                val;
                          },
                        );
                      }

                      // ✅ Enum (single select) → Dropdown
                      if (!rule.isArray && mergedOptions.isNotEmpty) {
                        values[rule.baseKey] =
                            values[rule.baseKey] ?? mergedOptions.first;
                        widget.bookingController.formAnswers[rule.baseKey] =
                            values[rule.baseKey] ?? mergedOptions.first;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: DropdownButtonFormField<String>(
                            value: values[rule.baseKey],
                            decoration: InputDecoration(
                              labelText: rule.label,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
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
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            items: mergedOptions
                                .map(
                                  (opt) => DropdownMenuItem(
                                    value: opt,
                                    child: Text(opt.tr),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() => values[rule.baseKey] = val);
                              widget.bookingController.formAnswers[rule
                                      .baseKey] =
                                  val;
                            },
                            validator: (val) {
                              if (rule.isRequired &&
                                  (val == null || val.isEmpty)) {
                                return "Required";
                              }
                              return null;
                            },
                            onSaved: (val) {
                              values[rule.baseKey] = val;
                              widget.bookingController.formAnswers[rule
                                      .baseKey] =
                                  val;
                            },
                          ),
                        );
                      }

                      // ✅ Array of enums → Multi-select (checkboxes)
                      if (rule.isArray && mergedOptions.isNotEmpty) {
                        values[rule.baseKey] =
                            (values[rule.baseKey] ?? <String>[])
                                as List<String>;
                        widget.bookingController.formAnswers[rule.baseKey] =
                            (values[rule.baseKey] ?? <String>[])
                                as List<String>;

                        return FormField<List<String>>(
                          initialValue: List<String>.from(values[rule.baseKey]),
                          validator: (list) {
                            final count = list?.length ?? 0;
                            if (rule.isRequired && count == 0) {
                              return "Required";
                            }
                            if (rule.min != null && count < rule.min!) {
                              return "Select at least ${rule.min}";
                            }
                            return null;
                          },
                          onSaved: (list) {
                            values[rule.baseKey] = list ?? <String>[];
                            widget.bookingController.formAnswers[rule.baseKey] =
                                list ?? <String>[];
                          },
                          builder: (state) {
                            final selected = List<String>.from(
                              values[rule.baseKey],
                            );
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    rule.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...mergedOptions.map((opt) {
                                  final isChecked = selected.contains(opt);
                                  return CheckboxListTile(
                                    title: Text(opt.tr),
                                    value: isChecked,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          selected.add(opt);
                                        } else {
                                          selected.remove(opt);
                                        }
                                        values[rule.baseKey] = selected;
                                      });
                                      widget.bookingController.formAnswers[rule
                                              .baseKey] =
                                          selected;
                                      state.didChange(selected);
                                    },
                                  );
                                }),
                                if (state.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      state.errorText!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      }

                      // ✅ Array of free text → comma separated input
                      if (rule.isArray) {
                        final controller = _getController(rule.baseKey);
                        return InputFieldWidget(
                          textEditingController: controller,
                          focusNode: FocusNode(),
                          obscureText: false,
                          label: "${rule.label} (comma separated)",
                          validator: (val) {
                            if (rule.isRequired &&
                                (val == null || val.isEmpty)) {
                              return "Required";
                            }
                            final items = (val ?? '')
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();

                            if (rule.min != null && items.length < rule.min!) {
                              return "Enter at least ${rule.min} item(s)";
                            }
                            final itemMax = itemRule?.maxLength;
                            if (itemMax != null &&
                                items.any((s) => s.length > itemMax)) {
                              return "Each item max length is $itemMax";
                            }
                            return null;
                          },
                          passwordInput: false,
                          onSaved: (val) {
                            values[rule.baseKey] = (val ?? '')
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();
                            widget.bookingController.formAnswers[rule.baseKey] =
                                (val ?? '')
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();
                          },
                          onChanged: (val) {
                            values[rule.baseKey] = (val ?? '')
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();
                            widget.bookingController.formAnswers[rule.baseKey] =
                                (val ?? '')
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();
                          },
                        );
                      }

                      // ✅ Number (with min/max)
                      if (rule.isNumber) {
                        final controller = _getController(
                          rule.baseKey,
                          values[rule.baseKey]?.toString(),
                        );
                        return InputFieldWidget(
                          textEditingController: controller,
                          focusNode: FocusNode(),
                          obscureText: false,
                          textInputType: TextInputType.number,
                          label: rule.label,
                          validator: (val) {
                            if (rule.isRequired &&
                                (val == null || val.isEmpty)) {
                              return "Required";
                            }
                            final parsed = int.tryParse(val ?? '');
                            if (parsed == null) {
                              return "Enter a valid number";
                            }
                            if (rule.min != null && parsed < rule.min!) {
                              return "Minimum is ${rule.min}";
                            }
                            if (rule.max != null && parsed > rule.max!) {
                              return "Maximum is ${rule.max}";
                            }
                            return null;
                          },
                          onSaved: (val) {
                            values[rule.baseKey] = int.tryParse(val ?? '') ?? 0;
                            widget.bookingController.formAnswers[rule.baseKey] =
                                int.tryParse(val ?? '') ?? 0;
                          },
                          onChanged: (val) {
                            values[rule.baseKey] = int.tryParse(val ?? '') ?? 0;
                            widget.bookingController.formAnswers[rule.baseKey] =
                                int.tryParse(val ?? '') ?? 0;
                          },
                          passwordInput: false,
                        );
                      }

                      // ✅ Default string
                      final controller = _getController(
                        rule.baseKey,
                        values[rule.baseKey],
                      );
                      return InputFieldWidget(
                        textEditingController: controller,
                        focusNode: FocusNode(),
                        obscureText: false,
                        label: rule.label,
                        validator: (val) {
                          if (rule.isRequired && (val == null || val.isEmpty)) {
                            return "Required";
                          }
                          if (rule.maxLength != null &&
                              val != null &&
                              val.length > rule.maxLength!) {
                            return "Max length is ${rule.maxLength}";
                          }
                          return null;
                        },
                        onSaved: (val) {
                          values[rule.baseKey] = val ?? '';
                          widget.bookingController.formAnswers[rule.baseKey] =
                              val ?? '';
                        },
                        onChanged: (val) {
                          values[rule.baseKey] = val ?? '';
                          widget.bookingController.formAnswers[rule.baseKey] =
                              val ?? '';
                          return;
                        },
                        passwordInput: false,
                      );
                    }),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        maxLines: 3,
                        controller: notesController,
                        onChanged: (val) =>
                            widget.bookingController.notesReceived.value = val,
                        decoration: const InputDecoration(
                          labelText: "Additional Notes",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       Logger().d(widget.bookingController.formAnswers);
                    //       Logger().d(
                    //         widget.bookingController.notesReceived.value,
                    //       );
                    //       if (_formKey.currentState!.validate()) {
                    //         _formKey.currentState!.save();
                    //         widget.onSubmit(values, notesController.text);
                    //       }
                    //     },
                    //     child: const Text(
                    //       "Submit Answers",
                    //       style: TextStyle(color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
