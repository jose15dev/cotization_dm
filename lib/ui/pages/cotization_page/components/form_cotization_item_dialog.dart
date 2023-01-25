import 'package:cotizacion_dm/core/domain/cotization/cotization.dart';
import 'package:cotizacion_dm/ui/pages/cotization_page/bloc/form_cotization_item_bloc/form_cotization_item_cubit.dart';
import 'package:cotizacion_dm/ui/styled/loading_indicator.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'heading_textfield.dart';

class FormCotizationItemDialog extends StatelessWidget {
  final CotizationItem? item;
  final Color background;
  final Color foreground;
  final bool? onCopy;
  const FormCotizationItemDialog(
    this.item, {
    super.key,
    required this.background,
    required this.foreground,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FormCotizationItemCubit>(
      create: (context) => FormCotizationItemCubit(),
      child: FormCotizationItemContent(item,
          background: background,
          foreground: foreground,
          onCopy: onCopy ?? false),
    );
  }
}

class FormCotizationItemContent extends StatefulWidget {
  final Color background;
  final Color foreground;
  final CotizationItem? item;
  final bool onCopy;
  const FormCotizationItemContent(
    this.item, {
    super.key,
    required this.background,
    required this.foreground,
    required this.onCopy,
  });

  @override
  State<FormCotizationItemContent> createState() =>
      _FormCotizationItemContentState();
}

class _FormCotizationItemContentState extends State<FormCotizationItemContent> {
  Color msgColor = Colors.grey.shade600;
  bool enabledToSave = false;

  late TextEditingController _nameCtrl,
      _descCtrl,
      _unitCtrl,
      _amountCtrl,
      _unitValueCtrl;
  FormCotizationItemCubit get formBloc => BlocProvider.of(context);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var item = widget.item;
    if (item is CotizationItem) {
      formBloc.loadItem(item, widget.onCopy);
      _nameCtrl = TextEditingController(text: item.name);
      _descCtrl = TextEditingController(text: item.description);
      _unitCtrl = TextEditingController(text: item.unit);
      _amountCtrl = TextEditingController(text: item.amount.toString());
      _unitValueCtrl = TextEditingController(
          text: CurrencyUtility.doubleToCurrency(item.unitValue));
    } else {
      _nameCtrl = TextEditingController();
      _descCtrl = TextEditingController();
      _unitCtrl = TextEditingController();
      _amountCtrl = TextEditingController();
      _unitValueCtrl = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      alignment: Alignment.center,
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: BlocConsumer<FormCotizationItemCubit, FormCotizationItemState>(
        listener: (context, state) {
          if (state is FormCotizationItemSaveSuccess) {
            Navigator.of(context).pop({
              "newItem": state.item,
              "oldItem": state.oldItem,
            });
          }
        },
        builder: (context, state) {
          if (state is FormCotizationItemSaveLoading) {
            return Center(
              child: LoadingIndicator(color: widget.background),
            );
          }
          return SizedBox(
            width: size.width,
            height: size.height / 1.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _heading(),
                _calcItem(size),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _calcItem(Size size) {
    return BlocConsumer<FormCotizationItemCubit, FormCotizationItemState>(
      listener: (context, state) {
        if (state is FormCotizationItemFailed ||
            state is FormCotizationItemSaveFailed) {
          setState(() {
            enabledToSave = false;
            msgColor = ColorPalete.error;
          });
        }
        if (state is FormCotizationItemValidationSuccess) {
          setState(() {
            msgColor = Colors.grey.shade600;
          });
        }

        if (state is FormCotizationItemSuccess) {
          setState(() {
            enabledToSave = true;
          });
        }
      },
      builder: (context, state) {
        Widget msg = Container();
        if (state is FormCotizationItemFailed) {
          msg = Text(
            state.message,
            style: TextStyle(
              color: msgColor,
            ),
            textAlign: TextAlign.center,
          );
        }
        if (state is FormCotizationItemSuccess) {
          msg = Text(
            "Toque aqui para guardar",
            style: TextStyle(
              color: msgColor,
            ),
            textAlign: TextAlign.center,
          );
        }

        if (state is FormCotizationItemFailed) {
          msg = Text(
            state.message,
            style: TextStyle(
              color: msgColor,
            ),
            textAlign: TextAlign.center,
          );
        }

        return Expanded(
          child: InkWell(
            onTap: enabledToSave ? formBloc.save : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StreamBuilder<double>(
                    stream: formBloc.totalValueStream,
                    builder: (context, snapshot) {
                      return Text(
                        CurrencyUtility.doubleToCurrency(snapshot.data ?? 0),
                        style: TextStyle(
                          color: msgColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }),
                msg,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _heading() {
    var fontSize = 20.0;
    final CurrencyTextInputFormatter formatter = CurrencyTextInputFormatter(
      symbol: "\$",
      decimalDigits: 1,
    );
    return Container(
      color: widget.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HeadingTextField(
              title: "Nombre del servicio",
              fontSize: 25,
              color: widget.foreground,
              maxLines: 2,
              onChange: formBloc.updateName,
              controller: _nameCtrl,
            ),
            HeadingTextField(
              title: "Descripcion",
              fontSize: fontSize,
              maxLines: 3,
              color: widget.foreground,
              onChange: formBloc.updateDescription,
              controller: _descCtrl,
            ),
            HeadingTextField(
              title: "Unidad",
              fontSize: fontSize,
              maxLines: 3,
              color: widget.foreground,
              onChange: formBloc.updateUnit,
              controller: _unitCtrl,
            ),
            HeadingTextField(
              title: "Cantidad",
              fontSize: fontSize,
              maxLines: 3,
              color: widget.foreground,
              type: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChange: formBloc.updateAmount,
              controller: _amountCtrl,
            ),
            HeadingTextField(
              title: "Valor Unitario",
              fontSize: fontSize,
              maxLines: 3,
              color: widget.foreground,
              type: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                formatter,
              ],
              onChange: formBloc.updateUnitValue,
              controller: _unitValueCtrl,
            ),
          ],
        ),
      ),
    );
  }
}
