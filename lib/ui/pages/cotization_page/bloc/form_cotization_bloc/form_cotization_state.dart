part of 'form_cotization_cubit.dart';

abstract class FormCotizationState extends Equatable {
  const FormCotizationState();

  @override
  List<Object> get props => [];
}

class FormCotizationInitial extends FormCotizationState {}

abstract class FormCotizationFailed extends FormCotizationState {
  final String message;

  const FormCotizationFailed(this.message);
}

class FormCotizationValidationLoading extends FormCotizationState {}

class FormCotizationValidationSuccess extends FormCotizationState {}

class FormCotizationValidationFailed extends FormCotizationFailed {
  const FormCotizationValidationFailed(super.message);
}

class OnAddNewItem extends FormCotizationState {}

class FormOnEditItem extends FormCotizationState {
  final CotizationItem item;
  final bool copy;
  final Offset position;

  const FormOnEditItem(this.item, {this.copy = false, required this.position});
}

class ActionItemLoading extends FormCotizationState {}

class ActionItemSuccess extends FormCotizationState {}

class ActionItemFailed extends FormCotizationFailed {
  const ActionItemFailed(super.message);
}

class FormOnSaveCotizationLoading extends FormCotizationState {}

class FormOnSaveCotizationSuccess extends FormCotizationState {
  final Cotization cotization;

  const FormOnSaveCotizationSuccess(this.cotization);
}

class FormOnSaveCotizationFailed extends FormCotizationFailed {
  const FormOnSaveCotizationFailed(super.message);
}

class FormOnLoadCotization extends FormCotizationState {}
