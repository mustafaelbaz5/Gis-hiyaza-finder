import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/settings/ui/settings_sheet.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions/context_ext.dart';
import '../../../../core/utils/spacing.dart';
import '../../../../core/widgets/custom_text_button.dart';
import '../../../../core/widgets/custom_text_form_.dart';
import '../../data/repository/holdings_repository.dart';
import '../../logic/cubit/home_cubit.dart';
import '../../logic/cubit/home_state.dart';
import '../../logic/services/holding_search_service.dart';
import '../widgets/basin_filter_sheet.dart';
import '../widgets/recommendation_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(final String query, final HomeCubit cubit) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      cubit.search(query);
    });
  }

  void _openHistory() => context.pushNamed(Routes.fileHistory);

  Future<void> _openBasinFilter(final HomeCubit cubit) async {
    final HomeState state = cubit.state;
    final String? selected = await showBasinFilterSheet(
      context,
      basins: state.availableBasins,
      selected: state.selectedBasin,
    );
    if (selected != state.selectedBasin) {
      cubit.selectBasin(selected);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;
    final HomeCubit cubit = context.read<HomeCubit>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<HomeCubit, HomeState>(
          listenWhen: (final HomeState previous, final HomeState current) =>
              current.status == HomeStatus.loaded &&
              previous.status != HomeStatus.loaded &&
              current.availableBasins.length > 1,
          listener: (final BuildContext context, final HomeState state) {
            _openBasinFilter(cubit);
          },
          builder: (final BuildContext context, final HomeState state) {
            return Column(
              children: <Widget>[
                _HomeTopBar(
                  onSettings: () => showSettingsSheet(context),
                  onHistory: _openHistory,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: KeyedSubtree(
                      key: ValueKey<HomeStatus>(state.status),
                      child: switch (state.status) {
                        HomeStatus.loading => const _LoadingBody(),
                        HomeStatus.noFile => _EmptyBody(
                          onPickFile: cubit.pickFile,
                        ),
                        HomeStatus.error => _ErrorBody(
                          state: state,
                          onPickFile: cubit.pickFile,
                        ),
                        HomeStatus.loaded => _LoadedBody(
                          state: state,
                          controller: _controller,
                          cubit: cubit,
                          onQueryChanged: (final String q) =>
                              _onQueryChanged(q, cubit),
                          onOpenBasinFilter: () => _openBasinFilter(cubit),
                        ),
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({required this.onSettings, required this.onHistory});

  final VoidCallback onSettings;
  final VoidCallback onHistory;

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(12), vertical: rh(8)),
      child: Row(
        children: <Widget>[
          _TopBarIconButton(
            icon: Icons.settings_rounded,
            tooltip: 'settings.title'.tr(),
            onTap: onSettings,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.landscape_rounded,
                  color: AppColors.primary200,
                  size: 22,
                ),
                horizontalSpacing(6),
                Text(
                  'holdings.home.brand'.tr(),
                  style: AppTextStyles.font20Bold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _TopBarIconButton(
            icon: Icons.history_rounded,
            tooltip: 'holdings.home.history'.tr(),
            onTap: onHistory,
          ),
        ],
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.iconPrimary, size: 22),
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(final BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary200),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.onPickFile});

  final VoidCallback onPickFile;

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rw(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                  padding: EdgeInsets.all(rw(28)),
                  decoration: BoxDecoration(
                    color: AppColors.primary50.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_open_rounded,
                    size: rf(64),
                    color: AppColors.primary200,
                  ),
                )
                .animate()
                .fadeIn(duration: 350.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                  duration: 400.ms,
                ),
            verticalSpacing(24),
            Text(
              'holdings.empty.title'.tr(),
              style: AppTextStyles.font20Bold.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpacing(8),
            Text(
              'holdings.empty.desc'.tr(),
              style: AppTextStyles.font16Regular.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpacing(32),
            CustomTextButton(
              text: 'holdings.empty.pick_file'.tr(),
              onPressed: onPickFile,
              prefixIcon: const Icon(
                Icons.upload_file_rounded,
                color: AppColors.white,
              ),
              isFullWidth: false,
              size: CustomButtonSize.large,
            ),
          ],
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.state, required this.onPickFile});

  final HomeState state;
  final VoidCallback onPickFile;

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;
    final bool isColumnsError = state.missingColumns.isNotEmpty;
    final String message = isColumnsError
        ? 'holdings.error.invalid_file'.tr(
            namedArgs: {'columns': state.missingColumns.join('، ')},
          )
        : (state.errorMessage ?? 'holdings.error.generic'.tr());

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rw(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(rw(24)),
              decoration: BoxDecoration(
                color: AppColors.red200.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: rf(56),
                color: AppColors.red200,
              ),
            ).animate().shake(duration: 400.ms, hz: 4),
            verticalSpacing(20),
            Text(
              message,
              style: AppTextStyles.font16SemiBold.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpacing(28),
            CustomTextButton(
              text: 'holdings.error.pick_another'.tr(),
              onPressed: onPickFile,
              isFullWidth: false,
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.state,
    required this.controller,
    required this.cubit,
    required this.onQueryChanged,
    required this.onOpenBasinFilter,
  });

  final HomeState state;
  final TextEditingController controller;
  final HomeCubit cubit;
  final void Function(String query) onQueryChanged;
  final VoidCallback onOpenBasinFilter;

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final bool isTablet = constraints.maxWidth >= 600;
        final double horizontalPadding = isTablet ? rw(64) : rw(16);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              verticalSpacing(8),
              _FileInfoCard(
                holdingCount: state.holdingCount,
                selectedBasin: state.selectedBasin,
                hasBasins: state.availableBasins.isNotEmpty,
                onChangeFile: cubit.changeFile,
                onOpenBasinFilter: onOpenBasinFilter,
              ),
              verticalSpacing(16),
              CustomTextForm(
                hintText: 'holdings.search.hint'.tr(),
                controller: controller,
                isRTL: true,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.iconSecondary,
                ),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.iconSecondary,
                        ),
                        onPressed: () {
                          controller.clear();
                          onQueryChanged('');
                        },
                      ),
                onChanged: onQueryChanged,
              ),
              verticalSpacing(16),
              RecommendationList(
                query: state.query,
                results: state.results,
                onSelect: (final SearchResult result) =>
                    _openDetail(context, result),
              ),
              verticalSpacing(24),
            ],
          ).animate().fadeIn(duration: 250.ms),
        );
      },
    );
  }

  void _openDetail(final BuildContext context, final SearchResult result) {
    final HoldingsRepository repository = getIt<HoldingsRepository>();
    context.pushNamed(
      Routes.holdingDetail,
      arguments: repository.parcelsForHolding(result.holdingId),
    );
  }
}

