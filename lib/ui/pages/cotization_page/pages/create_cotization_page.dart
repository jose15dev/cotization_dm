import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/bloc/bloc.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Cotization? lastValue;

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

class _CreateCotizationViewState extends State<CreateCotizationView>
    with SingleTickerProviderStateMixin {
  late Color selectedColor;
  late Color textColor;
  late bool onlyShow;
  late ScrollController scrollController;
  late TabController _tabController;
  late TextEditingController _nameController, _descriptionController;

  var _enableFloatingButton = false;

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
      _nameController = TextEditingController(text: widget.cotization!.name);
      _descriptionController =
          TextEditingController(text: widget.cotization!.description);
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
    }

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _enableFloatingButton = _tabController.index == 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var floatingButtonKey = GlobalKey();

    return BlocListener<FormCotizationCubit, FormCotizationState>(
        listener: (context, state) {
          if (state is FormOnSaveCotizationSuccess) {
            Navigator.of(context).pop(state.cotization);
          }
          if (state is FormOnSaveCotizationFailed) {
            snackbarBloc.add(ErrorSnackbarEvent(state.message));
          }

          if (state is FormOnEditItem) {
            _dialogFormItem(state.position, state);
          }
          if (state is ActionItemFailed) {
            snackbarBloc.add(WarningSnackbarEvent(state.message));
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: !_enableFloatingButton,
          backgroundColor: ColorPalete.white,
          body: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              var keyboardIsOpen =
                  WidgetsBinding.instance.window.viewInsets.bottom > 0.0;
              var sizeMaxHeight =
                  constraints.maxHeight * (keyboardIsOpen ? 0.6 : 0.4);
              var color = ColorPalete.white;

              return NestedScrollView(
                physics: const BouncingScrollPhysics(),
                body: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        LayoutBuilder(builder: (context, constraints) {
                          return ColorPicker(
                            width: constraints.maxWidth - 20,
                            initialColor: selectedColor,
                            onChange: ((p0, p1) {
                              setState(() {
                                selectedColor = p0;
                                textColor = p1;
                              });
                              blocProvider.updateColor(p0.value);
                            }),
                          );
                        }),
                        const SizedBox(height: 20),
                        CustomTextfield(
                          align: TextAlign.left,
                          stream: blocProvider.nameStream,
                          controller: _nameController,
                          filled: true,
                          enableError: true,
                          onChanged: (p0) => blocProvider.updateName(p0),
                          label: "Nombre del cliente",
                          foreground: Colors.grey.shade800,
                          fontSize: 20,
                        ),
                        CustomTextfield(
                          maxLines: 3,
                          stream: blocProvider.descStream,
                          controller: _descriptionController,
                          align: TextAlign.left,
                          filled: true,
                          enableError: true,
                          onChanged: (p0) => blocProvider.updateDescription(p0),
                          label: "Descripción de la cotización",
                          foreground: Colors.grey.shade800,
                          fontSize: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _title("CARGAR IMPUESTOS (IVA)"),
                            StreamBuilder<double?>(
                                stream: blocProvider.taxStream,
                                builder: (context, snapshot) {
                                  return Switch(
                                    activeTrackColor:
                                        selectedColor.withOpacity(0.6),
                                    activeColor: selectedColor,
                                    value: snapshot.data != null,
                                    onChanged: (value) {
                                      if (value) {
                                        blocProvider.updateTax(
                                            AppSetup.getTaxPercentOption()
                                                ?.percent);
                                      } else {
                                        blocProvider.updateTax(null);
                                      }
                                    },
                                  );
                                }),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _title("CUENTA DE COBRO"),
                            StreamBuilder<bool>(
                                stream: blocProvider.isAccountStream,
                                initialData: false,
                                builder: (context, snapshot) {
                                  return Switch(
                                    activeTrackColor:
                                        selectedColor.withOpacity(0.6),
                                    activeColor: selectedColor,
                                    value: snapshot.data!,
                                    onChanged: (value) {
                                      blocProvider.updateIsAccount(value);
                                    },
                                  );
                                }),
                          ],
                        ),
                      ],
                    ),
                    StreamBuilder<List<CotizationItem>>(
                        stream: blocProvider.itemsStream,
                        initialData: const [],
                        builder: (context, snapshot) {
                          if (snapshot.data!.isEmpty) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FontAwesomeIcons.fileInvoiceDollar,
                                    size: 100, color: Colors.grey.shade300),
                                const SizedBox(height: 10),
                                Text(
                                  "No hay servicios agregados",
                                  style: TextStyle(
                                    color: Colors.grey.shade300,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            );
                          }
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) => CardItemCotization(
                              snapshot.data![index],
                              bloc: blocProvider,
                              color: selectedColor,
                              activeActions: true,
                              key: Key(snapshot.data![index].id.toString()),
                            ),
                          );
                        }),
                  ],
                ),
                headerSliverBuilder: ((context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      backgroundColor: color,
                      pinned: true,
                      actions: [
                        StreamBuilder<bool>(
                            stream: blocProvider.validateForm,
                            initialData: false,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      blocProvider.save();
                                    },
                                    child: const Icon(
                                        FontAwesomeIcons.solidFloppyDisk),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            })
                      ],
                    ),
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: color,
                      collapsedHeight: sizeMaxHeight,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          padding: const EdgeInsets.all(20.0),
                          child: StreamBuilder<Cotization>(
                              stream:
                                  BlocProvider.of<FormCotizationCubit>(context)
                                      .cotizationStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  lastValue = snapshot.data;
                                }
                                if (lastValue is Cotization) {
                                  return NormalCotizationHero(
                                    id: lastValue!.id,
                                    child: AnimatedCardCotization(
                                      lastValue!,
                                      isDetail: true,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                        ),
                      ),
                    ),
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: color,
                      toolbarHeight: 20.0,
                      bottom: TabBar(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        controller: _tabController,
                        tabs: const [
                          Tab(
                            text: "Datos Generales",
                          ),
                          Tab(
                            text: "Servicios",
                          ),
                        ],
                        labelColor: Colors.grey.shade700,
                        indicator: DotPlaneIndicator(Colors.grey.shade700),
                        labelStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )
                  ];
                }),
              );
            }),
          ),
          floatingActionButton: _enableFloatingButton
              ? FloatingActionButton.extended(
                  key: floatingButtonKey,
                  backgroundColor: selectedColor,
                  foregroundColor: textColor,
                  onPressed: () {
                    var box = floatingButtonKey.currentContext!
                        .findRenderObject() as RenderBox;
                    Offset position = box.localToGlobal(Offset.zero);
                    _dialogFormItem(position);
                  },
                  label: const Text("Agregar Servicio"),
                  icon: const Icon(FontAwesomeIcons.plus),
                )
              : null,
        ));
  }

  Future<void> _dialogFormItem(Offset position, [FormOnEditItem? state]) async {
    Map<String, CotizationItem?>? items = await dialogScale(
        context,
        position,
        FormCotizationItemDialog(
          state?.item,
          background: selectedColor,
          foreground: textColor,
          onCopy: state?.copy,
        ));

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
}
