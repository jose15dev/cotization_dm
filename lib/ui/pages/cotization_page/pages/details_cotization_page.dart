import 'dart:ui';
import 'dart:math' as math;

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/globals.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailsCotizationPage extends StatefulWidget {
  final Cotization cotization;
  const DetailsCotizationPage(this.cotization, {super.key});

  @override
  State<DetailsCotizationPage> createState() => _DetailsCotizationPageState();
}

class _DetailsCotizationPageState extends State<DetailsCotizationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateCardAnimation;
  late Animation<double> _moveCardAnimation;

  // info
  late Cotization _cotization;
  bool _isUpdated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _rotateCardAnimation = CurveTween(
      curve: const Interval(0.1, 0.5, curve: Curves.easeInOut),
    ).animate(_controller);
    _moveCardAnimation = CurveTween(
      curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
    ).animate(_controller);

    _cotization = widget.cotization;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  FetchCotizationCubit get bloc => BlocProvider.of(context);
  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchCotizationCubit, FetchCotizationState>(
      listener: (context, state) {
        if (state is OnActionCotizationSuccess) {
          if (state.cotization is Cotization) {
            setState(() {
              _cotization = state.cotization!;
              _isUpdated = true;
            });
            DelayUtility.custom(1).then((value) => setState(() {
                  _isUpdated = false;
                }));
          }
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverAppBar(
                            pinned: true,
                            backgroundColor: ColorPalete.white,
                            actions: [
                              IconButton(
                                onPressed: () {
                                  _controller
                                    ..reset()
                                    ..forward().then((value) {
                                      Navigator.of(context).pop(_cotization);
                                    });
                                },
                                icon: const Icon(
                                  FontAwesomeIcons.trash,
                                ),
                              )
                            ],
                          ),
                          SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                "Detalles",
                                style: TextStyle(
                                  fontFamily: fontFamily,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _CustomDelegate(
                              minHeight:
                                  MediaQuery.of(context).size.height * 0.35,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.35,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: Hero(
                                    tag: "cotization-${_cotization.id}",
                                    child: Opacity(
                                      opacity: 1 - _moveCardAnimation.value,
                                      child: _TransformCard(
                                        movement: _moveCardAnimation.value,
                                        rotation: _rotateCardAnimation.value,
                                        child: AnimatedCardCotization(
                                          _cotization,
                                          isUpdated: _isUpdated,
                                          isDetail: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, bottom: 10.0),
                              child: Text(
                                'Servicios',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                          SliverList(
                              delegate:
                                  SliverChildBuilderDelegate(((context, index) {
                            var item = _cotization.items[index];
                            return _CotizationItemWidget(item: item);
                          }), childCount: _cotization.items.length)),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),
        bottomNavigationBar: _CotizationActions(
          cotization: _cotization,
        ),
      ),
    );
  }
}

class _CotizationItemWidget extends StatelessWidget {
  const _CotizationItemWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  final CotizationItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        FontAwesomeIcons.circleInfo,
        size: 40,
      ),
      title: Column(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Cantidad: '),
              Text("${item.amount} ${item.unit}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Precio: '),
              Text(CurrencyUtility.doubleToCurrency(item.unitValue)),
            ],
          ),
        ],
      ),
      trailing: Text(
        CurrencyUtility.doubleToCurrency(item.total),
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CustomDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final double minHeight;

  _CustomDelegate(
      {required this.child, required this.maxHeight, required this.minHeight});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return child;
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => maxHeight;

  @override
  // TODO: implement minExtent
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return true;
  }
}

class _TransformCard extends StatelessWidget {
  final Widget child;
  final double movement, rotation;
  const _TransformCard(
      {required this.child, required this.movement, required this.rotation});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translate(100.0 * movement, -300.0 * math.pow(movement, 2))
        ..rotateX(-math.pi / 6 * rotation)
        ..rotateZ(math.pi / 4 * movement)
        ..scale(lerpDouble(1, 0.3, movement)!),
      child: child,
    );
  }
}

class _CotizationActions extends StatefulWidget {
  final Cotization cotization;
  const _CotizationActions({
    Key? key,
    required this.cotization,
  }) : super(key: key);

  @override
  State<_CotizationActions> createState() => _CotizationActionsState();
}

class _CotizationActionsState extends State<_CotizationActions>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )
      ..forward()
      ..addListener(() {
        if (_backgroundController.isCompleted) {
          _backgroundController.repeat();
        }
      });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  FetchCotizationCubit get bloc => BlocProvider.of(context);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, _) {
          return Container(
            height: kBottomNavigationBarHeight * 1.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                transform:
                    GradientRotation(2 * math.pi * _backgroundController.value),
                colors: [
                  ColorPalete.primary,
                  ColorPalete.secondary,
                ],
              ),
            ),
            child: Row(children: [
              Expanded(
                child: _CotizationAction(
                  onTap: () {
                    bloc.exportToPDF(widget.cotization, getIt());
                  },
                  icon: FontAwesomeIcons.fileExport,
                  label: "Exportar a PDF",
                ),
              ),
              if (!widget.cotization.finished)
                Expanded(
                  child: _CotizationAction(
                    onTap: () {
                      bloc.onEditCotization(widget.cotization);
                    },
                    icon: FontAwesomeIcons.pencil,
                    label: "Editar",
                  ),
                ),
              if (!widget.cotization.finished)
                Expanded(
                  child: _CotizationAction(
                    onTap: () {
                      bloc.onFinishCotization(widget.cotization);
                    },
                    icon: FontAwesomeIcons.truck,
                    label: "Entregar",
                  ),
                ),
              Expanded(
                child: _CotizationAction(
                  onTap: () {
                    bloc.onEditCotization(widget.cotization, true);
                  },
                  icon: FontAwesomeIcons.solidCopy,
                  label: "Duplicar",
                ),
              ),
            ]),
          );
        });
  }
}

class _CotizationAction extends StatelessWidget {
  const _CotizationAction({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: ColorPalete.white,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: ColorPalete.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
