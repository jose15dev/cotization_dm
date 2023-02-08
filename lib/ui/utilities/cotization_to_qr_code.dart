import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/shared/utilities/cotization_serialize.dart';

String cotizationToQrCode(Cotization cotization) {
  var model = Cotization(
    name: cotization.name,
    description: cotization.description,
    color: cotization.color,
    isAccount: cotization.isAccount,
    tax: cotization.tax,
    items: cotization.items,
    createdAt: cotization.createdAt,
    updatedAt: cotization.updatedAt,
  );
  return cotizationToJson(model);
}
