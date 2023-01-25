part of 'cache_employee_service.dart';

class CachedEmployeeModel {
  final int? id;
  final String firstname, lastname, phone;
  final Uint8List? image;
  final double salary;

  const CachedEmployeeModel({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.salary,
    this.image,
  });

  factory CachedEmployeeModel.fromMap(Map<String, Object?> map) {
    return CachedEmployeeModel(
      id: map["id"] as int,
      firstname: map["firstname"] as String,
      lastname: map["lastname"] as String,
      phone: map["phone"] as String,
      salary: map["salary"] as double,
      image: map["image"] as Uint8List?,
    );
  }

  factory CachedEmployeeModel.fromEmployee(Employee employee) {
    return CachedEmployeeModel(
      id: employee.id,
      firstname: employee.firstname,
      lastname: employee.lastname,
      phone: employee.phone,
      salary: employee.salary,
      image: employee.image,
    );
  }

  factory CachedEmployeeModel.fromString(String encode) {
    Map<String, Object?> map = jsonDecode(encode);

    var image = map["image"];
    if (image is List<dynamic>) {
      map["image"] = Uint8List.fromList(image.cast<int>());
    } else {
      map["image"] = null;
    }
    return CachedEmployeeModel.fromMap(map);
  }

  Map<String, Object?> toMap() => {
        "id": id,
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

  @override
  String toString() {
    return jsonEncode(toMap());
  }
}
