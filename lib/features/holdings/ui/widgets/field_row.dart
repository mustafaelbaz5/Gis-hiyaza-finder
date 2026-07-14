import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions/context_ext.dart';

/// Label + value row with a copy-to-clipboard icon. Values are large and
/// bold per the sunlight-readability requirement (base ≥18sp, bold values).
class FieldRow extends StatelessWidget {
  const FieldRow({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String? value;
  final bool showDivider;

  static const String _emptyPlaceholder = '—';

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;
    final String displayValue =
        (value == null || value!.trim().isEmpty) ? _emptyPlaceholder : value!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.font14Regular.copyWith(
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayValue,
                      style: AppTextStyles.font18Bold.copyWith(
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: displayValue == _emptyPlaceholder
                    ? null
                    : () => _copy(context, displayValue),
                icon: Icon(
                  Icons.copy_rounded,
                  size: 22,
                  color: displayValue == _emptyPlaceholder
                      ? colors.iconSecondary
                      : AppColors.primary200,
                ),
                tooltip: 'نسخ',
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, thickness: 1, color: colors.divider),
      ],
    );
  }

  Future<void> _copy(final BuildContext context, final String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      HapticFeedback.lightImpact();
      context.showSuccessSnackBar('holdings.detail.copied'.tr());
    }
  }
}
