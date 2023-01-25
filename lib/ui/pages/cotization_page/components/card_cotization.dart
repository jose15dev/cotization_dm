import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/configuration/dependency_injection/injection.dart';
import 'package:cotizacion_dm/core/infrastructure/configuration/pdf/pdf_cotization_service.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardCotization extends StatefulWidget {
  const CardCotization(
    this.cotization, {
    Key? key,
  }) : super(key: key);

  final Cotization cotization;

  @override
  State<CardCotization> createState() => _CardCotizationState();
}

class _CardCotizationState extends State<CardCotization> {
  FetchCotizationCubit get bloc => BlocProvider.of(context);
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
              items: [PopupMenu(isFinished: widget.cotization.finished)])
          .then((value) {
        if (value is PopupMenuAction) {
          switch (value) {
            case PopupMenuAction.delete:
              {
                _dialogFinish();
                break;
              }
            case PopupMenuAction.edit:
              {
                bloc.onEditCotization(widget.cotization);
                break;
              }

            case PopupMenuAction.finish:
              {
                bloc.onFinishCotization(widget.cotization);
                PDFCotizationService service = getIt();
                bloc.exportToPDF(widget.cotization, service);
                break;
              }
            case PopupMenuAction.visualize:
              {
                PDFCotizationService service = getIt();
                bloc.exportToPDF(widget.cotization, service);
                break;
              }
            case PopupMenuAction.copy:
              {
                bloc.onEditCotization(widget.cotization, true);
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
    var borderRadius = BorderRadius.circular(40.0);

    var fg = Color(widget.cotization.color);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => bloc.onShowCotization(widget.cotization),
        onLongPress: _showPopupMenu,
        onTapDown: _storePosition,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: Color(widget.cotization.color).withOpacity(0.3),
            borderRadius: borderRadius,
          ),
          child: Stack(
            children: [
              Align(
                alignment: FractionalOffset.center,
                child: _info(fg),
              ),
              Align(
                alignment: FractionalOffset.bottomRight,
                child: Icon(
                  widget.cotization.finished
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  size: 25,
                  color: fg,
                ),
              ),
              widget.cotization.isAccount
                  ? Align(
                      alignment: FractionalOffset.topRight,
                      child: Icon(
                        Icons.account_balance,
                        size: 25,
                        color: fg,
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(Color fg) {
    var value = widget.cotization.total;
    var total = (1 + (widget.cotization.tax ?? 0.0)) * value;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.cotization.name,
          style: TextStyle(
            color: fg,
            fontSize: 20.0,
          ),
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
        Text(
          widget.cotization.description,
          style: TextStyle(
            color: fg,
            fontSize: 15.0,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          CurrencyUtility.doubleToCurrency(total),
          style: TextStyle(
            color: fg,
            fontSize: 15.0,
          ),
        ),
      ],
    );
  }

  Future<void> _dialogFinish() async {
    bool? res = await showDialog(
      context: context,
      builder: ((context) {
        return FinishDialog(
          title: "Desea eliminar la cotization?",
          selectedColor: Color(widget.cotization.color),
        );
      }),
    );

    if (res is bool && res) {
      bloc.deleteCotization(widget.cotization);
    } else {
      bloc.resetState();
    }
  }
}

enum PopupMenuAction {
  edit,
  delete,
  finish,
  copy,
  visualize,
}

class PopupMenu extends PopupMenuEntry<PopupMenuAction> {
  final bool isFinished;
  const PopupMenu({super.key, required this.isFinished});

  @override
  State<PopupMenu> createState() => _PopupMenuState();

  @override
  // TODO: implement height
  double get height => 100;

  @override
  bool represents(PopupMenuAction? value) {
    return true;
  }
}

class _PopupMenuState extends State<PopupMenu> {
  void onDelete() {
    Navigator.of(context).pop(PopupMenuAction.delete);
  }

  void onEdit() {
    Navigator.of(context).pop(PopupMenuAction.edit);
  }

  void onFinish() {
    Navigator.of(context).pop(PopupMenuAction.finish);
  }

  void onCopy() {
    Navigator.of(context).pop(PopupMenuAction.copy);
  }

  void onVisualize() {
    Navigator.of(context).pop(PopupMenuAction.visualize);
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      TextButton(
        onPressed: onCopy,
        child: const Text(
          "Copiar",
        ),
      ),
    ];
    if (widget.isFinished) {
      children.addAll([
        TextButton(
          onPressed: onDelete,
          child: const Text(
            "Eliminar",
          ),
        ),
        TextButton(
          onPressed: onVisualize,
          child: const Text(
            "Visualizar",
          ),
        ),
      ]);
    } else {
      children = [
        TextButton(
          onPressed: onDelete,
          child: const Text(
            "Descartar",
          ),
        ),
        TextButton(
          onPressed: onEdit,
          child: const Text(
            "Editar",
          ),
        ),
        TextButton(
          onPressed: onFinish,
          child: const Text(
            "Entregar",
          ),
        ),
      ];
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
