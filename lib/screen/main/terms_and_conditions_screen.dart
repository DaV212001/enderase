import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/digital_signature_widget.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  final Function(bool accepted, Uint8List? signature)? onTermsAccepted;

  const TermsAndConditionsScreen({
    super.key,
    this.onTermsAccepted,
  });

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool _termsAccepted = false;
  Uint8List? _signature;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSignatureChanged(Uint8List? signature) {
    setState(() {
      _signature = signature;
    });
  }

  void _acceptAndContinue() {
    if (!_termsAccepted) {
      Get.snackbar(
        'error'.tr,
        'must_accept_terms'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_signature == null) {
      Get.snackbar(
        'error'.tr,
        'signature_required'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    widget.onTermsAccepted?.call(_termsAccepted, _signature);
    Get.back(result: {'accepted': _termsAccepted, 'signature': _signature});
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('terms_and_conditions'.tr),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Terms content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'matif_terms_title'.tr,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'location_addis_ababa'.tr,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Terms sections
                  _buildSection(
                    'introduction'.tr,
                    'welcome_to_matif'.tr,
                  ),

                  _buildSection(
                    'service_description'.tr,
                    'matif_description'.tr,
                  ),

                  Text(
                    'matif_not_employer'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'verification_required'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    'user_eligibility'.tr,
                    'age_requirement'.tr,
                  ),

                  Text(
                    'fayda_registration'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'employer_requirements'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'worker_requirements'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    'client_responsibilities'.tr,
                    '',
                  ),

                  _buildListItem('job_description_requirement'.tr),
                  _buildListItem('respect_workers'.tr),
                  _buildListItem('safe_environment'.tr),
                  _buildListItem('timely_payments'.tr),
                  _buildListItem('comply_labor_laws'.tr),
                  const SizedBox(height: 16),

                  _buildSection(
                    'worker_responsibilities'.tr,
                    '',
                  ),

                  _buildListItem('honest_information'.tr),
                  _buildListItem('professional_service'.tr),
                  _buildListItem('respect_property'.tr),
                  _buildListItem('no_illegal_activities'.tr),
                  const SizedBox(height: 16),

                  _buildSection(
                    'verification_security'.tr,
                    'fayda_verification'.tr,
                  ),

                  Text(
                    'background_checks'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'misuse_consequences'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    'payments_fees'.tr,
                    'service_fee'.tr,
                  ),

                  Text(
                    'payment_method'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'unpaid_wages_disclaimer'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    'dispute_resolution'.tr,
                    'report_disputes'.tr,
                  ),

                  Text(
                    'mediation_attempt'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'legal_disputes'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    'ratings_feedback'.tr,
                    'provide_ratings'.tr,
                  ),

                  Text(
                    'fair_ratings'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'false_feedback'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    'prohibited_activities'.tr,
                    'users_may_not'.tr,
                  ),

                  _buildListItem('no_fake_ids'.tr),
                  _buildListItem('no_illegal_services'.tr),
                  _buildListItem('no_account_sharing'.tr),
                  _buildListItem('no_discrimination'.tr),
                  const SizedBox(height: 16),

                  _buildSection(
                    'limitation_liability'.tr,
                    'as_is_basis'.tr,
                  ),

                  Text(
                    'matif_not_liable'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),

                  _buildListItem('injury_damage'.tr),
                  _buildListItem('misconduct_negligence'.tr),
                  _buildListItem('outside_platform'.tr),
                  _buildListItem('theft_loss'.tr),
                  _buildListItem('platform_communication'.tr),
                  _buildListItem('report_within_24h'.tr),
                  const SizedBox(height: 16),

                  _buildSection(
                    'account_termination'.tr,
                    'violation_consequences'.tr,
                  ),

                  Text(
                    'account_deactivation'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    'privacy_policy'.tr,
                    'data_collection'.tr,
                  ),

                  Text(
                    'data_protection'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    'governing_law'.tr,
                    'ethiopian_law'.tr,
                  ),

                  _buildSection(
                    'acceptance'.tr,
                    'terms_acceptance'.tr,
                  ),

                  // Signature section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'signature'.tr,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: DigitalSignatureWidget(
                            width: MediaQuery.of(context).size.width - 64,
                            height: 150,
                            onSignatureChanged: _onSignatureChanged,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${'date'.tr}: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Extra space for bottom buttons
                ],
              ),
            ),
          ),

          // Bottom section with checkbox and button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: Text('i_agree'.tr),
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _acceptAndContinue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'accept_and_continue'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
