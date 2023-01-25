part of 'form_employee_cubit.dart';

abstract class FormEmployeeState extends Equatable {
  const FormEmployeeState();

  @override
  List<Object> get props => [];
}

class FormEmployeeInitial extends FormEmployeeState {}

class FormEmployeeFailed extends FormEmployeeState {
  final String message;

  const FormEmployeeFailed(this.message);
}

class FormEmployeeImageError extends FormEmployeeFailed {
  const FormEmployeeImageError(super.message);
}

class FormEmployeeValidationFailed extends FormEmployeeState {}

class FormEmployeeValidationSuccess extends FormEmployeeState {}

class FormEmployeeValidationLoading extends FormEmployeeState {}

class FormEmployeeSaveInfoLoading extends FormEmployeeState {}

class FormEmployeeSaveInfoSuccess extends FormEmployeeState {
  final Employee employee;

  const FormEmployeeSaveInfoSuccess(this.employee);
}

class FormEmployeeSaveInfoFailed extends FormEmployeeFailed {
  final bool? warning;

  const FormEmployeeSaveInfoFailed(super.message, [this.warning]);
}

class FormEmployeeOnEdit extends FormEmployeeState {
  final String firstname, lastname, phone, salary;
  final Uint8List? image;

  const FormEmployeeOnEdit(
      this.firstname, this.lastname, this.phone, this.salary,
      [this.image]);
}

class FormEmployeeOnEditFailed extends FormEmployeeFailed {
  const FormEmployeeOnEditFailed(super.message);
}

class OnContactsLoading extends FormEmployeeState {}

class OnContactsEmpty extends FormEmployeeState {}

class OnContactsSaveLoading extends FormEmployeeState {}

class OnContactsSuccess extends FormEmployeeState {
  final List<CustomContact> contacts;
  const OnContactsSuccess(this.contacts);
}

class OnContactsFailed extends FormEmployeeFailed {
  const OnContactsFailed(super.message);
}

class OnContactsSaveSuccess extends FormEmployeeState {}

class OnContactsSaveFailed extends FormEmployeeFailed {
  const OnContactsSaveFailed(super.message);
}
