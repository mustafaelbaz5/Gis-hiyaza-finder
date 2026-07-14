import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/extensions/context_ext.dart';
import '../../../../core/utils/spacing.dart';
import '../../../../core/widgets/custom_text_button.dart';
import '../../data/models/parcel.dart';
import 'border_compass.dart';
import 'field_row.dart';

/// One parcel's full record: border compass + field rows + copy-all.
/// Detail screens stack one of these per parcel belonging to a holding.
class ParcelDetailCard extends StatelessWidget {
  const ParcelDetailCard({
    super.key,
    required this.parcel,
    required this.resolveBorder,
    required this.onNavigate,
  });

  final Parcel parcel;
  final String? Function(String borderText) resolveBorder;
  final void Function(String holdingId) onNavigate;

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;

    return Container(
      padding: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BorderCompass(
            holdingId: parcel.holdingId,
            north: parcel.borderNorth,
            south: parcel.borderSouth,
            east: parcel.borderEast,
            west: parcel.borderWest,
            resolveBorder: resolveBorder,
            onNavigate: onNavigate,
          ),
          verticalSpacing(16),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                FieldRow(label: 'اسم الحائز', value: parcel.holderName),
                FieldRow(label: 'الرقم القومي', value: parcel.nationalId),
                FieldRow(label: 'اسم الحوض', value: parcel.basinName),
                FieldRow(label: 'كود الحوض', value: parcel.basinCode),
                FieldRow(label: 'المديرية', value: parcel.directorate),
                FieldRow(label: 'الإدارة', value: parcel.administration),
                FieldRow(label: 'رقم الأرض', value: parcel.landNumber),
                FieldRow(
                  label: 'المساحة',
                  value: _areaSummary(parcel),
                  showDivider: false,
                ),
              ],
            ),
          ),
          verticalSpacing(16),
          CustomTextButton.outlined(
            text: 'holdings.detail.copy_all'.tr(),
            prefixIcon: const Icon(Icons.copy_all_rounded, color: AppColors.primary200),
            onPressed: () => _copyAll(context),
          ),
        ],
      ),
    );
  }

  String _areaSummary(final Parcel p) {
    final String feddan = _formatNumber(p.feddan);
    final String qirat = _formatNumber(p.qirat);
    final String sahm = _formatNumber(p.sahm);
    final String sqm = p.totalSqm == null
        ? '—'
        : _formatNumber(p.totalSqm);
    return '$feddan فدان، $qirat قيراط، $sahm سهم ≈ $sqm م²';
  }

  String _formatNumber(final double? value) {
    if (value == null) return '0';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  Future<void> _copyAll(final BuildContext context) async {
    final String text = _formatForClipboard(parcel);
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      HapticFeedback.mediumImpact();
      context.showSuccessSnackBar('holdings.detail.copied'.tr());
    }
  }

  String _formatForClipboard(final Parcel p) {
    String dash(final String? v) => (v == null || v.trim().isEmpty) ? '—' : v;

    return '''
رقم الحيازة: ${p.holdingId}
الحائز: ${dash(p.holderName)}
الرقم القومي: ${dash(p.nationalId)}
الحوض: ${dash(p.basinName)}
رقم الأرض: ${dash(p.landNumber)}
المساحة: ${_areaSummary(p)}
الحدود: شمال(${dash(p.borderNorth)}) جنوب(${dash(p.borderSouth)}) شرق(${dash(p.borderEast)}) غرب(${dash(p.borderWest)})''';
  }
}
