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
import 'parcel_edit_screen.dart';

/// Full record for one holding. If the holding has multiple parcels they
/// are all stacked in one scrollable view, each with its own compass and
/// fields (per the chosen UX — no per-parcel sub-routing).
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.parcels});

  final List<Parcel> parcels;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final HoldingsRepository _repository = getIt<HoldingsRepository>();
  late List<Parcel> _parcels;

  @override
  void initState() {
    super.initState();
    _parcels = List<Parcel>.of(widget.parcels);
  }

  Future<void> _editParcel(final Parcel parcel) async {
    final Parcel? edited = await Navigator.push<Parcel>(
      context,
      MaterialPageRoute<Parcel>(
        builder: (final _) => ParcelEditScreen(parcel: parcel),
      ),
    );
    if (edited == null) return;

    await _repository.updateParcel(edited);
    final int idx = _parcels.indexWhere((final Parcel p) => p.id == edited.id);
    if (idx >= 0) {
      setState(() => _parcels[idx] = edited);
    }
    if (mounted) context.showSuccessSnackBar('holdings.edit.saved'.tr());
  }

  void _navigateToHolding(final String holdingId) {
    final List<Parcel> neighborParcels = _repository.parcelsForHolding(
      holdingId,
    );
    context.pushNamed(Routes.holdingDetail, arguments: neighborParcels);
  }

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;
    final String holdingId = _parcels.isNotEmpty
        ? _parcels.first.holdingId
        : '';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: rw(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              verticalSpacing(16),
              Row(
                children: <Widget>[
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
              if (_parcels.isEmpty)
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
                for (final (int i, Parcel parcel) in _parcels.indexed) ...<Widget>[
                  ParcelDetailCard(
                    parcel: parcel,
                    isEdited: _repository.isParcelEdited(parcel.id),
                    resolveBorder: (final String text) =>
                        _repository.resolveBorder(text),
                    onNavigate: _navigateToHolding,
                    onEdit: () => _editParcel(parcel),
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
}
