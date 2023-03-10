part of 'sqlite_cotization_repository.dart';

class SQLiteCotizationModel {
  final String name, description;
  final int? id;
  final int? finished, deletedAt;
  final int createdAt, updatedAt;
  final bool isAccount;
  final double? tax;
  final int color;
  final List<SQLiteCotizationItemModel> items;

  SQLiteCotizationModel({
    required this.name,
    required this.description,
    required this.color,
    required this.tax,
    required this.isAccount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.finished,
    this.id,
    required this.items,
  });

  factory SQLiteCotizationModel.fromMap(Map<String, dynamic> map) {
    return SQLiteCotizationModel(
      id: map["id"] as int,
      name: map["name"] as String,
      description: map["description"] as String,
      color: map["color"] as int,
      tax: (map["tax"] as double?),
      isAccount: SQLBoolValue.integerToBool(map["is_account"] as int),
      finished: (map["finished"] as int?),
      items: (map['items'] as List<Map<String, Object?>>)
          .map((e) => SQLiteCotizationItemModel.fromMap(e))
          .toList(),
      createdAt: map["created_at"] as int,
      updatedAt: map["updated_at"] as int,
      deletedAt: (map["deleted_at"] as int?),
    );
  }

  factory SQLiteCotizationModel.fromCotization(Cotization cotization) {
    return SQLiteCotizationModel(
      name: cotization.name,
      description: cotization.description,
      color: cotization.color,
      tax: cotization.tax,
      isAccount: cotization.isAccount,
      items: cotization.items
          .map((e) => SQLiteCotizationItemModel.fromCotizationItem(e))
          .toList(),
      finished: cotization.finished?.millisecondsSinceEpoch,
      createdAt: cotization.createdAt.millisecondsSinceEpoch,
      updatedAt: cotization.updatedAt.millisecondsSinceEpoch,
      deletedAt: cotization.deletedAt?.millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
      "tax": tax,
      "is_account": SQLBoolValue.boolToInteger(isAccount),
      "color": color,
      "finished": finished,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "deleted_at": deletedAt,
    };
  }

  Cotization toCotization() {
    return Cotization(
      id: id,
      name: name,
      description: description,
      color: color,
      tax: tax,
      isAccount: isAccount,
      finished: finished != null
          ? DateTime.fromMillisecondsSinceEpoch(finished!)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      deletedAt: deletedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(deletedAt!)
          : null,
      items: items.map((e) => e.toCotizationItem()).toList(),
    );
  }
}

class SQLiteCotizationItemModel {
  final String name, description, unit;
  final double unitValue, amount;
  final int? id;

  SQLiteCotizationItemModel({
    required this.name,
    required this.description,
    required this.unit,
    required this.unitValue,
    required this.amount,
    this.id,
  });

  factory SQLiteCotizationItemModel.fromMap(Map<String, dynamic> map) {
    return SQLiteCotizationItemModel(
      id: map["id"] as int,
      name: map["name"] as String,
      description: map["description"] as String,
      unit: map["unit"] as String,
      unitValue: map["unit_value"] as double,
      amount: map["amount"] as double,
    );
  }

  factory SQLiteCotizationItemModel.fromCotizationItem(
      CotizationItem cotizationItem) {
    return SQLiteCotizationItemModel(
      id: cotizationItem.id,
      name: cotizationItem.name,
      description: cotizationItem.description,
      unit: cotizationItem.unit,
      unitValue: cotizationItem.unitValue,
      amount: cotizationItem.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
      "unit": unit,
      "unit_value": unitValue,
      "amount": amount,
    };
  }

  CotizationItem toCotizationItem() {
    return CotizationItem(
      id: id,
      name: name,
      description: description,
      unit: unit,
      unitValue: unitValue,
      amount: amount,
    );
  }
}

abstract class SQLBoolValue {
  static int boolToInteger(bool value) {
    return value ? 1 : 0;
  }

  static bool integerToBool(int value) {
    if (value > 1 || value < 0) {
      throw Exception("Bool invalido");
    }
    if (value == 1) {
      return true;
    }
    return false;
  }
}
