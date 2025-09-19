import 'package:enderase/config/storage_config.dart';
import 'package:enderase/controllers/bookings_controller.dart';
import 'package:enderase/models/booking.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_card.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:enderase/widgets/cards/booking/booking_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../../constants/assets.dart';
import '../../../constants/pages.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Logger().d(ConfigPreference.getUserToken());
    final BookingsController bookingsController = Get.put(BookingsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('my_bookings'.tr),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => bookingsController.refreshBookings(),
          ),
        ],
      ),
      body: Obx(() {
        if (bookingsController.loadingBookings.value == ApiCallStatus.loading) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return BookingCard(
                booking: Booking(
                  id: 0,
                  clientId: 0,
                  providerId: 0,
                  categoryId: 0,
                  startTime: '2021-09-08 00:00:00',
                  endTime: '2022-09-09 00:00:00',
                  notes: 'Sample notes',
                  status: 'pending',
                  createdAt: '2025-08-16T09:27:05.000000Z',
                ),
                isShimmer: true,
              );
            },
          );
        }

        if (bookingsController.bookings.isEmpty) {
          return Center(
            child: ErrorCard(
              errorData: ErrorData(
                title: 'no_bookings_found'.tr,
                buttonText: 'refresh'.tr,
                body: 'no_bookings_description'.tr,
                image: Assets.emptyCart,
              ),
              refresh: () => bookingsController.refreshBookings(),
            ),
          );
        }

        return ListView.builder(
          controller: bookingsController.scrollController,
          itemCount:
              bookingsController.bookings.length +
              (bookingsController.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == bookingsController.bookings.length) {
              // Loading indicator at bottom for pagination
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final booking = bookingsController.bookings[index];
            return InkWell(
              onTap: () {
                Get.toNamed(
                  AppRoutes.bookingDetailRoute,
                  arguments: {
                    'id': booking.id,
                    'providerName': booking.providerDisplayName,
                    'categoryName': booking.categoryDisplayName,
                    'avatar': booking.provider != null
                        ? booking.provider!['profile_picture']
                        : null,
                  },
                );
              },
              child: BookingCard(booking: booking, isShimmer: false),
            );
          },
        );
      }),
    );
  }
}
