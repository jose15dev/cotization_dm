import 'package:bloc_test/bloc_test.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/pages/employee_page/bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'fetch_employee_bloc_test.mocks.dart';

@GenerateMocks([DomainEmployeeService, SharedPreferencesCacheEmployeeService])
void main() {
  late FetchEmployeeCubit mockCubit;
  late MockDomainEmployeeService service;
  late MockSharedPreferencesCacheEmployeeService cacheService;

  List<Employee> empList =
      List.generate(10, (index) => _generateEmployee("Test"));

  final emp = _generateEmployee("Test");
  setUp(() async {
    service = MockDomainEmployeeService();
    cacheService = MockSharedPreferencesCacheEmployeeService();
    mockCubit = FetchEmployeeCubit(service, cacheService);
  });

  group("Fetch employee bloc test", () {
    blocTest<FetchEmployeeCubit, FetchEmployeeState>(
        'check if on fetch cache not exist works',
        build: () => mockCubit,
        setUp: () {
          when(cacheService.all())
              .thenAnswer((realInvocation) async => empList);
          when(service.all()).thenAnswer((realInvocation) async => empList);
        },
        act: (b) => b.fetchEmployees(),
        expect: () => [isA<OnFetchEmployeeSuccess>()]);

    blocTest<FetchEmployeeCubit, FetchEmployeeState>(
        'check if on fetch cache not exist works',
        build: () => mockCubit,
        setUp: () {
          when(cacheService.all()).thenAnswer((realInvocation) async => []);
          when(service.all()).thenAnswer((realInvocation) async => empList);
        },
        act: (b) => b.fetchEmployees(),
        expect: () =>
            [isA<OnFetchEmployeeLoading>(), isA<OnFetchEmployeeSuccess>()]);

    blocTest<FetchEmployeeCubit, FetchEmployeeState>(
      'check if fetch all fails',
      build: () => mockCubit,
      act: (bloc) => bloc.fetchEmployees(),
      setUp: () {
        when(cacheService.all()).thenAnswer((realInvocation) async => []);

        when(service.all())
            .thenAnswer((realInvocation) => throw Exception("Something"));
      },
      expect: () => [isA<OnFetchEmployeeLoading>(), isA<FetchEmployeeFailed>()],
    );

    blocTest<FetchEmployeeCubit, FetchEmployeeState>(
      'check if fetch all empty',
      build: () => mockCubit,
      act: (bloc) => bloc.fetchEmployees(),
      setUp: () {
        when(cacheService.all()).thenAnswer((realInvocation) async => []);
        when(service.all()).thenAnswer((realInvocation) async => []);
      },
      expect: () =>
          [isA<OnFetchEmployeeLoading>(), isA<OnFetchEmployeeEmpty>()],
    );
    blocTest<FetchEmployeeCubit, FetchEmployeeState>(
      'check if delete works',
      build: () => mockCubit,
      act: (b) => b.deleteEmployee(emp),
      setUp: () {
        when(service.delete(any)).thenAnswer((_) async => 1);
        when(cacheService.delete(any)).thenAnswer((_) async => 1);
      },
      expect: () =>
          [isA<OnActionEmployeeLoading>(), isA<OnActionEmployeeSuccess>()],
    );

    blocTest<FetchEmployeeCubit, FetchEmployeeState>('check if delete failed',
        build: () => mockCubit,
        act: (bloc) => bloc.deleteEmployee(emp),
        setUp: () =>
            when(service.delete(any)).thenAnswer((_) => throw Exception()),
        expect: () =>
            [isA<OnActionEmployeeLoading>(), isA<OnActionEmployeeFailed>()]);

    blocTest<FetchEmployeeCubit, FetchEmployeeState>(
      'check if store works',
      build: () => mockCubit,
      act: (bloc) => bloc.saveEmployee(emp),
      setUp: () {
        when(service.save(any)).thenAnswer((_) async => emp);
        when(cacheService.save(any)).thenAnswer((_) async => emp);
      },
      expect: () =>
          [isA<OnActionEmployeeLoading>(), isA<OnActionEmployeeSuccess>()],
    );

    blocTest<FetchEmployeeCubit, FetchEmployeeState>(
      'check if store failed',
      build: () => mockCubit,
      act: (bloc) => bloc.saveEmployee(emp),
      setUp: () =>
          when(service.save(any)).thenAnswer((_) async => throw Exception()),
      expect: () =>
          [isA<OnActionEmployeeLoading>(), isA<OnActionEmployeeFailed>()],
    );
  });
}

Employee _generateEmployee(String name) {
  return Employee(
    firstname: name,
    lastname: name,
    phone: "123-345-6789",
    salary: 20000.0,
  );
}
