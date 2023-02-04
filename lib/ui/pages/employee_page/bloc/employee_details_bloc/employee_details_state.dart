part of 'employee_details_cubit.dart';

abstract class EmployeeDetailsState extends Equatable {
  const EmployeeDetailsState();

  @override
  List<Object> get props => [];
}

class EmployeeDetailsInitial extends EmployeeDetailsState {}

class OnCallLoading extends EmployeeDetailsState {}

class OnCallSuccess extends EmployeeDetailsState {}

class OnActionFailed extends EmployeeDetailsState {
  final String message;

  const OnActionFailed(this.message);
}

class OnWhatsappChatLoading extends EmployeeDetailsState {}

class OnWhatsappChatSuccess extends EmployeeDetailsState {}

class OnGetLiquidationsEmpty extends EmployeeDetailsState {}

class OnGetLiquidationsSuccess extends EmployeeDetailsState {}

class OnDeleteAnimationCard extends EmployeeDetailsState {}

class OnDeleteAnimationTrash extends EmployeeDetailsState {}
