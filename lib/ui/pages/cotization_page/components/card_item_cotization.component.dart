import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/pages/cotization_page/bloc/form_cotization_bloc/form_cotization_cubit.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CardItemCotization extends StatefulWidget {
  final CotizationItem item;
  final bool activeActions;
  final FormCotizationCubit bloc;
  const CardItemCotization(this.item,
      {required Key key, required this.bloc, required this.activeActions})
      : super(key: key);

  @override
  State<CardItemCotization> createState() => _CardItemCotizationState();
}

class _CardItemCotizationState extends State<CardItemCotization> {
  Offset? _tapPosition;
  void _showPopupMenu() {
    final RenderObject? overlay =
        Overlay.of(context)?.context.findRenderObject();
    if (_tapPosition != null && overlay != null) {
      var rect = _tapPosition! & const Size(40, 40);
      var container = overlay.paintBounds;
      showMenu(
          context: context,
          position: RelativeRect.fromRect(rect, container),
          color: ColorPalete.white,
          items: [const PopupMenuPosition()]).then((value) {
        if (value is PopupMenuActionPosition) {
          switch (value) {
            case PopupMenuActionPosition.down:
              {
                widget.bloc.onMoveDown(widget.item);
                break;
              }

            case PopupMenuActionPosition.up:
              {
                widget.bloc.onMoveUp(widget.item);
                break;
              }
          }
        }
      });
    }
  }

  void _storePosition(TapDownDetails details) {
    setState(() {
      _tapPosition = details.globalPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activeActions) {
      return Slidable(
        key: widget.key,
        startActionPane: _actionsLeft(),
        endActionPane: _actionsRight(),
        child: _description(),
      );
    }
    return _description();
  }

  ActionPane _actionsRight() {
    return ActionPane(motion: const BehindMotion(), children: [
      SlidableAction(
        label: "Copiar",
        icon: Icons.copy,
        onPressed: (_) => widget.bloc.onCopyItem(widget.item),
        foregroundColor: ColorPalete.white,
        backgroundColor: ColorPalete.primary,
      ),
    ]);
  }

  ActionPane _actionsLeft() {
    var extentRatio = 0.65;
    return ActionPane(
      extentRatio: extentRatio,
      motion: const BehindMotion(),
      children: [
        SlidableAction(
          label: "Eliminar",
          icon: Icons.delete,
          onPressed: (_) => widget.bloc.removeItem(widget.item),
          foregroundColor: ColorPalete.white,
          backgroundColor: ColorPalete.error,
        ),
        SlidableAction(
          label: "Editar",
          icon: Icons.edit,
          onPressed: (_) => widget.bloc.onEditItem(widget.item),
          foregroundColor: ColorPalete.white,
          backgroundColor: ColorPalete.primary,
        ),
      ],
    );
  }

  Widget _description() {
    var foreground = Colors.grey.shade900;
    return InkWell(
      onTap: widget.activeActions ? _showPopupMenu : null,
      onTapDown: _storePosition,
      child: ListTile(
        key: widget.key,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 2,
                  ),
                  Text(
                    "${widget.item.amount} ${widget.item.unit}",
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.normal,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Text(
          CurrencyUtility.doubleToCurrency(widget.item.total),
          style: TextStyle(
            color: foreground,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}

enum PopupMenuActionPosition {
  down,
  up,
}

class PopupMenuPosition extends PopupMenuEntry<PopupMenuActionPosition> {
  const PopupMenuPosition({super.key});

  @override
  State<PopupMenuPosition> createState() => _PopupMenuState();

  @override
  // TODO: implement height
  double get height => 100;

  @override
  bool represents(PopupMenuActionPosition? value) {
    return true;
  }
}

class _PopupMenuState extends State<PopupMenuPosition> {
  void onDown() {
    Navigator.of(context).pop(PopupMenuActionPosition.down);
  }

  void onUp() {
    Navigator.of(context).pop(PopupMenuActionPosition.up);
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      TextButton(
        onPressed: onUp,
        child: const Text(
          "Subir",
        ),
      ),
      TextButton(
        onPressed: onDown,
        child: const Text(
          "Bajar",
        ),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
