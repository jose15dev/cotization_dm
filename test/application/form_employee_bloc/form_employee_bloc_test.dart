import 'package:bloc_test/bloc_test.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/pages/employee_page/bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([EmployeeService])
void main() {
  late FormEmployeeCubit mockCubit;
  group("Form employee bloc test", () {
    setUp(() {
      mockCubit = FormEmployeeCubit();
    });
    blocTest<FormEmployeeCubit, FormEmployeeState>(
      'update firstname works',
      build: () => mockCubit,
      act: (bloc) => bloc.updateFirstname("Test"),
      expect: () => [
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationSuccess>(),
      ],
    );

    blocTest<FormEmployeeCubit, FormEmployeeState>(
      'update firstname empty',
      build: () => mockCubit,
      act: (bloc) => bloc.updateFirstname(""),
      expect: () => [
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationFailed>(),
      ],
    );

    blocTest<FormEmployeeCubit, FormEmployeeState>(
      'update lastname works',
      build: () => mockCubit,
      act: (bloc) => bloc.updateLastname("Test"),
      expect: () => [
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationSuccess>(),
      ],
    );
    blocTest<FormEmployeeCubit, FormEmployeeState>(
      'update lastname empty',
      build: () => mockCubit,
      act: (bloc) => bloc.updateLastname(""),
      expect: () => [
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationFailed>(),
      ],
    );

    blocTest<FormEmployeeCubit, FormEmployeeState>(
      'update phone works',
      build: () => mockCubit,
      act: (bloc) => bloc.updatePhone("123-456-7890"),
      expect: () => [
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationSuccess>(),
      ],
    );
    blocTest<FormEmployeeCubit, FormEmployeeState>(
      'update phone empty',
      build: () => mockCubit,
      act: (bloc) => bloc.updatePhone(""),
      expect: () => [
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationFailed>(),
      ],
    );

    blocTest<FormEmployeeCubit, FormEmployeeState>(
      'update phone incomplete',
      build: () => mockCubit,
      act: (bloc) => bloc.updatePhone("123"),
      expect: () => [
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationFailed>(),
      ],
    );

    blocTest<FormEmployeeCubit, FormEmployeeState>(
      'update salary works',
      build: () => mockCubit,
      act: (bloc) => bloc.updateSalary("\$3,000.0"),
      expect: () => [
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationSuccess>(),
      ],
    );
    blocTest<FormEmployeeCubit, FormEmployeeState>(
      'update salary on zero',
      build: () => mockCubit,
      act: (bloc) => bloc.updateSalary("\$0.0"),
      expect: () => [
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationFailed>(),
      ],
    );
    blocTest<FormEmployeeCubit, FormEmployeeState>(
      'update salary invalid',
      build: () => mockCubit,
      act: (bloc) => bloc.updateSalary("Test"),
      expect: () => [
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationFailed>(),
      ],
    );

    blocTest<FormEmployeeCubit, FormEmployeeState>(
      'check if form is ready to save',
      build: () => mockCubit,
      act: (bloc) {
        bloc.updateFirstname("Test");
        bloc.updateLastname("Test");
        bloc.updatePhone("123-456-6789");
        bloc.updateSalary("\$30,000.0");
      },
      expect: () => [
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationSuccess>(),
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationSuccess>(),
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationSuccess>(),
        isA<FormEmployeeValidationLoading>(),
        isA<FormEmployeeValidationSuccess>(),
      ],
    );
  });
}
