import 'package:cotizacion_dm/core/domain/employee/employee.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:flutter/services.dart';

part 'cache_employee_model.dart';

@Injectable()
class SharedPreferencesCacheEmployeeService implements EmployeeService {
  final SharedPreferences prefs;

  var key = "employee_list_cached";
  SharedPreferencesCacheEmployeeService(this.prefs);

  @override
  Future<List<Employee>> all() async {
    var cached = prefs.getStringList(key);

    if (cached is List<String>) {
      var cacheListModel = cached.map((e) => CachedEmployeeModel.fromString(e));
      var employees = cacheListModel.map((e) => e.toEmployee()).toList();
      return employees;
    }

    return [];
  }

  void setEmployees(List<Employee> employees) {
    var cacheListModel =
        employees.map((e) => CachedEmployeeModel.fromEmployee(e));

    var stringList = cacheListModel.map((e) => e.toString()).toList();

    prefs.setStringList(key, stringList);
  }

  @override
  Future<Employee> save(Employee employee) async {
    var employees = await all();
    employees.add(employee);

    setEmployees(employees);
    return employee;
  }

  void clearAll() {
    prefs.remove(key);
  }

  @override
  Future<int> delete(Employee employee) async {
    var employees = await all();
    employees.removeWhere((e) => e.id == employee.id);
    setEmployees(employees);
    return employee.id ?? 0;
  }

  @override
  Future<Employee> findById(int id) async {
    var employees = await all();
    return employees.firstWhere((element) => element.id == id,
        orElse: () => throw Exception());
  }

  @override
  Future<Employee> update(Employee employee) async {
    var employees = await all();
    var index = employees.indexWhere((e) => e.id == employee.id);
    if (index >= 0) {
      employees.removeAt(index);
      employees.insert(index, employee);
      setEmployees(employees);
    }

    return employee;
  }
}
