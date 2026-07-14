import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/router/routes.dart';
import 'core/settings/cubit/app_settings_cubit.dart';
import 'core/settings/cubit/app_settings_state.dart';
import 'core/themes/theme_data/theme_data_dark.dart';
import 'core/themes/theme_data/theme_data_light.dart';

class HiyazaFinderApp extends StatelessWidget {
  const HiyazaFinderApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (final BuildContext context, final Widget? child) {
        return BlocProvider(
          create: (final _) => AppSettingsCubit(),
          child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder:
                (final BuildContext context, final AppSettingsState settings) {
              return MaterialApp(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: settings.locale, // driven by cubit
                debugShowCheckedModeBanner: false,
                initialRoute: Routes.aboutScreen,
                onGenerateRoute: AppRouter.generateRoute,
                title: AppConfig.appName,
                // font family injected into both themes
                theme: getLightTheme().copyWith(
                  textTheme: getLightTheme()
                      .textTheme
                      .apply(fontFamily: settings.fontFamily),
                ),
                darkTheme: getDarkTheme().copyWith(
                  textTheme: getDarkTheme()
                      .textTheme
                      .apply(fontFamily: settings.fontFamily),
                ),
                themeMode: settings.themeMode,
              );
            },
          ),
        );
      },
    );
  }
}
