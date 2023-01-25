part of 'fetch_employee_cubit.dart';

abstract class FetchEmployeeState extends Equatable {
  const FetchEmployeeState();

  @override
  List<Object> get props => [];
}

class FetchEmployeeInitial extends FetchEmployeeState {}

class OnFetchEmployeeLoading extends FetchEmployeeState {}

class OnFetchEmployeeEmpty extends FetchEmployeeState {}

class OnFetchEmployeeSuccess extends FetchEmployeeState {}

abstract class FetchEmployeeFailed extends FetchEmployeeState {
  final String message;

  const FetchEmployeeFailed(this.message);
}

class OnActionEmployeeLoading extends FetchEmployeeState {}

class OnActionEmployeeSuccess extends FetchEmployeeState {}

class OnActionEmployeeFailed extends FetchEmployeeFailed {
  const OnActionEmployeeFailed(super.message);
}

class FetchEmployeeOnEdit extends FetchEmployeeState {
  final Employee employee;

  const FetchEmployeeOnEdit(this.employee);
}

class FetchEmployeeOnShow extends FetchEmployeeState {
  final Employee employee;

  const FetchEmployeeOnShow(this.employee);
}

class FetchEmployeeOnCreate extends FetchEmployeeState {}

class OnUpdateEmployeeSuccess extends OnActionEmployeeSuccess {
  final Employee employee;

  OnUpdateEmployeeSuccess(this.employee);
}
