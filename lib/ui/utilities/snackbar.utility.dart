import 'package:cotizacion_dm/globals.dart';
import 'package:cotizacion_dm/ui/bloc/snackbar/snackbar_bloc.dart';
import 'package:cotizacion_dm/ui/utilities/theme_utility.dart';
import 'package:flutter/material.dart';

enum MessageType {
  success,
  error,
  warning,
}

abstract class SnackbarUtility {
  static SnackBar snackbar(ShowSnackbarState state) {
    var type = state.type;
    switch (type) {
      case MessageType.error:
        {
          return _buildSnackbar(state.message, ColorPalete.error,
              state.actionCallback, state.action, ColorPalete.white);
        }

      default:
        {
          return _buildSnackbar(state.message, ColorPalete.primary,
              state.actionCallback, state.action, ColorPalete.white);
        }
    }
  }

  static SnackBar _buildSnackbar(
    String? message,
    Color? color,
    Function()? actionCallback,
    String? actionName, [
    Color? foreground,
  ]) {
    return SnackBar(
      backgroundColor: color,
      content: Text(
        message ?? "",
        style: TextStyle(color: foreground),
      ),
      action: actionCallback != null && actionName != null
          ? SnackBarAction(
              label: actionName,
              onPressed: actionCallback,
            )
          : null,
    );
  }
}

abstract class BannerUtility {
  static MaterialBanner banner(ShowBannerState state) {
    var type = state.type;
    switch (type) {
      case MessageType.error:
        {
          return _buildSnackbar(state.message, ColorPalete.error, state.actions,
              ColorPalete.white);
        }

      default:
        {
          return _buildSnackbar(state.message, ColorPalete.primary,
              state.actions, ColorPalete.white);
        }
    }
  }

  static MaterialBanner _buildSnackbar(
    String? message,
    Color? color, [
    List<Widget> actions = const [],
    Color? foreground,
  ]) {
    if (actions.isEmpty) {
      actions = [
        TextButton(
          onPressed: messagerKey.currentState?.hideCurrentMaterialBanner,
          child: Text("OK", style: TextStyle(color: foreground)),
        )
      ];
    }
    return MaterialBanner(
      backgroundColor: color,
      content: Text(
        message ?? "",
        style: TextStyle(color: foreground),
      ),
      actions: actions,
    );
  }
}
