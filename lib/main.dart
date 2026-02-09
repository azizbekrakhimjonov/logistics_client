// import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:logistic/constants/colors.dart';
// import 'package:logistic/repositories/auth_repositories.dart';

import 'constants/app_theme.dart';
import 'generated/codegen_loader.g.dart';
import 'routes.dart';
import 'di/locator.dart';
import 'screens/error/server_error_page.dart';
import 'utils/health_service.dart';
import 'utils/navigation_services.dart';
import 'utils/shared_pref.dart';

//shaxboz
//tegma desa ham tegadiye

final snackBarKey = GlobalKey<ScaffoldMessengerState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    // print('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    // print('onEvent -- ${bloc.runtimeType}, $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) print('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // print('onTransition -- ${bloc.runtimeType}, $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) print('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    // print('onClose -- ${bloc.runtimeType}');
  }
}

Future<void> main() async {
  dynamic initialRoute;
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await locatorSetUp();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColor.primary, // transparent status bar
    statusBarBrightness: Brightness.light,
    // statusBarIconBrightness: Brightness.dark // dark text for status bar
  ));
  final serverHealthy = await HealthService.check();
  var token = await SharedPref().read('token') ?? '';
  if (kDebugMode) print("Token.: ${token}");
  if (token.isEmpty) {
    initialRoute = Routes.login;
  } else {
    initialRoute = Routes.mainScreen;
  }
  // ignore: deprecated_member_use
  BlocOverrides.runZoned(
    () {
      runApp(
        EasyLocalization(
          supportedLocales: const [
            Locale('ru'),
            Locale('uz'),
          ],
          path: 'assets/translations',
          fallbackLocale: const Locale('ru'),
          startLocale: const Locale('ru'),
          assetLoader: const CodegenLoader(),
          useOnlyLangCode: true,
          child:
              MyApp(initialRoute: initialRoute, serverHealthy: serverHealthy),
        ),
      );
    },
    blocObserver: kDebugMode ? MyBlocObserver() : null,
  );
}

class MyApp extends StatefulWidget {
  final dynamic initialRoute;
  final bool serverHealthy;

  const MyApp({Key? key, this.initialRoute, this.serverHealthy = true})
      : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _serverHealthy;

  @override
  void initState() {
    super.initState();
    _serverHealthy = widget.serverHealthy;
    initialization();
  }

  void initialization() async {
    FlutterNativeSplash.remove();
  }

  Future<void> _retryHealth() async {
    final ok = await HealthService.check();
    if (ok && mounted) {
      setState(() => _serverHealthy = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColor.primary,
      statusBarBrightness: Brightness.light,
    ));
    if (!_serverHealthy) {
      return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: ServerErrorPage(onRetry: _retryHealth),
      );
    }
    return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        theme: themeData,
        scaffoldMessengerKey: snackBarKey,
        navigatorObservers: [routeObserver],
        initialRoute: widget.initialRoute,
        routes: Routes.routes,
        navigatorKey: NavigationService.instance.navigationKey);
  }
}
