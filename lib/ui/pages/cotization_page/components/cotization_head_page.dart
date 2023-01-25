import 'dart:ui';

import 'package:cotizacion_dm/core/domain/cotization/cotization.dart';
import 'package:cotizacion_dm/core/infrastructure/configuration/pdf/pdf_cotization_service.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/bloc/setup_properties/setup_properties_cubit.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CotizationHeadDelegate extends SliverPersistentHeaderDelegate {
  final double _maxExtended;
  final bool onlyShow;
  final Color selectedColor, textColor;
  final Cotization? cotization;

  CotizationHeadDelegate(this._maxExtended, this.onlyShow, this.selectedColor,
      this.textColor, this.cotization);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var t = shrinkOffset / (_maxExtended);

    if (t * _maxExtended >= _maxExtended - minExtent) {
      t = 1;
    }

    return CotizationHeadPage(
      onlyShow: onlyShow,
      selectedColor: selectedColor,
      textColor: textColor,
      t: t,
      cotization: cotization,
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => _maxExtended;

  @override
  // TODO: implement minExtent
  double get minExtent => 300;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class CotizationHeadPage extends StatefulWidget {
  const CotizationHeadPage({
    Key? key,
    required this.onlyShow,
    required this.selectedColor,
    required this.textColor,
    required this.t,
    this.cotization,
  }) : super(key: key);

  final double t;
  final Color selectedColor;
  final Color textColor;
  final Cotization? cotization;
  final bool onlyShow;

  @override
  State<CotizationHeadPage> createState() => _CotizationHeadPageState();
}

class _CotizationHeadPageState extends State<CotizationHeadPage> {
  late TextEditingController _nameCtrl, _descCtrl;

  FormCotizationCubit get blocProvider =>
      BlocProvider.of<FormCotizationCubit>(context);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameCtrl = TextEditingController(text: widget.cotization?.name ?? "");
    _descCtrl =
        TextEditingController(text: widget.cotization?.description ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          alignment: FractionalOffset.center,
          color: widget.selectedColor,
          child: Stack(
            children: [
              Align(
                alignment: FractionalOffset(
                    0.5, lerpDouble(0.3, 0.4, widget.t) ?? 0.3),
                child: _name(),
              ),
              Align(
                alignment: FractionalOffset(
                    0.5, lerpDouble(0.45, 0.6, widget.t) ?? 0.4),
                child: _description(),
              ),
              Align(
                alignment: FractionalOffset(
                    0.5, lerpDouble(0.58, 0.7, widget.t) ?? 0.5),
                child: _value(),
              ),
              Transform.scale(
                scale: lerpDouble(1, 0, widget.t),
                child: Opacity(
                  opacity: 1 - widget.t,
                  child: Align(
                    alignment: FractionalOffset(
                        0.5, lerpDouble(0.8, 1, widget.t) ?? 0.8),
                    child: _viewButton(),
                  ),
                ),
              )
            ],
          ),
        ),
        widget.onlyShow
            ? Container()
            : Align(
                alignment: FractionalOffset(
                    0.95, lerpDouble(0.1, 0.15, widget.t) ?? 0.1),
                child: StreamBuilder<bool>(
                    stream: blocProvider.validateForm,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var enabled = snapshot.data ?? false;
                        if (enabled) {
                          return IconButton(
                            onPressed: blocProvider.tryToSave,
                            icon: Icon(
                              Icons.save,
                              color: widget.textColor,
                              size: 35,
                            ),
                          );
                        }
                      }

                      return Container();
                    }),
              ),
      ],
    );
  }

  Widget? _viewButton() {
    var borderRadius = BorderRadius.circular(20.0);
    FetchCotizationCubit fetchBloc = BlocProvider.of(context);
    return widget.onlyShow
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                PDFCotizationService service = getIt();
                fetchBloc.exportToPDF(widget.cotization!, service);
              },
              borderRadius: borderRadius,
              child: Ink(
                decoration: BoxDecoration(
                    color: widget.textColor, borderRadius: borderRadius),
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 10.0),
                child: Text(
                    widget.cotization?.finished ?? false
                        ? "Visualizar"
                        : "Previsualizar",
                    style: TextStyle(
                      fontSize: 20,
                      color: widget.selectedColor,
                    )),
              ),
            ),
          )
        : null;
  }

  Widget _value() {
    return StreamBuilder<double>(
        stream: blocProvider.totalStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var value = snapshot.data ?? 0.0;
            return StreamBuilder<double?>(
                stream: blocProvider.taxStream,
                builder: (context, snapshotTax) {
                  if (snapshotTax.hasData) {
                    if (snapshotTax.data != null) {
                      return StreamBuilder<TaxPercentOption?>(
                          stream: BlocProvider.of<SetupPropertiesCubit>(context)
                              .taxPercentOptionStream,
                          builder: (context, snapshot) {
                            var percent = snapshot.data?.percent ?? 0.0;
                            var taxes = value * percent;
                            var valueTaxes = value * (1 + percent);
                            return Text(
                              "${CurrencyUtility.doubleToCurrency(value)} + ${CurrencyUtility.doubleToCurrency(taxes)} = ${CurrencyUtility.doubleToCurrency(valueTaxes)}",
                              style: TextStyle(
                                fontSize: 20,
                                color: widget.textColor,
                              ),
                              textAlign: TextAlign.center,
                            );
                          });
                    }
                  }
                  return Text(
                    CurrencyUtility.doubleToCurrency(value),
                    style: TextStyle(
                      fontSize: 20,
                      color: widget.textColor,
                    ),
                    textAlign: TextAlign.center,
                  );
                });
          }
          return Container();
        });
  }

  Widget _description() {
    if (widget.onlyShow) {
      return StreamBuilder<String>(
        stream: blocProvider.descStream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              snapshot.data ?? "",
              style: TextStyle(
                color: widget.textColor,
                fontSize: 22,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    }
    return HeadingTextField(
      onChange: blocProvider.updateDescription,
      title: "Descripcion",
      fontSize: 22,
      maxLines: 3,
      color: widget.textColor,
      controller: _descCtrl,
    );
  }

  Widget _name() {
    if (widget.onlyShow) {
      return StreamBuilder<String>(
        stream: blocProvider.nameStream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              snapshot.data ?? "",
              style: TextStyle(
                color: widget.textColor,
                fontSize: 30,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    }
    return HeadingTextField(
      onChange: blocProvider.updateName,
      title: "Nombre descriptivo",
      fontSize: 30,
      color: widget.textColor,
      maxLines: 2,
      controller: _nameCtrl,
    );
  }
}
