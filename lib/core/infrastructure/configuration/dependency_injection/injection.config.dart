// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cotizacion_dm/core/domain/cotization/cotization.dart' as _i9;
import 'package:cotizacion_dm/core/domain/domain.dart' as _i11;
import 'package:cotizacion_dm/core/domain/employee/employee.dart' as _i13;
import 'package:cotizacion_dm/core/domain/liquidation/liquidation.dart' as _i16;
import 'package:cotizacion_dm/core/infrastructure/configuration/cache/cache_service.dart'
    as _i8;
import 'package:cotizacion_dm/core/infrastructure/configuration/cache/cotization/cache_cotization_service.dart'
    as _i6;
import 'package:cotizacion_dm/core/infrastructure/configuration/cache/employee/cache_employee_service.dart'
    as _i7;
import 'package:cotizacion_dm/core/infrastructure/configuration/pdf/pdf_cotization_service.dart'
    as _i3;
import 'package:cotizacion_dm/core/infrastructure/configuration/sqlite/cotization/sqlite_cotization_repository.dart'
    as _i10;
import 'package:cotizacion_dm/core/infrastructure/configuration/sqlite/employee/sqlite_employee_repository.dart'
    as _i12;
import 'package:cotizacion_dm/core/infrastructure/configuration/sqlite/liquidation/sqlite_liquidation_repository.dart'
    as _i14;
import 'package:cotizacion_dm/core/infrastructure/configuration/sqlite/sqlite_provider.dart'
    as _i4;
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart' as _i15;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i5;

import 'modules.dart' as _i17;

/// ignore_for_file: unnecessary_lambdas
/// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of main-scope dependencies inside of [GetIt]
Future<_i1.GetIt> init(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final appModules = _$AppModules();
  gh.factory<_i3.PDFCotizationService>(() => _i3.MainPDFCotizationService());
  gh.factory<_i4.SQLiteProvider>(() => _i4.MainSQLiteProvider());
  await gh.factoryAsync<_i5.SharedPreferences>(
    () => appModules.prefs,
    preResolve: true,
  );
  gh.factory<_i6.SharedPreferencesCacheCotizationService>(() =>
      _i6.SharedPreferencesCacheCotizationService(gh<_i5.SharedPreferences>()));
  gh.factory<_i7.SharedPreferencesCacheEmployeeService>(() =>
      _i7.SharedPreferencesCacheEmployeeService(gh<_i5.SharedPreferences>()));
  gh.factory<_i8.CacheService>(
      () => _i8.CacheService(gh<_i5.SharedPreferences>()));
  gh.factory<_i9.CotizationRepository>(
      () => _i10.SQLiteCotizationRepository(gh<_i4.SQLiteProvider>()));
  gh.factory<_i9.CotizationService>(
      () => _i9.DomainCotizationService(gh<_i9.CotizationRepository>()));
  gh.factory<_i11.EmployeeRepository>(
      () => _i12.SQLiteEmployeeRepository(gh<_i4.SQLiteProvider>()));
  gh.factory<_i13.EmployeeService>(
      () => _i13.DomainEmployeeService(gh<_i13.EmployeeRepository>()));
  gh.factory<_i11.LiquidationRepository>(
      () => _i14.SQLiteLiquidationRepository(gh<_i15.SQLiteProvider>()));
  gh.factory<_i16.LiquidationService>(
      () => _i16.DomainLiquidationService(gh<_i16.LiquidationRepository>()));
  return getIt;
}

class _$AppModules extends _i17.AppModules {}
