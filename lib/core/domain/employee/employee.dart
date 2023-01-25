import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

part 'employee_service.dart';
part 'employee_repository.dart';

class Employee extends Equatable {
  final String firstname, lastname, phone;
  final Uint8List? image;
  final double salary;
  final int? id;

  const Employee({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.salary,
    this.image,
  });

  factory Employee.withId(Employee employee, int id) {
    return Employee(
      id: id,
      firstname: employee.firstname,
      lastname: employee.lastname,
      phone: employee.phone,
      salary: employee.salary,
      image: employee.image,
    );
  }

  @override
  List<Object?> get props => [firstname, lastname, phone];
}