class _FileInfoCard extends StatelessWidget {
  const _FileInfoCard({
    required this.holdingCount,
    required this.selectedBasin,
    required this.hasBasins,
    required this.onChangeFile,
    required this.onOpenBasinFilter,
  });

  final int holdingCount;
  final String? selectedBasin;
  final bool hasBasins;
  final VoidCallback onChangeFile;
  final VoidCallback onOpenBasinFilter;

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;

    return Container(
      padding: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary50.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dataset_rounded,
                  color: AppColors.primary200,
                ),
              ),
              horizontalSpacing(12),
              Expanded(
                child: Text(
                  'holdings.home.holdings_loaded'.tr(
                    namedArgs: {'count': holdingCount.toString()},
                  ),
                  style: AppTextStyles.font18Bold.copyWith(
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          if (hasBasins) ...<Widget>[
            verticalSpacing(12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _InlineAction(
                    icon: Icons.filter_alt_rounded,
                    label: selectedBasin == null
                        ? 'holdings.basin.all'.tr()
                        : 'holdings.basin.focus_label'.tr(
                            namedArgs: {'basin': selectedBasin!},
                          ),
                    onTap: onOpenBasinFilter,
                    highlighted: selectedBasin != null,
                  ),
                ),
                horizontalSpacing(10),
                Expanded(
                  child: _InlineAction(
                    icon: Icons.swap_horiz_rounded,
                    label: 'holdings.home.change_file'.tr(),
                    onTap: onChangeFile,
                  ),
                ),
              ],
            ),
          ] else ...<Widget>[
            verticalSpacing(12),
            _InlineAction(
              icon: Icons.swap_horiz_rounded,
              label: 'holdings.home.change_file'.tr(),
              onTap: onChangeFile,
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineAction extends StatelessWidget {
  const _InlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.primary50.withValues(alpha: 0.3)
              : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted ? AppColors.primary200 : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 18, color: AppColors.primary200),
            horizontalSpacing(6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.font12Bold.copyWith(
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
