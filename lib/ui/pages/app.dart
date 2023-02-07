import 'package:cotizacion_dm/ui/bloc/bloc.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/transitions/transitions.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import '../../globals.dart';

part 'listeners.dart';
part 'routing.dart';

class AppState extends StatelessWidget {
  CotizationService get cotizationService => getIt();
  QueryCotizationService get queryCotizationService => getIt();
  SharedPreferencesCacheCotizationService get cacheCotizationService => getIt();
  EmployeeService get employeeService => getIt();
  SharedPreferencesCacheEmployeeService get cacheEmployeeService => getIt();
  LiquidationService get liquidationService => getIt();
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // App Services
        BlocProvider(create: (_) => SetupPropertiesCubit()),
        BlocProvider(create: (_) => SnackbarBloc()),
        // Features
        BlocProvider(
            create: (_) => FetchCotizationCubit(cotizationService,
                cacheCotizationService, queryCotizationService)),
        BlocProvider(
            create: (_) =>
                FetchEmployeeCubit(employeeService, cacheEmployeeService)),
        BlocProvider(
          create: (context) => FetchLiquidationsCubit(liquidationService),
        ),
      ],
      child: const MyMaterialApp(),
    );
  }
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: titleApp,
      scaffoldMessengerKey: messagerKey,
      theme: ThemeUtility.light,
      navigatorObservers: [routeObserver],
      home:
          const AppListener(child: RouteAwareWidget(child: InitialRootPage())),
    );
  }
}
