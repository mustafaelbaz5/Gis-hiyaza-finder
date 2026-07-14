import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions/context_ext.dart';
import '../../../../core/utils/spacing.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../data/models/parcel.dart';
import '../../data/repository/holdings_repository.dart';
import '../widgets/parcel_detail_card.dart';

/// Full record for one holding. If the holding has multiple parcels they
/// are all stacked in one scrollable view, each with its own compass and
/// fields (per the chosen UX — no per-parcel sub-routing).
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.parcels});

  final List<Parcel> parcels;

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;
    final HoldingsRepository repository = getIt<HoldingsRepository>();
    final String holdingId = parcels.isNotEmpty ? parcels.first.holdingId : '';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: rw(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(16),
              Row(
                children: [
                  const AppBackButton(),
                  horizontalSpacing(12),
                  Expanded(
                    child: Text(
                      'holdings.detail.title'.tr(namedArgs: {'id': holdingId}),
                      style: AppTextStyles.font20Bold.copyWith(
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              verticalSpacing(20),
              if (parcels.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: rh(32)),
                  child: Center(
                    child: Text(
                      'holdings.detail.empty'.tr(),
                      style: AppTextStyles.font16Regular.copyWith(
                        color: colors.textHint,
                      ),
                    ),
                  ),
                )
              else
                for (final (int i, Parcel parcel) in parcels.indexed) ...[
                  ParcelDetailCard(
                    parcel: parcel,
                    resolveBorder: (final String text) =>
                        repository.resolveBorder(text),
                    onNavigate: (final String neighborId) =>
                        _navigateToHolding(context, repository, neighborId),
                    animationDelay: Duration(milliseconds: i * 80),
                  ),
                  verticalSpacing(16),
                ],
              verticalSpacing(16),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHolding(
    final BuildContext context,
    final HoldingsRepository repository,
    final String holdingId,
  ) {
    final List<Parcel> neighborParcels = repository.parcelsForHolding(
      holdingId,
    );
    context.pushNamed(Routes.holdingDetail, arguments: neighborParcels);
  }
}
