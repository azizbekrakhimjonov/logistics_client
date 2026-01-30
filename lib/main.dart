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
  var token = await SharedPref().read('token') ?? '';
  if (kDebugMode) print("Token.: ${token}");
  if (token.isEmpty) {
    initialRoute = Routes.login;
  } else {
    initialRoute = Routes.mainScreen;
  }
  // SharedPref().save("token", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjk3NzMzODk3LCJpYXQiOjE2NzE4MTM4OTcsImp0aSI6ImQxOTQxNGY5MGFhMzQ4ZGZiMDQ0ZWRiNWY1NmQyODlmIiwidXNlcl9pZCI6ImZhZjQwMjg0LTk0NWItNGMxMC1hZThjLWU4ODFiOGVlN2ViMiJ9.Latbqz8crhssbwIOki39G8wNf8pTlsxsnH129vZp6EM");
  // SharedPref().save("user", "3ebba04d-1713-45bf-888a-5d733e4aaf85");
  // await _getId();
  // ignore: deprecated_member_use
  BlocOverrides.runZoned(
    () {
      runApp(
        EasyLocalization(
          supportedLocales: const [
            Locale('ru'),
            Locale('uz'),
          ],
          path:
              'assets/translations', // <-- change the path of the translation files
          fallbackLocale: const Locale('ru'),
          startLocale: const Locale('ru'),
          assetLoader: const CodegenLoader(),
          useOnlyLangCode: true,
          child: MyApp(initialRoute: initialRoute),
        ),
        //  MyApp(initialRoute: initialRoute)
      );
    },
    blocObserver: kDebugMode ? MyBlocObserver() : null,
  );
}

class MyApp extends StatefulWidget {
  final dynamic initialRoute;

  const MyApp({Key? key, this.initialRoute}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColor.primary, // transparent status bar
      statusBarBrightness: Brightness.light,
      // statusBarIconBrightness: Brightness.dark // dark text for status bar
    ));
    return MaterialApp(
        // useInheritedMediaQuery: true,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        // builder: DevicePreview.appBuilder,
        theme: themeData,
        scaffoldMessengerKey: snackBarKey,
        navigatorObservers: [routeObserver],
        initialRoute: widget.initialRoute, //Routes.mainScreen,
        routes: Routes.routes,
        navigatorKey: NavigationService.instance.navigationKey);
    // navigatorKey: NavigationService.instance.navigationKey);
  }
}
