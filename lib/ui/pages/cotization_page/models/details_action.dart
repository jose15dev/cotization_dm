import 'package:cotizacion_dm/core/domain/domain.dart';

class DetailsAction {
  final Cotization cotization;
  final DetailsActionType action;

  const DetailsAction({
    required this.cotization,
    required this.action,
  });
}

enum DetailsActionType {
  delete,
  trash,
  restore,
}
