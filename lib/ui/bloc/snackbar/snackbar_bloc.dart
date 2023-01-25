import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'snackbar_event.dart';
part 'snackbar_state.dart';

class SnackbarBloc extends Bloc<SnackbarEvent, SnackbarState> {
  SnackbarBloc() : super(SnackbarInitial()) {
    on<SnackbarEvent>((event, emit) async {
      await emit.forEach(_buildEventAsState(event), onData: (state) => state);
    });
  }

  Stream<SnackbarState> _buildEventAsState(SnackbarEvent event) async* {
    if (event is ErrorSnackbarEvent) {
      yield _snackbarState(MessageType.error, event);
    }
    if (event is WarningSnackbarEvent) {
      yield _snackbarState(MessageType.warning, event);
    }
    if (event is SuccessSnackbarEvent) {
      yield _snackbarState(MessageType.success, event);
    }

    if (event is ErrorBannerEvent) {
      yield _bannerState(MessageType.error, event);
    }
    if (event is WarningBannerEvent) {
      yield _bannerState(MessageType.warning, event);
    }
    if (event is SuccessBannerEvent) {
      yield _bannerState(MessageType.success, event);
    }

    await DelayUtility.custom(3);

    yield SnackbarInitial();
  }

  ShowBannerState _bannerState(MessageType type, BaseBannerEvent event) {
    return ShowBannerState(
      type,
      message: event.message,
      actions: event.actions,
    );
  }

  ShowSnackbarState _snackbarState(MessageType type, BaseSnackbarEvent event) {
    return ShowSnackbarState(type,
        message: event.message,
        action: event.action,
        actionCallback: event.actionCallback);
  }
}
