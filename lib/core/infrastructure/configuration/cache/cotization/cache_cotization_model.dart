part of 'cache_cotization_service.dart';

class CacheCotizationModel {
  final String name, description;
  final int? id;
  final bool isAccount;
  final double? tax;
  final int color;
  final List<CacheCotizationItemModel> items;
  final int? finished, deletedAt;
  final int createdAt, updatedAt;

  CacheCotizationModel({
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

  factory CacheCotizationModel.fromMap(Map<String, dynamic> map) {
    return CacheCotizationModel(
      id: map["id"] as int,
      name: map["name"] as String,
      description: map["description"] as String,
      color: map["color"] as int,
      tax: map["tax"] as double?,
      isAccount: map["is_account"] as bool,
      finished: map["finished"] as int?,
      items: (map['items'] as List<Map<String, Object?>>)
          .map((e) => CacheCotizationItemModel.fromMap(e))
          .toList(),
      createdAt: map["created_at"] as int,
      updatedAt: map["updated_at"] as int,
      deletedAt: map["deleted_at"] as int?,
    );
  }

  factory CacheCotizationModel.fromCotization(Cotization cotization) {
    return CacheCotizationModel(
      id: cotization.id,
      name: cotization.name,
      description: cotization.description,
      color: cotization.color,
      tax: cotization.tax,
      isAccount: cotization.isAccount,
      items: cotization.items
          .map((e) => CacheCotizationItemModel.fromCotizationItem(e))
          .toList(),
      finished: cotization.finished?.millisecondsSinceEpoch,
      createdAt: cotization.createdAt.millisecondsSinceEpoch,
      updatedAt: cotization.updatedAt.millisecondsSinceEpoch,
      deletedAt: cotization.deletedAt?.millisecondsSinceEpoch,
    );
  }

  factory CacheCotizationModel.fromString(String encode) {
    Map<String, Object?> map = jsonDecode(encode);
    List<Map<String, dynamic>> list = (map["items"] as List<dynamic>)
        .cast<String>()
        .map((e) => CacheCotizationItemModel.fromString(e).toMap())
        .toList();
    map["items"] = list;
    return CacheCotizationModel.fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "tax": tax,
      "color": color,
      "is_account": isAccount,
      "finished": finished,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "deleted_at": deletedAt,
      "items": items.map((e) => e.toString()).toList(),
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

  @override
  String toString() {
    return jsonEncode(toMap());
  }
}

class CacheCotizationItemModel {
  final String name, description, unit;
  final double unitValue, amount;
  final int? id;

  CacheCotizationItemModel({
    required this.name,
    required this.description,
    required this.unit,
    required this.unitValue,
    required this.amount,
    this.id,
  });

  factory CacheCotizationItemModel.fromMap(Map<String, dynamic> map) {
    return CacheCotizationItemModel(
      id: map["id"] as int,
      name: map["name"] as String,
      description: map["description"] as String,
      unit: map["unit"] as String,
      unitValue: map["unit_value"] as double,
      amount: map["amount"] as double,
    );
  }

  factory CacheCotizationItemModel.fromCotizationItem(
      CotizationItem cotizationItem) {
    return CacheCotizationItemModel(
      id: cotizationItem.id,
      name: cotizationItem.name,
      description: cotizationItem.description,
      unit: cotizationItem.unit,
      unitValue: cotizationItem.unitValue,
      amount: cotizationItem.amount,
    );
  }

  factory CacheCotizationItemModel.fromString(String encode) {
    Map<String, Object?> map = jsonDecode(encode);
    return CacheCotizationItemModel.fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
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

  @override
  String toString() {
    return jsonEncode(toMap());
  }
}
