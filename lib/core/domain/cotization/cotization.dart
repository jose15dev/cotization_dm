import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'cotization_repository.dart';
part 'cotization_service.dart';

class Cotization extends Equatable {
  final String name, description;
  final int? id;
  final List<CotizationItem> items;
  final int color;
  final double? tax;
  final bool finished;
  final bool isAccount;

  const Cotization({
    required this.name,
    required this.description,
    required this.color,
    required this.isAccount,
    this.tax,
    this.finished = false,
    this.items = const [],
    this.id,
  });

  factory Cotization.withId(Cotization cotization, int id) {
    return Cotization(
      name: cotization.name,
      description: cotization.description,
      items: cotization.items,
      color: cotization.color,
      tax: cotization.tax,
      finished: cotization.finished,
      isAccount: cotization.isAccount,
      id: id,
    );
  }

  factory Cotization.finished(Cotization cotization) {
    return Cotization(
      name: cotization.name,
      description: cotization.description,
      items: cotization.items,
      color: cotization.color,
      tax: cotization.tax,
      isAccount: cotization.isAccount,
      finished: true,
      id: cotization.id,
    );
  }

  int get amountItems => items.length;

  double get total =>
      items.fold(
          0.0, (previousValue, element) => previousValue + element.total) *
      (1 + (tax ?? 0));

  @override
  List<Object?> get props => [
        name,
        description,
        id,
      ];
}

class CotizationItem extends Equatable {
  final String name, description, unit;
  final double unitValue, amount;
  final int? id;

  const CotizationItem({
    required this.name,
    required this.description,
    required this.unit,
    required this.unitValue,
    required this.amount,
    this.id,
  });

  factory CotizationItem.withId(CotizationItem cotizationItem, int id) {
    return CotizationItem(
      name: cotizationItem.name,
      description: cotizationItem.description,
      unitValue: cotizationItem.unitValue,
      amount: cotizationItem.amount,
      unit: cotizationItem.unit,
      id: id,
    );
  }

  double get total => amount * unitValue;

  @override
  List<Object?> get props => [name, description, unit];
}
