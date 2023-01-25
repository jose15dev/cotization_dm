part of 'form_cotization_item_cubit.dart';

abstract class FormCotizationItemState extends Equatable {
  const FormCotizationItemState();

  @override
  List<Object> get props => [];
}

class FormCotizationItemInitial extends FormCotizationItemState {}

abstract class FormCotizationItemFailed extends FormCotizationItemState {
  final String message;

  const FormCotizationItemFailed(this.message);
}

class FormCotizationItemValidationLoading extends FormCotizationItemState {}

class FormCotizationItemValidationSuccess extends FormCotizationItemState {}

class FormCotizationItemValidationFailed extends FormCotizationItemFailed {
  const FormCotizationItemValidationFailed(super.message);
}

class FormCotizationItemSuccess extends FormCotizationItemState {}

class FormCotizationItemSaveLoading extends FormCotizationItemState {}

class FormCotizationItemSaveSuccess extends FormCotizationItemState {
  final CotizationItem item;
  final CotizationItem? oldItem;

  const FormCotizationItemSaveSuccess(this.item, this.oldItem);
}

class FormCotizationItemSaveFailed extends FormCotizationItemFailed {
  const FormCotizationItemSaveFailed(super.message);
}

class OnEditCotizationItem extends FormCotizationItemState {
  final String name, desc, unit, unitValue, amount;

  const OnEditCotizationItem(
      {required this.name,
      required this.desc,
      required this.unit,
      required this.unitValue,
      required this.amount});
}
