import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/styled/loading_indicator.dart';
import 'package:cotizacion_dm/ui/transitions/custom_transtion.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnimatedCotizationList extends StatefulWidget {
  const AnimatedCotizationList({super.key});

  @override
  State<AnimatedCotizationList> createState() => _AnimatedCotizationListState();
}

class _AnimatedCotizationListState extends State<AnimatedCotizationList> {
  FetchCotizationCubit get bloc => BlocProvider.of(context);
  @override
  void initState() {
    super.initState();
    bloc.fetchCotizations();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return RefreshIndicator(
        onRefresh: bloc.reloadCotization,
        child: Stack(
          children: [
            Positioned.fill(
              top: constraints.maxHeight * 0.1,
              child: BlocConsumer<FetchCotizationCubit, FetchCotizationState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is OnFetchCotizationSuccess) {
                    var list = state.cotizations
                        .map(
                          (e) => Hero(
                            tag: "cotization-${e.id}",
                            child: AnimatedCardCotization(e),
                          ),
                        )
                        .toList();
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          height: constraints.maxHeight * 0.5,
                          left: 0,
                          right: 0,
                          bottom: -constraints.maxHeight * 0.2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ColorPalete.black.withOpacity(0.5),
                                  blurRadius: 90,
                                  spreadRadius: 50,
                                  offset: Offset.zero,
                                ),
                              ],
                            ),
                          ),
                        ),
                        PerspectiveListView(
                          onTapFrontItem: (value) {
                            Navigator.of(context)
                                .push(fadeTransition(DetailsCotizationPage(
                                    state.cotizations[value!])))
                                .then(
                              (value) {
                                if (value is DetailsAction &&
                                    value.action == DetailsActionType.trash) {
                                  bloc.deleteCotization(value.cotization);
                                }
                                if (value is DetailsAction &&
                                    value.action == DetailsActionType.restore) {
                                  bloc.restoreCotization(value.cotization);
                                }
                                if (value is DetailsAction &&
                                    value.action == DetailsActionType.delete) {
                                  bloc.forceDeleteCotization(value.cotization);
                                } else {
                                  bloc.resetState();
                                }
                              },
                            );
                          },
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          itemExtent: constraints.maxHeight * 0.4,
                          initialIndex: state.cotizations.length - 1,
                          visualizedItems: 8,
                          children: list,
                        ),
                      ],
                    );
                  }
                  if (state is OnFetchCotizationEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.faceSadTear,
                          size: 100.0,
                          color: Colors.grey.shade400,
                        ),
                        Text("No hay cotizaciones",
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.grey.shade400,
                            )),
                      ],
                    );
                  }
                  return const Center(child: LoadingIndicator());
                },
              ),
            ),
            const _FilterMenuWidget(),
          ],
        ),
      );
    });
  }
}

class _FilterMenuWidget extends StatefulWidget {
  const _FilterMenuWidget();

  @override
  State<_FilterMenuWidget> createState() => _FilterMenuWidgetState();
}

class _FilterMenuWidgetState extends State<_FilterMenuWidget> {
  var _isExpanded = false;

  FetchCotizationCubit get bloc => BlocProvider.of(context);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var minHeight = constraints.maxHeight * 0.1;
      var maxHeight = constraints.maxHeight * 0.55;
      return Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInQuad,
                  transform: Matrix4.identity()
                    ..translate(0.0, _isExpanded ? 0.0 : -maxHeight),
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: ColorPalete.white,
                    boxShadow: [
                      if (_isExpanded)
                        BoxShadow(
                          color: ColorPalete.black.withOpacity(0.5),
                          blurRadius: 90,
                          spreadRadius: 50,
                          offset: Offset.zero,
                        ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 20.0, top: minHeight, bottom: 20.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "ORDERNAR POR:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: constraints.maxWidth,
                            child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                runSpacing: 10.0,
                                children: bloc.orderingOptions
                                    .where((element) => element.isOrdering)
                                    .map((e) {
                                  var index = bloc.orderingOptions.indexOf(e);

                                  return StreamBuilder(
                                    stream: bloc.orderingOptionStreams[index],
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      return TagFilter(
                                        text: e.title,
                                        icon: e.icon,
                                        onTap: () {
                                          e.onTap(index, !snapshot.data!);
                                          _toggleExpand();
                                        },
                                        selected: snapshot.data ?? false,
                                      );
                                    },
                                  );
                                }).toList()),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, top: 10.0),
                            child: Text(
                              "FILTRAR POR:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: constraints.maxWidth,
                            child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                runSpacing: 10.0,
                                children: bloc.orderingOptions
                                    .where((element) => !element.isOrdering)
                                    .map((e) {
                                  var index = bloc.orderingOptions.indexOf(e);

                                  return StreamBuilder(
                                    stream: bloc.orderingOptionStreams[index],
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      return TagFilter(
                                        text: e.title,
                                        icon: e.icon,
                                        onTap: () {
                                          e.onTap(index, !snapshot.data!);
                                        },
                                        selected: snapshot.data ?? false,
                                      );
                                    },
                                  );
                                }).toList()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: ColorPalete.white,
                  height: minHeight,
                  child: GestureDetector(
                    onTap: () {
                      _toggleExpand();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 1000),
                              tween: _isExpanded
                                  ? Tween(begin: 0.0, end: 1.0)
                                  : Tween(begin: 1.0, end: 0.0),
                              builder: (context, value, _) {
                                if (_isExpanded) {
                                  return Opacity(
                                    opacity: value,
                                    child: Icon(
                                      FontAwesomeIcons.chevronUp,
                                      color: Colors.grey.shade800,
                                    ),
                                  );
                                }
                                return Opacity(
                                  opacity: 1 - value,
                                  child: Icon(
                                    FontAwesomeIcons.chevronDown,
                                    color: Colors.grey.shade800,
                                  ),
                                );
                              }),
                          Text(
                            "FILTROS DE BUSQUEDA",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
}

class TagFilter extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  const TagFilter({
    Key? key,
    required this.text,
    required this.icon,
    required this.onTap,
    required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var background = selected ? ColorPalete.secondary : Colors.grey.shade300;
    var foreground = selected ? ColorPalete.primary : Colors.grey.shade700;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: foreground),
              const SizedBox(width: 10),
              Text(text, style: TextStyle(fontSize: 16, color: foreground)),
            ]),
      ),
    );
  }
}
