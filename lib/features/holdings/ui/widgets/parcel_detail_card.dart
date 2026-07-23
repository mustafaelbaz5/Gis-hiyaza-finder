import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
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
    this.onEdit,
    this.isEdited = false,
    this.animationDelay = Duration.zero,
  });

  final Parcel parcel;
  final String? Function(String borderText) resolveBorder;
  final void Function(String holdingId) onNavigate;
  final VoidCallback? onEdit;
  final bool isEdited;
  final Duration animationDelay;

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
          CustomTextButton.outlined(
            text: 'holdings.detail.copy_all'.tr(),
            prefixIcon: const Icon(
              Icons.copy_all_rounded,
              color: AppColors.primary200,
            ),
            onPressed: () => _copyAll(context),
          ),
          verticalSpacing(16),
          if (onEdit != null) ...<Widget>[
            Row(
              children: <Widget>[
                if (isEdited)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.amber200.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.edit_note_rounded,
                          size: 16,
                          color: AppColors.amber300,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'holdings.edit.edited_badge'.tr(),
                          style: AppTextStyles.font12Bold.copyWith(
                            color: AppColors.amber300,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary50.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: AppColors.primary200,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'holdings.edit.edit_button'.tr(),
                          style: AppTextStyles.font12Bold.copyWith(
                            color: AppColors.primary200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            verticalSpacing(12),
          ],
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
                FieldRow(
                  label: 'holdings.detail.holding_id'.tr(),
                  value: parcel.holdingId,
                ),
                FieldRow(label: 'اسم الحائز', value: parcel.holderName),
                FieldRow(label: 'الرقم القومي', value: parcel.nationalId),
                FieldRow(label: 'اسم الحوض', value: parcel.basinName),
                FieldRow(label: 'كود الحوض', value: parcel.basinCode),
                FieldRow(label: 'المديرية', value: parcel.directorate),
                FieldRow(label: 'الإدارة', value: parcel.administration),
                FieldRow(label: 'رقم الأرض', value: parcel.landNumber),
                FieldRow(
                  label: 'holdings.detail.feddan'.tr(),
                  value: _formatNumber(parcel.feddan),
                ),
                FieldRow(
                  label: 'holdings.detail.qirat'.tr(),
                  value: _formatNumber(parcel.qirat),
                ),
                FieldRow(
                  label: 'holdings.detail.sahm'.tr(),
                  value: _formatNumber(parcel.sahm),
                ),
                FieldRow(
                  label: 'holdings.detail.total_sqm'.tr(),
                  value: _formatNumber(parcel.totalSqm),
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: animationDelay)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.04, end: 0);
  }

  /// `null`/empty values are formatted with [FieldRow.emptyPlaceholder] so
  /// the on-screen display and the copy-all text stay consistent.
  String? _formatNumber(final double? value) {
    if (value == null) return null;
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  String _areaSummary(final Parcel p) {
    final String feddan = _formatNumber(p.feddan) ?? FieldRow.emptyPlaceholder;
    final String qirat = _formatNumber(p.qirat) ?? FieldRow.emptyPlaceholder;
    final String sahm = _formatNumber(p.sahm) ?? FieldRow.emptyPlaceholder;
    final String sqm =
        _formatNumber(p.totalSqm) ?? FieldRow.emptyPlaceholder;
    return '$feddan فدان، $qirat قيراط، $sahm سهم ≈ $sqm م²';
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
    String dash(final String? v) =>
        (v == null || v.trim().isEmpty) ? FieldRow.emptyPlaceholder : v;

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
