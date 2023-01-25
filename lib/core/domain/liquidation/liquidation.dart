import 'package:cotizacion_dm/core/domain/employee/employee.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'liquidation_repository.dart';
part 'liquidation_service.dart';

class Liquidation extends Equatable {
  final int? id;
  final Employee employee;
  final int days;
  final double realPrice;
  final DateTime createdAt;

  const Liquidation({
    this.id,
    required this.employee,
    required this.days,
    required this.realPrice,
    required this.createdAt,
  });

  factory Liquidation.withId(Liquidation liquidation, int id) {
    return Liquidation(
      id: id,
      employee: liquidation.employee,
      days: liquidation.days,
      realPrice: liquidation.realPrice,
      createdAt: liquidation.createdAt,
    );
  }

  double get total => days * employee.salary;

  @override
  // TODO: implement props
  List<Object?> get props => [id, employee, days, realPrice, createdAt];
}
