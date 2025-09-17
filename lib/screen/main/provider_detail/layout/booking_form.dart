import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:enderase/controllers/user_controller.dart';
import 'package:enderase/setup_files/templates/dio_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';

import '../../../../config/storage_config.dart';
import '../../../../models/category.dart';
import '../../../../models/provider.dart';
import '../../../../setup_files/wrappers/cached_image_widget_wrapper.dart';
import '../../../../utils/schedule_validation_helper.dart';
import 'booking_step_indicator.dart';
import 'category_selection.dart';
import 'dynamic_form_generator_from_rules_schema.dart';
import 'schedule_picker.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingController controller;
  final providerId;

  BookingConfirmationScreen({super.key, required this.providerId})
    : controller = Get.find<BookingController>(tag: providerId.toString());

  String _formatDate(DateTime? dt) =>
      dt == null ? "-" : DateFormat("EEE, MMM d, yyyy").format(dt);

  String _formatTime(DateTime? dt) =>
      dt == null ? "-" : DateFormat("HH:mm").format(dt);

  @override
  Widget build(BuildContext context) {
    Logger().d(UserController.user.value.id);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Your Booking"),
        centerTitle: true,
      ),
      body: Obx(() {
        final type = controller.bookingType.value;
        Provider provider = Get.arguments;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cachedNetworkImageWrapper(
                    imageUrl: provider.profilePicture ?? '',
                    height: MediaQuery.of(context).size.width * 0.15,
                    width: MediaQuery.of(context).size.width * 0.15,
                    imageBuilder: (context, imageProvider) =>
                        CircularImageHolder(
                          image: Image.network(
                            provider.profilePicture ?? '',
                            height: MediaQuery.of(context).size.width * 0.15,
                            width: MediaQuery.of(context).size.width * 0.15,
                            fit: BoxFit.cover,
                          ),
                        ),
                    placeholderBuilder: (context, string) {
                      return Container(
                        height: MediaQuery.of(context).size.width * 0.15,
                        width: MediaQuery.of(context).size.width * 0.15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                    errorWidgetBuilder: (context, path, obj) {
                      return Container(
                        height: MediaQuery.of(context).size.width * 0.15,
                        width: MediaQuery.of(context).size.width * 0.15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          // color: Theme.of(context).primaryColor,
                        ),
                        child: Icon(
                          Icons.person_2_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: AutoSizeText(
                              (provider.firstName ?? '') +
                                  (provider.lastName ?? ''),
                              maxFontSize: 16,
                              minFontSize: 9,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey,
                              size: 15,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: AutoSizeText(
                                '${provider.subcity} ${provider.city}, ${provider.woreda ?? ''}',
                                maxFontSize: 10,
                                minFontSize: 4,
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 8.0,
                                top: 2.0,
                              ),
                              child: RatingBarIndicator(
                                rating: provider.rating ?? 0.0,
                                itemBuilder: (context, index) => Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 15.0,
                                direction: Axis.horizontal,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: AutoSizeText(
                                '${provider.rating}',
                                maxFontSize: 11,
                                minFontSize: 7,
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(),
              // ----- Booking type card -----
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      type == "one_time"
                          ? Ionicons.time_outline
                          : type == 'recurring'
                          ? Ionicons.calendar_outline
                          : Icons.work,
                      color: Colors.blue,
                    ),
                  ),
                  title: Text(
                    type == "one_time"
                        ? "One-Time Booking"
                        : type == 'recurring'
                        ? "Recurring Booking"
                        : "Full-Time Booking",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    type == "one_time"
                        ? "This booking will happen once at the selected time"
                        : type == 'recurring'
                        ? "This booking will repeat on selected days and times"
                        : "This booking will be available for the entire day, unless edited",
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ----- Date/Time Section -----
              if (type == "one_time") ...[
                _buildSectionCard(
                  title: "Date & Time",
                  children: [
                    _infoRow(
                      "Start",
                      "${_formatDate(controller.oneTimeStart.value)} • ${_formatTime(controller.oneTimeStart.value)}",
                    ),
                    _infoRow(
                      "End",
                      "${_formatDate(controller.oneTimeEnd.value)} • ${_formatTime(controller.oneTimeEnd.value)}",
                    ),
                  ],
                ),
              ] else ...[
                _buildSectionCard(
                  title: "Schedule Duration",
                  children: [
                    _infoRow(
                      "Start Date",
                      _formatDate(controller.startDate.value),
                    ),
                    _infoRow(
                      "End Date",
                      controller.indefinite.value
                          ? "Indefinite"
                          : _formatDate(controller.endDate.value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: "Recurrence",
                  children: [
                    _infoRow(
                      "Frequency",
                      (controller.frequency.value ?? "-").tr,
                    ),
                    _infoRow("Interval", "${controller.interval.value ?? 1}"),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: "Time Windows",
                  children: controller.windows.entries.expand((entry) {
                    final weekday = entry.key;
                    return entry.value.map(
                      (w) => ListTile(
                        dense: true,
                        leading: const Icon(Ionicons.time_outline, size: 20),
                        title: Text(
                          "${DateFormat('EEEE').format(DateTime(2023, 1, 02 + int.parse(weekday) - 1))}: ${w['start']} - ${w['end']}",
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 16),

              // ----- Notes & Category -----
              _buildSectionCard(
                title: "Additional Info",
                children: [
                  _infoRow(
                    "Category",
                    controller.selectedCategory.value?.categoryName ?? "-",
                  ),
                  _infoRow(
                    "Notes",
                    controller.notesReceived.value.isEmpty
                        ? "-"
                        : controller.notesReceived.value,
                  ),
                ],
              ),

              const SizedBox(height: 80), // space for bottom button
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: controller.confirming.value
                  ? null
                  : () => controller.confirmBooking(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: controller.confirming.value
                  ? null
                  : const Icon(
                      Ionicons.checkmark_circle_outline,
                      color: Colors.white,
                    ),
              label: Obx(
                () => controller.confirming.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Confirm Booking",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable info section card
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  // Key-Value display
  Widget _infoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}

class BookingController extends GetxController {
  // ---------- Validation helpers (put inside ScheduleController) ----------
  ScheduleValidationHelper scheduleValidationHelper =
      ScheduleValidationHelper();
  String? validateWindow({
    required int weekday,
    required String start, // "HH:mm"
    required String end, // "HH:mm"
    Map<int, List<Map<String, String>>>?
    candidateWindows, // default to controller.windows
    int? indexToIgnore, // when editing an existing window, ignore this index
  }) {
    return scheduleValidationHelper.validateWindow(
      weekday: weekday,
      start: start,
      end: end,
      providerBusyTimes: providerBusyTimes,
      windows: windows,
    );
  }

  /// Validate all windows before submit; returns first error string or null
  String? validateAllWindows() {
    return scheduleValidationHelper.validateAllWindows(
      providerBusyTimes,
      windows,
    );
  }

  // State carried forward
  var formAnswers = {}.obs;
  var notesReceived = "".obs;
  var selectedCategory = Rxn<Category>();
  var currentStep = 0.obs;
  final formKey = GlobalKey<FormState>();
  var payload = <String, dynamic>{}.obs;

  Rx<String> bookingType = 'one_time'.obs;
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  Rx<bool> indefinite = false.obs;
  Rx<DateTime?> oneTimeStart = Rx<DateTime?>(null);
  Rx<DateTime?> oneTimeEnd = Rx<DateTime?>(null);
  Rx<String?> frequency = 'weekly'.obs;
  Rx<int?> interval = 1.obs;
  var providerBusyTimes = <DateTimeRange>[].obs;
  var windows = <String, List<Map<String, String>>>{}.obs;
  void updatePayload({
    required int providerIdReceived,
    int? categoryIdReceived,
    required String bookingTypeReceived,
    DateTime? startDateReceived,
    DateTime? endDateReceived,
    required bool indefiniteReceived,
    DateTime? oneTimeStartReceived,
    DateTime? oneTimeEndReceived,
    String? frequencyReceived,
    int? intervalReceived,
    Map<String, List<Map<String, String>>>? windowsReceived,
    List<DateTimeRange>? providerBusyTimesReceived,
  }) {
    bookingType.value = bookingTypeReceived;
    startDate.value = startDateReceived;
    endDate.value = endDateReceived;
    indefinite.value = indefiniteReceived;
    oneTimeStart.value = oneTimeStartReceived;
    oneTimeEnd.value = oneTimeEndReceived;
    frequency.value = frequencyReceived;
    interval.value = intervalReceived;
    windows.value = windowsReceived ?? {};
    providerBusyTimes.value = providerBusyTimesReceived ?? [];

    final newPayload = {
      "provider_id": providerIdReceived,
      "category_id": (selectedCategory.value?.id) ?? 0,
      "timezone": "Africa/Addis_Ababa",
    };

    if (bookingTypeReceived == "one_time") {
      newPayload["schedule"] = {
        "type": "one_time",
        "one_time_start": oneTimeStartReceived?.toIso8601String(),
        "one_time_end": oneTimeEndReceived?.toIso8601String(),
      };
      // if (oneTimeStartReceived != null) {
      //   newPayload["start_date"] = DateFormat(
      //     "yyyy-MM-dd",
      //   ).format(oneTimeStartReceived);
      // }
    } else {
      if (startDateReceived != null) {
        newPayload["start_date"] = DateFormat(
          "yyyy-MM-dd",
        ).format(startDateReceived);
      }

      newPayload["indefinite"] = indefiniteReceived;
      if (endDateReceived != null) {
        newPayload["end_date"] = DateFormat(
          "yyyy-MM-dd",
        ).format(endDateReceived);
      }
      newPayload["schedule"] = {
        "type": bookingTypeReceived,
        "frequency": frequencyReceived,
        "interval": intervalReceived,
        "windows": windowsReceived,
      };
    }
    payload.value = newPayload;
  }

  bool validateForm() {
    if (bookingType.value == 'one_time') {
      // Validate one-time has both start and end
      return oneTimeStart.value != null && oneTimeEnd.value != null;
    } else {
      // Validate recurring/full-time has start date and windows
      if (startDate.value == null) return false;
      if (!indefinite.value && endDate.value == null) {
        return false;
      }
      // Full-time always has windows (set automatically)
      return bookingType.value == 'full_time' || windows.isNotEmpty;
    }
  }

  void createBooking() {
    if (validateForm()) {
      final err = validateAllWindows();
      if (err != null) {
        Get.snackbar(
          "Invalid schedule",
          err,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      Provider provider = Get.arguments;
      Get.to(
        BookingConfirmationScreen(providerId: provider.id),
        arguments: provider,
      );
      Logger().d(payload);
    } else {
      Get.snackbar(
        "Incomplete Information",
        "Please fill all required fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  var confirming = false.obs;
  void confirmBooking() async {
    confirming.value = true;
    payload['notes'] = notesReceived.value;
    payload['meta'] = formAnswers;
    Map<String, dynamic> payloadBody = payload;
    await DioService.dioPost(
      path: '/api/v1/client/booking',
      data: payloadBody,
      options: Options(
        headers: {'Authorization': 'Bearer ${ConfigPreference.getUserToken()}'},
      ),
      onSuccess: (response) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          Provider provider = Get.arguments;
          Get.snackbar(
            "Booking Created",
            "You have successfully booked ${provider.firstName} as a ${selectedCategory.value?.categoryName ?? ''}",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            "Error",
            "Something went wrong: ${response.data['message']}",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        confirming.value = false;
      },
      onFailure: (error, response) {
        Get.snackbar(
          "Error",
          "Something went wrong",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        confirming.value = false;
      },
    );
  }
}

class BookingFlow extends StatefulWidget {
  final List<Category> categories;
  final int providerId;
  final BookingController controller;
  BookingFlow({super.key, required this.categories, required this.providerId})
    : controller = Get.put(BookingController(), tag: providerId.toString());

  @override
  State<BookingFlow> createState() => _BookingFlowState();
}

class _BookingFlowState extends State<BookingFlow> {
  int currentStep = 0;

  Category? selectedCategory;
  Map<String, dynamic> formAnswers = {};
  String notesReceived = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BookingStepIndicator(
                currentStep: currentStep,
                steps: const ["Category", "Details", "Schedule"],
              ),
            ),
            // Divider(),
            Expanded(
              child: IndexedStack(
                index: currentStep,
                children: [
                  // Step 1: Category
                  CategorySelection(
                    categories: widget.categories,
                    onCategorySelected: (cat) {
                      setState(() {
                        selectedCategory = cat;
                        widget.controller.selectedCategory.value = cat;
                        currentStep = 1;
                      });
                    },
                  ),

                  // Step 2: Dynamic Form
                  if (selectedCategory != null)
                    DynamicForm(
                      rules: selectedCategory!.rulesSchema ?? [],
                      bookingController: widget.controller,
                      onSubmit: (vals, notes) {
                        setState(() {
                          formAnswers = vals;
                          notesReceived = notes;
                          currentStep = 2;
                        });
                      },
                    )
                  else
                    const SizedBox.shrink(),

                  // Step 3: Schedule Picker with Notes
                  if (selectedCategory != null)
                    SchedulePicker(
                      providerId: widget.providerId,
                      categoryId: selectedCategory!.id ?? 0,
                      onFinalize: (payload) {
                        // Inject notes + meta
                        payload["notes"] = notesReceived;
                        payload["meta"] = formAnswers;

                        Get.snackbar(
                          "Booking Ready",
                          "Payload constructed successfully",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );

                        debugPrint(payload.toString());
                      },
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
            Column(
              children: [
                if (currentStep == 2)
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ElevatedButton(
                        onPressed: widget.controller.createBooking,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        child: const Text(
                          "Create Booking",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentStep == 0) const SizedBox(height: 10),
                    if (currentStep > 0)
                      //Previous button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentStep > 0) {
                              setState(() => currentStep--);
                            }
                          },
                          child: const Text(
                            "Previous",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    if (currentStep < 2)
                      //Next button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentStep == 1) {
                              if (widget.controller.formKey.currentState!
                                  .validate()) {
                                setState(() {
                                  currentStep++;
                                });
                              } else {
                                Get.snackbar(
                                  "Validation Error",
                                  "Please fill in all required fields",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            } else if (currentStep < 2) {
                              setState(() => currentStep++);
                            }
                          },
                          child: const Text(
                            "Next",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    if (currentStep == 2) const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
