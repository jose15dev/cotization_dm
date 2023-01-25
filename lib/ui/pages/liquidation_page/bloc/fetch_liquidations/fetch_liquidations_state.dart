part of 'fetch_liquidations_cubit.dart';

abstract class FetchLiquidationsState extends Equatable {
  const FetchLiquidationsState();

  @override
  List<Object> get props => [];
}

class FetchLiquidationsInitial extends FetchLiquidationsState {}

class FetchLiquidationOnSuccess extends FetchLiquidationsState {}

class FetchLiquidationOnCreateSuccess extends FetchLiquidationsState {}

class FetchLiquidationOnCreate extends FetchLiquidationsState {}

class FetchLiquidationOnEmpty extends FetchLiquidationsState {}

class FetchLiquidationOnLoading extends FetchLiquidationsState {}

class FetchLiquidationFailed extends FetchLiquidationsState {
  final String message;

  const FetchLiquidationFailed(this.message);
}
