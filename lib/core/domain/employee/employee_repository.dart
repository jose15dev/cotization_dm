part of 'employee.dart';

abstract class EmployeeRepository {
  Future<Set<Employee>> employees();

  Future<Employee?> findById(int id);

  Future<int> save(Employee employee);

  Future<int> delete(Employee employee);

  Future<int> update(Employee employee);
}
