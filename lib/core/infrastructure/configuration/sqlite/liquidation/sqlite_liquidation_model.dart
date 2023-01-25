part of 'sqlite_liquidation_repository.dart';

class SQLiteLiquidationModel {
  final int? id;
  final SQLiteEmployeeModel employee;
  final int days;
  final double realPrice;
  final int createdAt;

  const SQLiteLiquidationModel({
    this.id,
    required this.employee,
    required this.days,
    required this.realPrice,
    required this.createdAt,
  });

  factory SQLiteLiquidationModel.fromLiquidation(Liquidation liquidation) {
    return SQLiteLiquidationModel(
      id: liquidation.id,
      employee: SQLiteEmployeeModel.fromEmployee(liquidation.employee),
      days: liquidation.days,
      realPrice: liquidation.realPrice,
      createdAt: liquidation.createdAt.millisecondsSinceEpoch,
    );
  }

  Liquidation toLiquidation() => Liquidation(
        id: id,
        employee: employee.toEmployee(),
        days: days,
        realPrice: realPrice,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      );

  factory SQLiteLiquidationModel.fromMap(Map<String, dynamic> map) {
    return SQLiteLiquidationModel(
      id: map['id'] as int,
      employee:
          SQLiteEmployeeModel.fromMap(map['employee'] as Map<String, dynamic>),
      days: map['days'] as int,
      realPrice: map['real_price'] as double,
      createdAt: map["created_at"] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fk_employee_id': employee.id,
      'days': days,
      'real_price': realPrice,
      'created_at': createdAt,
    };
  }
}
