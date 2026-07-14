import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions/context_ext.dart';

/// A 3×3 "compass" — the holding ID sits in the center, its four borders
/// (north/south/east/west) surround it. A border becomes tappable when the
/// caller resolves it to a neighboring holding ID via [resolveBorder].
///
/// The middle row is forced to LTR so west/east always render on the
/// geographically correct side regardless of the app's RTL layout.
class BorderCompass extends StatelessWidget {
  const BorderCompass({
    super.key,
    required this.holdingId,
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    required this.resolveBorder,
    required this.onNavigate,
  });

  final String holdingId;
  final String? north;
  final String? south;
  final String? east;
  final String? west;

  /// Returns the neighboring holding ID for a border's text, or `null` if
  /// it isn't a confident match (not navigable).
  final String? Function(String borderText) resolveBorder;
  final void Function(String holdingId) onNavigate;

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        _BorderCell(label: 'شمال (البحري)', text: north, resolved: _resolve(north)),
        const SizedBox(height: 8),
        Row(
          textDirection: TextDirection.ltr,
          children: [
            Expanded(
              child: _BorderCell(
                label: 'غرب (الغربي)',
                text: west,
                resolved: _resolve(west),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CenterCell(holdingId: holdingId),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _BorderCell(
                label: 'شرق (الشرقي)',
                text: east,
                resolved: _resolve(east),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _BorderCell(label: 'جنوب (القبلي)', text: south, resolved: _resolve(south)),
      ],
    );
  }

  ({String holdingId, VoidCallback onTap})? _resolve(final String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final String? neighborId = resolveBorder(text);
    if (neighborId == null || neighborId == holdingId) return null;
    return (holdingId: neighborId, onTap: () => onNavigate(neighborId));
  }
}

class _CenterCell extends StatelessWidget {
  const _CenterCell({required this.holdingId});

  final String holdingId;

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primary200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.crop_square_rounded, color: AppColors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            '#$holdingId',
            style: AppTextStyles.font14Bold.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BorderCell extends StatelessWidget {
  const _BorderCell({
    required this.label,
    required this.text,
    required this.resolved,
  });

  final String label;
  final String? text;
  final ({String holdingId, VoidCallback onTap})? resolved;

  bool get _isNavigable => resolved != null;

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;
    final String displayText = (text == null || text!.trim().isEmpty)
        ? '—'
        : text!;

    return InkWell(
      onTap: resolved?.onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: _isNavigable ? colors.infoBackground : colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isNavigable ? colors.info : colors.border,
            width: _isNavigable ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.font12Regular.copyWith(color: colors.textHint),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isNavigable) ...[
                  Icon(Icons.touch_app_rounded, size: 14, color: colors.info),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    displayText,
                    style: AppTextStyles.font14SemiBold.copyWith(
                      color: _isNavigable ? colors.info : colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
