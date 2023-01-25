import 'dart:convert';

import 'package:cotizacion_dm/core/infrastructure/configuration/configuration.dart';
import 'package:cotizacion_dm/core/infrastructure/configuration/sqlite/sqlite_provider.dart';
import 'package:equatable/equatable.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PayType extends Equatable {
  final String name;
  final int days;

  const PayType(this.name, this.days);

  factory PayType.fromMap(Map<String, dynamic> map) {
    return PayType(
      map["name"] as String,
      map["days"] as int,
    );
  }

  factory PayType.fromString(String encode) {
    var map = jsonDecode(encode);
    return PayType.fromMap(map);
  }

  Map<String, dynamic> toMap() => {
        "name": name,
        "days": days,
      };

  @override
  String toString() {
    return jsonEncode(toMap());
  }

  @override
  // TODO: implement props
  List<Object?> get props => [name, days];
}

class TaxPercentOption extends Equatable {
  final String name;
  final double percent;

  const TaxPercentOption(this.name, this.percent);

  factory TaxPercentOption.fromMap(Map<String, dynamic> map) {
    return TaxPercentOption(
      map["name"] as String,
      map["percent"] as double,
    );
  }

  factory TaxPercentOption.fromString(String encode) {
    var map = jsonDecode(encode);
    return TaxPercentOption.fromMap(map);
  }

  Map<String, dynamic> toMap() => {
        "name": name,
        "percent": percent,
      };

  @override
  String toString() {
    return jsonEncode(toMap());
  }

  @override
  // TODO: implement props
  List<Object?> get props => [name, percent];
}

abstract class AppSetup {
  static String appInvoiceTypekey = "app_invoice_type";
  static String appInvoiceNamekey = "app_invoice_name";
  static String appPayTypeKey = "app_pay_type";
  static String appLocationKey = "app_location";
  static String appNitKey = "app_nit";
  static String appBusinessNamekey = "app_business_name";
  static String appTaxPercentKey = "app_tax_percent_key";

  static Future<void> boot() async {
    return configureDependencies();
  }

  static Future<void> reset() async {
    var service = getIt<CacheService>();
    await service.resetDatabase();
    return getIt<SQLiteProvider>().dropDB();
  }

  static String? getLocation() {
    SharedPreferences prefs = getIt();
    return prefs.getString(appLocationKey);
  }

  static void setLocation(String value) {
    SharedPreferences prefs = getIt();
    prefs.setString(appLocationKey, value);
  }

  static String? getNIT() {
    SharedPreferences prefs = getIt();
    return prefs.getString(appNitKey);
  }

  static void setNIT(String value) {
    SharedPreferences prefs = getIt();
    prefs.setString(appNitKey, value);
  }

  static String? getBusinessName() {
    SharedPreferences prefs = getIt();
    return prefs.getString(appBusinessNamekey);
  }

  static void setBusinessName(String value) {
    SharedPreferences prefs = getIt();
    prefs.setString(appBusinessNamekey, value);
  }

  static TaxPercentOption? getTaxPercentOption() {
    SharedPreferences prefs = getIt();
    var value = prefs.getString(appTaxPercentKey);
    if (value is String) {
      return TaxPercentOption.fromString(value);
    }
    return null;
  }

  static void setTaxPercentOption(TaxPercentOption option) {
    SharedPreferences prefs = getIt();
    prefs.setString(appTaxPercentKey, option.toString());
  }
}
