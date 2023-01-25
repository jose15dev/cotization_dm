import 'package:cotizacion_dm/core/domain/employee/employee.dart';
import 'package:cotizacion_dm/core/infrastructure/configuration/sqlite/employee/sqlite_employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'employee_repository_test.mocks.dart';

@GenerateMocks([SQLiteEmployeeRepository])
void main() {
  late MockSQLiteEmployeeRepository repository;
  late Database database;
  late EmployeeService service;
  const table = SQLiteEmployeeRepository.table;
  const rules = SQLiteEmployeeRepository.statements;
  final empRnd = _generateEmployee("Test");

  final empRcrd = List.generate(10, (_) {
    return empRnd;
  }).toSet();

  setUpAll(() async {
    sqfliteFfiInit();
    repository = MockSQLiteEmployeeRepository();
    service = DomainEmployeeService(repository);
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    for (int i = 0; i < rules.length; i++) {
      await database.execute(rules[i]);
    }
    when(repository.employees()).thenAnswer((_) async => empRcrd);
    when(repository.save(any)).thenAnswer((_) async => 1);
    when(repository.update(any)).thenAnswer((_) async => 1);
    when(repository.delete(any)).thenAnswer((_) async => 1);
    when(repository.findById(any)).thenAnswer((_) async => empRnd);
  });

  group("Employee database test", () {
    test("Sqflite version", () async {
      expect(await database.getVersion(), 0);
    });

    test("Add item to the database", () async {
      await database.insert(
        table,
        SQLiteEmployeeModel.fromEmployee(empRnd).toMap(),
      );
      final rcd = await database.query(table);
      expect(rcd.length, 1);
    });

    test("Add 4 item to the database", () async {
      await database.insert(
        table,
        SQLiteEmployeeModel.fromEmployee(_generateEmployee("Second")).toMap(),
      );

      await database.insert(
        table,
        SQLiteEmployeeModel.fromEmployee(_generateEmployee("Thrid")).toMap(),
      );

      await database.insert(
        table,
        SQLiteEmployeeModel.fromEmployee(_generateEmployee("Fourth")).toMap(),
      );

      final rcd = await database.query(table);
      expect(rcd.length, 4);
    });

    test("Update item on the database", () async {
      var employee = _generateEmployee("Another");
      await database.update(
        table,
        SQLiteEmployeeModel.fromEmployee(employee).toMap(),
      );
      final rcd = await database.query(table);

      expect(rcd.first["firstname"], employee.firstname);
    });

    test("Delete item from the database", () async {
      await database.delete(
        table,
        where: "id = ?",
        whereArgs: [1],
      );

      final rcd = await database.query(table);
      expect(rcd.length, 3);
    });

    test("Database close", () async {
      await database.close();
      expect(database.isOpen, false);
    });
  });

  group("Employee repository test", () {
    test("Get all employees", () async {
      verifyNever(repository.employees());
      expect(await repository.employees(), empRcrd);
      verify(repository.employees()).called(1);
    });

    test("Get one employee", () async {
      verifyNever(repository.findById(1));
      expect(await repository.findById(1), empRnd);
      verify(repository.findById(1)).called(1);
    });

    test("Save one employee", () async {
      verifyNever(repository.save(empRnd));
      expect(await repository.save(empRnd), 1);
      verify(repository.save(empRnd)).called(1);
    });

    test("Update one employee", () async {
      verifyNever(repository.update(empRnd));
      expect(await repository.update(empRnd), 1);
      verify(repository.update(empRnd)).called(1);
    });
    test("Delete one employee", () async {
      verifyNever(repository.delete(empRnd));
      expect(await repository.delete(empRnd), 1);
      verify(repository.delete(empRnd)).called(1);
    });
  });

  group("Employee Service", () {
    test("Get all ", () async {
      final res = await service.all();
      expect(res, isA<List<Employee>>());
    });

    test("Save employee", () async {
      var employee = _generateEmployee("Test");
      verifyNever(service.save(employee));
      expect(await service.save(employee), isInstanceOf<Employee>());
      verify(service.save(employee)).called(1);
    });

    test("Update employee", () async {
      var employee = Employee.withId(_generateEmployee("Another"), 1);
      verifyNever(service.update(employee));
      var empUpdated = await service.update(employee);
      expect(empUpdated, isInstanceOf<Employee>());
      expect(empUpdated.firstname, "Another");
      verify(service.update(employee)).called(1);
    });

    test("Delete employee", () async {
      var find = await service.findById(1);
      expect(service.delete(find), isInstanceOf<void>());
    });

    test("Get employee", () async {
      var find = await service.findById(1);
      expect(find, isInstanceOf<Employee>());
    });
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
