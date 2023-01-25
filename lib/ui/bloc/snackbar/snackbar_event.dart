part of 'snackbar_bloc.dart';

abstract class SnackbarEvent extends Equatable {
  const SnackbarEvent();

  @override
  List<Object> get props => [];
}

abstract class BaseSnackbarEvent extends SnackbarEvent {
  final String? message;
  final String? action;
  final Function()? actionCallback;

  const BaseSnackbarEvent(this.message, {this.action, this.actionCallback});
}

class ErrorSnackbarEvent extends BaseSnackbarEvent {
  const ErrorSnackbarEvent(super.message, {super.action, super.actionCallback});
}

class SuccessSnackbarEvent extends BaseSnackbarEvent {
  const SuccessSnackbarEvent(super.message,
      {super.action, super.actionCallback});
}

class WarningSnackbarEvent extends BaseSnackbarEvent {
  const WarningSnackbarEvent(super.message,
      {super.action, super.actionCallback});
}

abstract class BaseBannerEvent extends SnackbarEvent {
  final String? message;
  final List<Widget> actions;

  const BaseBannerEvent(this.message, {required this.actions});
}

class ErrorBannerEvent extends BaseBannerEvent {
  ErrorBannerEvent(super.message, {super.actions = const []});
}

class SuccessBannerEvent extends BaseBannerEvent {
  SuccessBannerEvent(super.message, {super.actions = const []});
}

class WarningBannerEvent extends BaseBannerEvent {
  WarningBannerEvent(super.message, {super.actions = const []});
}
