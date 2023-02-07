import 'dart:convert';

import 'package:cotizacion_dm/core/domain/domain.dart';

Map<String, dynamic> cotizationToMap(Cotization cotization) {
  return {
    "id": cotization.id,
    "name": cotization.name,
    "description": cotization.description,
    "tax": cotization.tax,
    "color": cotization.color,
    "is_account": cotization.isAccount,
    "finished": cotization.finished?.millisecondsSinceEpoch,
    "created_at": cotization.createdAt.millisecondsSinceEpoch,
    "updated_at": cotization.updatedAt.millisecondsSinceEpoch,
    "deleted_at": cotization.deletedAt?.millisecondsSinceEpoch,
    "items": cotization.items
        .map((e) => <String, dynamic>{
              "id": e.id,
              "name": e.name,
              "description": e.description,
              "unit": e.unit,
              "unitValue": e.unitValue,
              "amount": e.amount,
            })
        .toList(),
  };
}

String cotizationToJson(Cotization cotization) {
  return jsonEncode(cotizationToMap(cotization));
}

Cotization cotizationFromMap(Map<String, dynamic> map) {
  return Cotization(
    id: map["id"],
    name: map["name"],
    description: map["description"],
    tax: map["tax"],
    color: map["color"],
    isAccount: map["is_account"],
    finished: DateTime.fromMillisecondsSinceEpoch(map["finished"]),
    createdAt: DateTime.fromMillisecondsSinceEpoch(map["created_at"]),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(map["updated_at"]),
    deletedAt: map["deleted_at"] != null
        ? DateTime.fromMillisecondsSinceEpoch(map["deleted_at"])
        : null,
    items: (map["items"] as List)
        .map((e) => CotizationItem(
              id: e["id"],
              name: e["name"],
              description: e["description"],
              unit: e["unit"],
              unitValue: e["unitValue"],
              amount: e["amount"],
            ))
        .toList(),
  );
}

Cotization cotizationFromJson(String source) {
  return cotizationFromMap(jsonDecode(source));
}
