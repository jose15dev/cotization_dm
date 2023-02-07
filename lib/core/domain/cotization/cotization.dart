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
  final DateTime? finished, deletedAt;
  final DateTime createdAt, updatedAt;
  final bool isAccount;

  const Cotization({
    required this.name,
    required this.description,
    required this.color,
    required this.isAccount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.tax,
    this.finished,
    this.items = const [],
    this.id,
  });
  factory Cotization.delete(Cotization cotization) {
    return Cotization(
      name: cotization.name,
      description: cotization.description,
      items: cotization.items,
      color: cotization.color,
      tax: cotization.tax,
      isAccount: cotization.isAccount,
      finished: cotization.finished,
      createdAt: cotization.createdAt,
      updatedAt: cotization.updatedAt,
      deletedAt: DateTime.now(),
      id: cotization.id,
    );
  }

  factory Cotization.update(Cotization cotization) {
    return Cotization(
      name: cotization.name,
      description: cotization.description,
      items: cotization.items,
      color: cotization.color,
      tax: cotization.tax,
      isAccount: cotization.isAccount,
      finished: cotization.finished,
      createdAt: cotization.createdAt,
      updatedAt: DateTime.now(),
      deletedAt: cotization.deletedAt,
      id: cotization.id,
    );
  }

  factory Cotization.restore(Cotization cotization) {
    return Cotization(
      name: cotization.name,
      description: cotization.description,
      items: cotization.items,
      color: cotization.color,
      tax: cotization.tax,
      finished: cotization.finished,
      isAccount: cotization.isAccount,
      createdAt: cotization.createdAt,
      updatedAt: cotization.updatedAt,
      deletedAt: null,
      id: cotization.id,
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
      finished: DateTime.now(),
      createdAt: cotization.createdAt,
      updatedAt: cotization.updatedAt,
      deletedAt: cotization.deletedAt,
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
