part of 'create_liquidation_cubit.dart';

abstract class CreateLiquidationState extends Equatable {
  const CreateLiquidationState();

  @override
  List<Object> get props => [];
}

class CreateLiquidationInitial extends CreateLiquidationState {}

class CreateLiquidationOnEmployeeSelected extends CreateLiquidationState {}

class CreateLiquidationOnSend extends CreateLiquidationState {
  final Liquidation liquidation;

  const CreateLiquidationOnSend(this.liquidation);
}
