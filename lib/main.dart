import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workmanager/workmanager.dart';
import 'core/background/background_tasks.dart';
import 'core/lifecycle/app_lifecycle_observer.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/router_refresh_stream.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/dependency_injection.dart';
import 'core/utils/logger.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/lifecycle/lifecycle_bloc.dart';
import 'presentation/bloc/localization/localization_bloc.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    AppLogger.info('Background task executed: $task');

    switch (task) {
      case BackgroundTasks.periodicSyncTask:
        await BackgroundTasks.performPeriodicSync();
        break;
      case BackgroundTasks.notificationTask:
        await BackgroundTasks.showScheduledNotification();
        break;
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background tasks
  await Workmanager().initialize(callbackDispatcher);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  await configureDependencies();

  // Initialize logging
  AppLogger.init();

  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatefulWidget {
  const SmartCampusApp({super.key});

  @override
  State<SmartCampusApp> createState() => _SmartCampusAppState();
}

class _SmartCampusAppState extends State<SmartCampusApp>
    with WidgetsBindingObserver {
  late AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lifecycleObserver = getIt<AppLifecycleObserver>();
    _lifecycleObserver.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleObserver.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleObserver.handleLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<AuthBloc>()..add(AppStarted())),
          BlocProvider(create: (_) => getIt<LifecycleBloc>()),
          BlocProvider(
            create: (_) => getIt<LocalizationBloc>()..add(LoadLocalization()),
          ),
        ],
        child: Builder(
          builder: (context) {
            // Wire the AuthBloc stream to the router so it re-evaluates
            // the redirect logic whenever auth state changes.
            AppRouter.setRefreshStream(
              context.read<AuthBloc>().stream,
            );
            return BlocBuilder<LocalizationBloc, LocalizationState>(
              builder: (context, localizationState) => MaterialApp.router(
                  title: 'SmartCampus Companion',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  locale: localizationState.locale,
                  supportedLocales: const [
                    Locale('en', 'US'),
                    Locale('fr', 'FR'),
                    Locale('ar', 'SA'),
                  ],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routerConfig: AppRouter.router,
                ),
            );
          },
        ),
      ),
  );
}
