import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/router/routes.dart';
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

  void _openHistory(final BuildContext context) {
    context.pushNamed(Routes.fileHistory);
  }

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;
    final HomeCubit cubit = context.read<HomeCubit>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (final BuildContext context, final HomeState state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey<HomeStatus>(state.status),
                child: switch (state.status) {
                  HomeStatus.loading => const _LoadingBody(),
                  HomeStatus.noFile => _EmptyBody(
                    onPickFile: cubit.pickFile,
                    onShowHistory: () => _openHistory(context),
                  ),
                  HomeStatus.error => _ErrorBody(
                    state: state,
                    onPickFile: cubit.pickFile,
                    onShowHistory: () => _openHistory(context),
                  ),
                  HomeStatus.loaded => _LoadedBody(
                    state: state,
                    controller: _controller,
                    cubit: cubit,
                    onQueryChanged: (final String q) =>
                        _onQueryChanged(q, cubit),
                    onShowHistory: () => _openHistory(context),
                  ),
                },
              ),
            );
          },
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
  const _EmptyBody({required this.onPickFile, required this.onShowHistory});

  final VoidCallback onPickFile;
  final VoidCallback onShowHistory;

  @override
  Widget build(final BuildContext context) {
    final colors = context.customColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rw(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                  Icons.folder_open_rounded,
                  size: rf(88),
                  color: colors.iconSecondary,
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
            verticalSpacing(12),
            TextButton.icon(
              onPressed: onShowHistory,
              icon: const Icon(Icons.history_rounded, color: AppColors.primary200),
              label: Text(
                'holdings.home.history'.tr(),
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: AppColors.primary200,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.state,
    required this.onPickFile,
    required this.onShowHistory,
  });

  final HomeState state;
  final VoidCallback onPickFile;
  final VoidCallback onShowHistory;

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
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: rf(72),
              color: AppColors.red200,
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
            verticalSpacing(12),
            TextButton.icon(
              onPressed: onShowHistory,
              icon: const Icon(Icons.history_rounded, color: AppColors.primary200),
              label: Text(
                'holdings.home.history'.tr(),
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: AppColors.primary200,
                ),
              ),
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
    required this.onShowHistory,
  });

  final HomeState state;
  final TextEditingController controller;
  final HomeCubit cubit;
  final void Function(String query) onQueryChanged;
  final VoidCallback onShowHistory;

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
            children: [
              verticalSpacing(16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'holdings.home.holdings_loaded'.tr(
                        namedArgs: {'count': state.holdingCount.toString()},
                      ),
                      style: AppTextStyles.font18Bold.copyWith(
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  IconButton(
                    onPressed: onShowHistory,
                    tooltip: 'holdings.home.history'.tr(),
                    icon: const Icon(
                      Icons.history_rounded,
                      color: AppColors.primary200,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: cubit.changeFile,
                    icon: const Icon(
                      Icons.swap_horiz_rounded,
                      color: AppColors.primary200,
                    ),
                    label: Text(
                      'holdings.home.change_file'.tr(),
                      style: AppTextStyles.font14SemiBold.copyWith(
                        color: AppColors.primary200,
                      ),
                    ),
                  ),
                ],
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
