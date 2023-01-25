part of 'employee.dart';

abstract class EmployeeService {
  Future<List<Employee>> all();
  Future<Employee> findById(int id);
  Future<Employee> save(Employee employee);
  Future<Employee> update(Employee employee);
  Future<int> delete(Employee employee);
}

@Injectable(as: EmployeeService)
class DomainEmployeeService implements EmployeeService {
  final EmployeeRepository _repository;

  const DomainEmployeeService(this._repository);

  @override
  Future<List<Employee>> all() async {
    return (await _repository.employees()).toList();
  }

  @override
  Future<int> delete(Employee employee) {
    return _repository.delete(employee);
  }

  @override
  Future<Employee> findById(int id) async {
    var employee = await _repository.findById(id);
    if (employee != null) {
      return employee;
    } else {
      throw Exception();
    }
  }

  @override
  Future<Employee> save(Employee employee) async {
    int id = await _repository.save(employee);
    return Employee.withId(employee, id);
  }

  @override
  Future<Employee> update(Employee employee) async {
    await _repository.update(employee);
    return employee;
  }
}
