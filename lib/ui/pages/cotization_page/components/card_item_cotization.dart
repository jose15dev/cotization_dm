import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/pages/cotization_page/bloc/form_cotization_bloc/form_cotization_cubit.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CardItemCotization extends StatefulWidget {
  final CotizationItem item;
  final bool activeActions;
  final FormCotizationCubit? bloc;
  final Color? color;
  const CardItemCotization(this.item,
      {super.key, this.bloc, required this.activeActions, this.color})
      : assert(activeActions == true ? bloc != null : true);

  @override
  State<CardItemCotization> createState() => _CardItemCotizationState();
}

class _CardItemCotizationState extends State<CardItemCotization> {
  bool _isHover = false;
  Offset? _tapPosition;
  void _onResultPopupMenu(MenuActionResult? value) {
    switch (value?.action) {
      case null:
        break;
      case PopupMenuActionPosition.down:
        {
          widget.bloc?.onMoveDown(widget.item);
          break;
        }

      case PopupMenuActionPosition.up:
        {
          widget.bloc?.onMoveUp(widget.item);
          break;
        }
      case PopupMenuActionPosition.copy:
        widget.bloc?.onCopyItem(widget.item, value!.position);
        break;
      case PopupMenuActionPosition.edit:
        widget.bloc?.onEditItem(widget.item, value!.position);
        break;
      case PopupMenuActionPosition.delete:
        widget.bloc?.removeItem(widget.item);
        break;
    }
  }

  void _showPopupMenuSecondary() {
    setState(() {
      _isHover = true;
    });
    _onShowMenu<MenuActionResult>(
        menu: PopupMenuSecondaryActions(
      color: widget.color ?? ColorPalete.primary,
    )).then((value) {
      setState(() {
        _isHover = false;
      });
      _onResultPopupMenu(value);
    });
  }

  void _showPopupMenuPrimary() {
    setState(() {
      _isHover = true;
    });
    _onShowMenu<MenuActionResult>(
        menu: PopupMenuPrimaryActions(
      color: widget.color ?? ColorPalete.primary,
    )).then((value) {
      setState(() {
        _isHover = false;
      });
      _onResultPopupMenu(value);
    });
  }

  Future<T?> _onShowMenu<T>({required PopupMenuEntry<T> menu}) {
    final RenderObject? overlay =
        Overlay.of(context)?.context.findRenderObject();
    if (_tapPosition != null && overlay != null) {
      var rect = _tapPosition! & const Size(40, 40);
      var container = overlay.paintBounds;
      return showMenu<T>(
          context: context,
          position: RelativeRect.fromRect(rect, container),
          color: ColorPalete.white,
          items: [
            menu,
          ]);
    }

    return Future.value(null);
  }

  void _storePosition(TapDownDetails details) {
    setState(() {
      _tapPosition = details.globalPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.activeActions ? _showPopupMenuPrimary : null,
      onLongPress: widget.activeActions ? _showPopupMenuSecondary : null,
      onTapDown: _storePosition,
      child: _CotizationItemWidget(
        item: widget.item,
        isHover: _isHover,
      ),
    );
  }
}

class _CotizationItemWidget extends StatelessWidget {
  const _CotizationItemWidget({
    Key? key,
    required this.item,
    this.isHover = false,
  }) : super(key: key);

  final CotizationItem item;
  final bool isHover;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: isHover ? Colors.grey.shade300 : null,
      title: Row(
        children: [
          const Icon(
            FontAwesomeIcons.circleInfo,
            size: 40,
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                Text("${item.amount} ${item.unit}"),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text('Precio: '),
                        Text(CurrencyUtility.doubleToCurrency(item.unitValue)),
                      ],
                    ),
                    Text(
                      CurrencyUtility.doubleToCurrency(item.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum PopupMenuActionPosition {
  down,
  up,
  copy,
  edit,
  delete,
}

class MenuActionResult {
  final Offset position;
  final PopupMenuActionPosition action;

  MenuActionResult(this.position, this.action);
}

const gap = SizedBox(height: 5);

class PopupMenuSecondaryActions extends PopupMenuEntry<MenuActionResult> {
  final Color color;
  const PopupMenuSecondaryActions({super.key, required this.color});

  @override
  State<PopupMenuSecondaryActions> createState() =>
      _PopupMenuSecondaryActionsState();

  @override
  // TODO: implement height
  double get height => 100;

  @override
  bool represents(MenuActionResult? value) {
    return true;
  }
}

class _PopupMenuSecondaryActionsState extends State<PopupMenuSecondaryActions> {
  void onDown(details) {
    Navigator.of(context)
        .pop(MenuActionResult(Offset.zero, PopupMenuActionPosition.down));
  }

  void onUp(details) {
    Navigator.of(context)
        .pop(MenuActionResult(Offset.zero, PopupMenuActionPosition.up));
  }

  @override
  Widget build(BuildContext context) {
    const spacer = SizedBox(height: 5);
    var children = <Widget>[
      _MenuAction(
          icon: FontAwesomeIcons.arrowUpAZ,
          text: "Subir",
          foreground: widget.color,
          onTap: onUp),
      spacer,
      _MenuAction(
          icon: FontAwesomeIcons.arrowDownAZ,
          text: "Bajar",
          foreground: widget.color,
          onTap: onDown),
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class PopupMenuPrimaryActions extends PopupMenuEntry<MenuActionResult> {
  final Color color;
  const PopupMenuPrimaryActions({super.key, required this.color});

  @override
  State<PopupMenuPrimaryActions> createState() =>
      _PopupMenuPrimaryActionsState();

  @override
  // TODO: implement height
  double get height => 100;

  @override
  bool represents(MenuActionResult? value) {
    return true;
  }
}

class _PopupMenuPrimaryActionsState extends State<PopupMenuPrimaryActions> {
  void onCopy(TapDownDetails details) {
    Navigator.of(context).pop(
        MenuActionResult(details.globalPosition, PopupMenuActionPosition.copy));
  }

  void onEdit(TapDownDetails details) {
    Navigator.of(context).pop(
        MenuActionResult(details.globalPosition, PopupMenuActionPosition.edit));
  }

  void onDelete(details) {
    Navigator.of(context).pop(PopupMenuActionPosition.delete);
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      _MenuAction(
          icon: FontAwesomeIcons.copy,
          text: "Copiar",
          foreground: widget.color,
          onTap: onCopy),
      gap,
      _MenuAction(
          icon: FontAwesomeIcons.penToSquare,
          text: "Editar",
          foreground: widget.color,
          onTap: onEdit),
      gap,
      _MenuAction(
          icon: FontAwesomeIcons.trashCan,
          text: "Eliminar",
          foreground: widget.color,
          onTap: onDelete),
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color foreground;
  final GestureTapDownCallback onTap;
  const _MenuAction(
      {required this.icon,
      required this.text,
      required this.foreground,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Icon(
            icon,
            color: foreground,
            size: 25,
          ),
          const SizedBox(
            width: 15,
          ),
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: 18,
            ),
          ),
        ]),
      ),
    );
  }
}
