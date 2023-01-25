part of 'fetch_cotization_cubit.dart';

abstract class FetchCotizationState extends Equatable {
  const FetchCotizationState();

  @override
  List<Object> get props => [];
}

class FetchCotizationInitial extends FetchCotizationState {}

abstract class FetchCotizationFailed extends FetchCotizationState {
  final String message;

  const FetchCotizationFailed(this.message);
}

class OnFetchCotizationSuccess extends FetchCotizationState {}

class OnFetchCotizationEmpty extends FetchCotizationState {}

class OnFetchCotizationLoading extends FetchCotizationState {}

class OnActionCotizationFailed extends FetchCotizationFailed {
  const OnActionCotizationFailed(super.message);
}

class OnActionCotizationLoading extends FetchCotizationState {}

class OnActionCotizationSuccess extends FetchCotizationState {}

class OnCreateCotization extends FetchCotizationState {}

class OnEditCotization extends FetchCotizationState {
  final Cotization cotization;
  final bool onCopy;

  const OnEditCotization(this.cotization, this.onCopy);
}

class OnShowCotization extends FetchCotizationState {
  final Cotization cotization;

  const OnShowCotization(this.cotization);
}

class OnExportCotizationFailed extends FetchCotizationFailed {
  const OnExportCotizationFailed(super.message);
}
