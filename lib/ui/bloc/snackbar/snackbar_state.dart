part of 'snackbar_bloc.dart';

abstract class SnackbarState extends Equatable {
  const SnackbarState();

  @override
  List<Object> get props => [];
}

class SnackbarInitial extends SnackbarState {}

class ShowSnackbarState extends SnackbarState {
  final MessageType type;
  final String? message;
  final String? action;
  final Function()? actionCallback;

  const ShowSnackbarState(this.type,
      {this.message, this.action, this.actionCallback});
}

class ShowBannerState extends SnackbarState {
  final MessageType type;
  final String? message;
  final List<Widget> actions;

  const ShowBannerState(this.type, {this.message, this.actions = const []});
}
