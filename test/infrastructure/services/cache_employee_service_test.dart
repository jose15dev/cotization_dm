import 'package:cotizacion_dm/core/domain/employee/employee.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  late SharedPreferences prefs;
  late SharedPreferencesCacheEmployeeService service;
  var employee = const Employee(
    firstname: "Test",
    lastname: "Test",
    phone: "3000",
    salary: 30000,
  );
  List<Employee> employees = List.generate(10, (index) {
    return Employee.withId(employee, index);
  }).toList();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = SharedPreferencesCacheEmployeeService(prefs);
  });

  group("Service employee for cache", () {
    test("Get employees on cache", () async {
      service.setEmployees(employees);
      var result = await service.all();
      expect(result, isA<List<Employee>>());
      expect(result, employees);
    });

    test("Save employee on cache", () async {
      service.setEmployees(employees);
      await service.save(Employee.withId(employee, 10));

      var result = await service.all();

      expect(result, isA<List<Employee>>());
      expect(result.length, employees.length + 1);
    });

    test("Get employee on cache", () async {
      service.setEmployees(employees);
      var result = await service.findById(1);
      expect(result, isA<Employee>());
    });

    test("Update employee on cache", () async {
      service.setEmployees(employees);
      await service.update(Employee.withId(employee, 1));

      var result = await service.all();

      expect(result, isA<List<Employee>>());
      expect(result.length, employees.length);
    });

    test("Delete employee on cache", () async {
      service.setEmployees(employees);
      var e = Employee.withId(employee, 5);
      await service.delete(e);

      var result = await service.all();

      expect(result, isA<List<Employee>>());
      expect(result.length, employees.length - 1);
    });
  });
}
