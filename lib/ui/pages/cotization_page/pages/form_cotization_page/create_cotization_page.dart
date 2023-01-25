import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/bloc/bloc.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/styled/styled.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateCotizationPage extends StatelessWidget {
  final Cotization? cotization;
  final bool onCopy;
  final bool onlyShow;
  const CreateCotizationPage({
    super.key,
    this.cotization,
    required this.onCopy,
    required this.onlyShow,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FormCotizationCubit(),
      child: CreateCotizationView(
        cotization,
        onCopy: onCopy,
        onlyShow: onlyShow,
      ),
    );
  }
}

class CreateCotizationView extends StatefulWidget {
  final Cotization? cotization;
  final bool onCopy;
  final bool onlyShow;
  const CreateCotizationView(this.cotization,
      {super.key, required this.onCopy, required this.onlyShow});

  @override
  State<CreateCotizationView> createState() => _CreateCotizationViewState();
}

class _CreateCotizationViewState extends State<CreateCotizationView> {
  late Color selectedColor;
  late Color textColor;
  late bool onlyShow;
  late ScrollController scrollController;

  FormCotizationCubit get blocProvider => BlocProvider.of(context);
  SnackbarBloc get snackbarBloc => BlocProvider.of(context);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedColor = ColorPalete.primary;
    blocProvider.updateColor(selectedColor.value);
    textColor = ColorPalete.white;
    onlyShow = widget.onlyShow;
    if (widget.cotization is Cotization) {
      selectedColor = Color(widget.cotization!.color);
      textColor = BgFgColorUtility.getFgForBg(widget.cotization!.color);
      blocProvider.loadCotization(widget.cotization!, widget.onCopy);
    }
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return BlocListener<FormCotizationCubit, FormCotizationState>(
        listener: (context, state) {
          if (state is FormOnSaveCotizationSuccess) {
            Navigator.of(context).pop(state.cotization);
          }
          if (state is FormOnSaveCotizationFailed) {
            snackbarBloc.add(ErrorSnackbarEvent(state.message));
          }
          if (state is FormOnSaveCotizationLoading) {
            _dialogFinish();
          }

          if (state is OnAddNewItem) {
            _dialogFormItem();
          }
          if (state is FormOnEditItem) {
            _dialogFormItem(state);
          }
          if (state is ActionItemFailed) {
            snackbarBloc.add(WarningSnackbarEvent(state.message));
          }
        },
        child: Scaffold(
          backgroundColor: ColorPalete.white,
          body: _buildBody(orientation),
          floatingActionButtonLocation: _floatingButtonLocation(orientation),
          floatingActionButton: _buildFloatingButton(),
          resizeToAvoidBottomInset: false,
        ));
  }

  Widget? _buildFloatingButton() {
    if (!onlyShow) {
      return FloatingActionButton.extended(
        backgroundColor: selectedColor,
        label: Text(
          "Nuevo Item",
          style: TextStyle(
            color: textColor,
          ),
        ),
        icon: Icon(
          Icons.add,
          color: textColor,
        ),
        onPressed: blocProvider.onAddNewItem,
      );
    }
    if (onlyShow &&
        widget.cotization is Cotization &&
        !widget.cotization!.finished) {
      return FloatingActionButton.extended(
        backgroundColor: selectedColor,
        label: Text(
          "Editar",
          style: TextStyle(
            color: textColor,
          ),
        ),
        icon: Icon(
          Icons.edit,
          color: textColor,
        ),
        onPressed: () => setState(() {
          onlyShow = false;
          scrollController.animateTo(MediaQuery.of(context).size.height - 300,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeIn);
        }),
      );
    }
    return null;
  }

  FloatingActionButtonLocation _floatingButtonLocation(
      Orientation orientation) {
    if (orientation == Orientation.landscape) {
      return FloatingActionButtonLocation.endFloat;
    }

    if (onlyShow) {
      return FloatingActionButtonLocation.endFloat;
    }

    return FloatingActionButtonLocation.centerFloat;
  }

  Widget _buildBody(Orientation orientation) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    return SizedBox(
      height: size.height,
      width: width,
      child: LayoutBuilder(builder: (context, constrains) {
        var slivers = <Widget>[
          SliverPersistentHeader(
            delegate: CotizationHeadDelegate(
              constrains.maxHeight,
              onlyShow,
              selectedColor,
              textColor,
              widget.cotization,
            ),
            pinned: true,
          ),
        ];

        if (!onlyShow) {
          slivers.addAll([
            SliverToBoxAdapter(child: _taxSwitch()),
            SliverToBoxAdapter(child: _accountSwitch()),
            SliverToBoxAdapter(child: _title("SELECCIONE UN COLOR")),
            SliverToBoxAdapter(child: _colorPicker(width, 100)),
          ]);
        }

        slivers.addAll([
          SliverToBoxAdapter(child: _title("ITEMS")),
          _items(),
        ]);

        scrollController = ScrollController(
            initialScrollOffset: onlyShow ? 0 : constrains.maxHeight * 0.6);
        return CustomScrollView(
          controller: scrollController,
          slivers: slivers,
        );
      }),
    );
  }

  Row _accountSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _title("CUENTA DE COBRO"),
        StreamBuilder<bool>(
          stream: blocProvider.isAccountStream,
          builder: (context, snapshot) {
            return Switch(
              activeTrackColor: selectedColor.withOpacity(0.6),
              activeColor: selectedColor,
              value: snapshot.data ?? false,
              onChanged: (value) {
                blocProvider.updateIsAccount(value);
              },
            );
          },
        ),
      ],
    );
  }

  Row _taxSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _title("CARGAR IMPUESTOS (IVA)"),
        StreamBuilder<double?>(
            stream: blocProvider.taxStream,
            builder: (context, snapshot) {
              return Switch(
                activeTrackColor: selectedColor.withOpacity(0.6),
                activeColor: selectedColor,
                value: snapshot.data != null,
                onChanged: (value) {
                  if (value) {
                    blocProvider
                        .updateTax(AppSetup.getTaxPercentOption()?.percent);
                  } else {
                    blocProvider.updateTax(null);
                  }
                },
              );
            }),
      ],
    );
  }

  Future<void> _dialogFinish() async {
    bool? res = await showDialog(
      context: context,
      builder: ((context) {
        return FinishDialog(
          title: "Desea entregar la cotization de inmediato?",
          selectedColor: selectedColor,
        );
      }),
    );

    if (res is bool) {
      blocProvider.save(res);
    } else {
      blocProvider.resetState();
    }
  }

  Future<void> _dialogFormItem([FormOnEditItem? state]) async {
    Map<String, CotizationItem?>? items = await showDialog(
        context: context,
        builder: (context) {
          return FormCotizationItemDialog(
            state?.item,
            background: selectedColor,
            foreground: textColor,
            onCopy: state?.copy,
          );
        });

    FocusManager.instance.primaryFocus?.unfocus();

    var item = items?["newItem"];
    var oldItem = items?["oldItem"];
    if (item is CotizationItem && oldItem is CotizationItem) {
      blocProvider.updateItem(oldItem, item);
    } else if (item is CotizationItem && oldItem == null) {
      blocProvider.addItem(item);
      _scrollTop();
    } else {
      blocProvider.resetState();
      snackbarBloc.add(const WarningSnackbarEvent("No se guardo nada"));
    }
  }

  void _scrollTop() {
    DelayUtility.delay().then((value) => scrollController.animateTo(
          MediaQuery.of(context).size.height,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        ));
  }

  Padding _title(String title) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ));
  }

  Widget _items() {
    return StreamBuilder<List<CotizationItem>>(
        stream: blocProvider.itemsStream,
        builder: ((context, snapshot) {
          var items = <CotizationItem>[];
          if (snapshot.hasData) {
            items = snapshot.data!;
            if (items.isNotEmpty) {
              var children = items
                  .map((e) => CardItemCotization(
                        e,
                        bloc: blocProvider,
                        activeActions: !onlyShow,
                        key: UniqueKey(),
                      ))
                  .toList();
              return SliverList(
                delegate: SliverChildListDelegate(children),
              );
            }
          }

          return const SliverToBoxAdapter(
            child: MessageInfo(
              "No hay items",
              enableIcon: false,
            ),
          );
        }));
  }

  Widget _colorPicker(double width, double height) {
    var crossAxisCount = (height / 150).ceil();
    return SizedBox(
      height: height,
      width: width,
      child: ColorPicker(
        crossAxisCount: crossAxisCount,
        onChange: ((bgColor, fgColor) {
          setState(() {
            selectedColor = bgColor;
            textColor = fgColor;
            blocProvider.updateColor(bgColor.value);
          });
        }),
      ),
    );
  }
}
