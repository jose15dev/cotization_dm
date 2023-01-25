part of "sqlite_employee_repository.dart";

class SQLiteEmployeeModel {
  final int? id;
  final String firstname, lastname, phone;
  final Uint8List? image;
  final double salary;

  const SQLiteEmployeeModel({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.salary,
    this.image,
  });

  factory SQLiteEmployeeModel.fromMap(Map<String, Object?> map) {
    return SQLiteEmployeeModel(
      id: map["id"] as int,
      firstname: map["firstname"] as String,
      lastname: map["lastname"] as String,
      phone: map["phone"] as String,
      salary: map["salary"] as double,
      image: map["image"] as Uint8List?,
    );
  }

  factory SQLiteEmployeeModel.fromEmployee(Employee employee) {
    return SQLiteEmployeeModel(
      id: employee.id,
      firstname: employee.firstname,
      lastname: employee.lastname,
      phone: employee.phone,
      salary: employee.salary,
      image: employee.image,
    );
  }

  Map<String, Object?> toMap() => {
        "firstname": firstname,
        "lastname": lastname,
        "phone": phone,
        "salary": salary,
        "image": image,
      };

  Employee toEmployee() => Employee(
        id: id,
        firstname: firstname,
        lastname: lastname,
        phone: phone,
        salary: salary,
        image: image,
      );
}
