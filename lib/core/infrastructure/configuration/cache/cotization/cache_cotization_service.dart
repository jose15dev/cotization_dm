import 'dart:convert';

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cache_cotization_model.dart';

@Injectable()
class SharedPreferencesCacheCotizationService extends CotizationService {
  final SharedPreferences prefs;

  var key = "list_cotization_cache";

  SharedPreferencesCacheCotizationService(this.prefs);

  @override
  Future<List<Cotization>> all() async {
    var cached = prefs.getStringList(key);
    if (cached is List<String>) {
      var cachedListModel =
          cached.map((e) => CacheCotizationModel.fromString(e));
      var cotizations = cachedListModel.map((e) => e.toCotization()).toList();
      return cotizations;
    }
    return [];
  }

  void setCotizations(List<Cotization> cotizations) {
    var cachedListModel =
        cotizations.map((e) => CacheCotizationModel.fromCotization(e));
    var stringList = cachedListModel.map((e) => e.toString()).toList();
    prefs.setStringList(key, stringList);
  }

  @override
  Future<int> delete(Cotization cotization) async {
    var cotizations = await all();
    cotizations.removeWhere((element) => element.id == cotization.id);
    setCotizations(cotizations);
    return cotization.id ?? 0;
  }

  @override
  Future<Cotization> findById(int id) async {
    var cotizations = await all();
    return cotizations.firstWhere(
      (element) => element.id == id,
      orElse: () => throw Exception(),
    );
  }

  @override
  Future<Cotization> save(Cotization cotization) async {
    var cotizations = await all();
    cotizations.add(cotization);
    setCotizations(cotizations);
    return cotization;
  }

  @override
  Future<Cotization> update(Cotization cotization) async {
    var cotizations = await all();
    var index =
        cotizations.indexWhere((element) => element.id == cotization.id);
    if (index >= 0) {
      cotizations.removeAt(index);
      cotizations.insert(index, cotization);
    }
    setCotizations(cotizations);
    return cotization;
  }
}
