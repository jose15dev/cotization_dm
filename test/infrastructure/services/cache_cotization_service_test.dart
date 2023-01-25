import 'package:cotizacion_dm/core/domain/cotization/cotization.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  late SharedPreferences prefs;
  late SharedPreferencesCacheCotizationService service;
  var cotization = const Cotization(
      name: "Test",
      description: "Test",
      color: 0x000000,
      tax: 0.19,
      isAccount: false,
      finished: true,
      items: [
        CotizationItem(
          id: 5,
          name: "Text item",
          description: "Text item",
          unit: "u",
          unitValue: 30000.0,
          amount: 30,
        ),
      ]);
  List<Cotization> cotizations = List.generate(10, (index) {
    return Cotization.withId(cotization, index);
  }).toList();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = SharedPreferencesCacheCotizationService(prefs);
  });

  group("Service cotization for cache", () {
    test("Get cotizations on cache", () async {
      service.setCotizations(cotizations);
      var result = await service.all();
      expect(result, isA<List<Cotization>>());
      expect(result, cotizations);
    });

    test("Save cotization on cache", () async {
      service.setCotizations(cotizations);
      await service.save(Cotization.withId(cotization, 10));

      var result = await service.all();

      expect(result, isA<List<Cotization>>());
      expect(result.length, cotizations.length + 1);
    });

    test("Get cotization on cache", () async {
      service.setCotizations(cotizations);
      var result = await service.findById(1);
      expect(result, isA<Cotization>());
    });

    test("Update cotization on cache", () async {
      service.setCotizations(cotizations);
      await service.update(Cotization.withId(cotization, 1));

      var result = await service.all();

      expect(result, isA<List<Cotization>>());
      expect(result.length, cotizations.length);
    });

    test("Delete cotization on cache", () async {
      service.setCotizations(cotizations);
      var e = Cotization.withId(cotization, 5);
      await service.delete(e);

      var result = await service.all();

      expect(result, isA<List<Cotization>>());
      expect(result.length, cotizations.length - 1);
    });
  });
}
