import 'package:bloc_test/bloc_test.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/pages/cotization_page/bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'fetch_cotization_bloc_test.mocks.dart';

@GenerateMocks([
  DomainCotizationService,
  SharedPreferencesCacheCotizationService,
  QueryCotizationService
])
void main() {
  late FetchCotizationCubit mockCubit;
  late MockDomainCotizationService service;
  late MockSharedPreferencesCacheCotizationService cacheService;
  late MockQueryCotizationService queryService;

  List<Cotization> empList =
      List.generate(10, (index) => _generateCotization("Test"));

  final emp = _generateCotization("Test");
  setUp(() async {
    service = MockDomainCotizationService();
    cacheService = MockSharedPreferencesCacheCotizationService();
    queryService = MockQueryCotizationService();
    mockCubit = FetchCotizationCubit(service, cacheService, queryService);
  });

  group("Fetch cotization bloc test", () {
    blocTest<FetchCotizationCubit, FetchCotizationState>(
        'check if on fetch cache not exist works',
        build: () => mockCubit,
        setUp: () {
          when(queryService.getOnlyNotDeleted(cotizations: empList))
              .thenAnswer((realInvocation) => empList);

          when(cacheService.all())
              .thenAnswer((realInvocation) async => empList);
          when(service.all()).thenAnswer((realInvocation) async => empList);
        },
        act: (b) => b.fetchCotizations(),
        expect: () => [isA<OnFetchCotizationSuccess>()]);

    blocTest<FetchCotizationCubit, FetchCotizationState>(
        'check if on fetch cache not exist works',
        build: () => mockCubit,
        setUp: () {
          when(cacheService.all()).thenAnswer((realInvocation) async => []);
          when(service.all()).thenAnswer((realInvocation) async => empList);
        },
        act: (b) => b.fetchCotizations(),
        expect: () =>
            [isA<OnFetchCotizationLoading>(), isA<OnFetchCotizationSuccess>()]);

    blocTest<FetchCotizationCubit, FetchCotizationState>(
      'check if fetch all fails',
      build: () => mockCubit,
      act: (bloc) => bloc.fetchCotizations(),
      setUp: () {
        when(cacheService.all()).thenAnswer((realInvocation) async => []);
        when(queryService.getOnlyNotDeleted(cotizations: empList))
            .thenAnswer((realInvocation) => empList);

        when(service.all())
            .thenAnswer((realInvocation) => throw Exception("Something"));
      },
      expect: () =>
          [isA<OnFetchCotizationLoading>(), isA<FetchCotizationFailed>()],
    );

    blocTest<FetchCotizationCubit, FetchCotizationState>(
      'check if fetch all empty',
      build: () => mockCubit,
      act: (bloc) => bloc.fetchCotizations(),
      setUp: () {
        when(cacheService.all()).thenAnswer((realInvocation) async => []);
        when(service.all()).thenAnswer((realInvocation) async => []);
      },
      expect: () =>
          [isA<OnFetchCotizationLoading>(), isA<OnFetchCotizationEmpty>()],
    );
    blocTest<FetchCotizationCubit, FetchCotizationState>(
      'check if delete works',
      build: () => mockCubit,
      act: (b) => b.deleteCotization(emp),
      setUp: () {
        when(queryService.getOnlyNotDeleted(cotizations: empList))
            .thenAnswer((realInvocation) => empList);
        when(service.delete(any)).thenAnswer((_) async => 1);
        when(cacheService.delete(any)).thenAnswer((_) async => 1);
      },
      expect: () =>
          [isA<OnActionCotizationLoading>(), isA<OnActionCotizationSuccess>()],
    );

    blocTest<FetchCotizationCubit, FetchCotizationState>(
        'check if delete failed',
        build: () => mockCubit,
        act: (bloc) => bloc.deleteCotization(emp),
        setUp: () =>
            when(service.delete(any)).thenAnswer((_) => throw Exception()),
        expect: () => [
              isA<OnActionCotizationLoading>(),
              isA<OnActionCotizationFailed>()
            ]);

    blocTest<FetchCotizationCubit, FetchCotizationState>(
      'check if store works',
      build: () => mockCubit,
      act: (bloc) => bloc.saveCotization(emp),
      setUp: () {
        when(service.save(any)).thenAnswer((_) async => emp);
        when(cacheService.save(any)).thenAnswer((_) async => emp);
      },
      expect: () =>
          [isA<OnActionCotizationLoading>(), isA<OnActionCotizationSuccess>()],
    );

    blocTest<FetchCotizationCubit, FetchCotizationState>(
      'check if store failed',
      build: () => mockCubit,
      act: (bloc) => bloc.saveCotization(emp),
      setUp: () {
        when(service.save(any)).thenAnswer((_) async => throw Exception());
      },
      expect: () =>
          [isA<OnActionCotizationLoading>(), isA<OnActionCotizationFailed>()],
    );
  });
}

Cotization _generateCotization(String name) {
  return Cotization(
      name: name,
      description: name,
      color: 0x000000,
      tax: 0.19,
      isAccount: false,
      finished: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [
        CotizationItem(
            name: name,
            description: name,
            unit: "u",
            unitValue: 3,
            amount: 30000.0)
      ]);
}
