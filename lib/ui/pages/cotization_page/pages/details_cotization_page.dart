import 'dart:ui';
import 'dart:math' as math;

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/globals.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/components/select_menu.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _trashKey = GlobalKey();
final _cardkey = GlobalKey();

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
        body: AnimatedBuilder(
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
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: GestureDetector(
                                key: _trashKey,
                                onTapDown: ((details) {
                                  dialogScale(
                                    context,
                                    details.globalPosition,
                                    SelectMenu(children: [
                                      MenuAction(
                                        icon: FontAwesomeIcons.trash,
                                        text: "Eliminar definitivamente",
                                        onTap: () {
                                          Navigator.of(context).pop(
                                            DetailsAction(
                                              cotization: _cotization,
                                              action: DetailsActionType.delete,
                                            ),
                                          );
                                        },
                                      ),
                                      if (_cotization.deletedAt != null)
                                        MenuAction(
                                          icon: FontAwesomeIcons.trashArrowUp,
                                          text: "Restaurar",
                                          onTap: (() =>
                                              Navigator.of(context).pop(
                                                DetailsAction(
                                                    cotization: _cotization,
                                                    action: DetailsActionType
                                                        .restore),
                                              )),
                                        ),
                                      if (_cotization.deletedAt == null)
                                        MenuAction(
                                          icon: FontAwesomeIcons.boxArchive,
                                          text: "Enviar a la papelera",
                                          onTap: () {
                                            Navigator.of(context).pop(
                                              DetailsAction(
                                                cotization: _cotization,
                                                action: DetailsActionType.trash,
                                              ),
                                            );
                                          },
                                        ),
                                    ]),
                                  ).then((value) {
                                    if (value is DetailsAction &&
                                        value.action ==
                                            DetailsActionType.delete) {
                                      _controller
                                        ..reset()
                                        ..forward().then(
                                          (_) {
                                            Navigator.of(context).pop(value);
                                          },
                                        );
                                    } else {
                                      Navigator.of(context).pop(value);
                                    }
                                  });
                                }),
                                child: Icon(
                                  _cotization.deletedAt == null
                                      ? FontAwesomeIcons.trash
                                      : FontAwesomeIcons.trashArrowUp,
                                ),
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
                                child: Opacity(
                                  opacity: 1 - _moveCardAnimation.value,
                                  child: _TransformCard(
                                    key: _cardkey,
                                    movement: _moveCardAnimation.value,
                                    rotation: _rotateCardAnimation.value,
                                    child: Hero(
                                      tag: "cotization-${_cotization.id}",
                                      child: AnimatedCardCotization(
                                        _cotization,
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
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 10.0),
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
                          return CardItemCotization(
                            item,
                            activeActions: false,
                          );
                        }), childCount: _cotization.items.length)),
                      ],
                    ),
                  ),
                ],
              );
            }),
        bottomNavigationBar: GradientBottomBar(
          actions: [
            Expanded(
              child: GradientAction(
                onTap: (details) {
                  bloc.exportToPDF(_cotization, getIt());
                },
                icon: FontAwesomeIcons.fileExport,
                label: "Exportar a PDF",
              ),
            ),
            if (_cotization.finished == null && _cotization.deletedAt == null)
              Expanded(
                child: GradientAction(
                  onTap: (details) {
                    bloc.onEditCotization(_cotization);
                  },
                  icon: FontAwesomeIcons.pencil,
                  label: "Editar",
                ),
              ),
            if (_cotization.finished == null && _cotization.deletedAt == null)
              Expanded(
                child: GradientAction(
                  onTap: (details) {
                    bloc.onFinishCotization(_cotization);
                  },
                  icon: FontAwesomeIcons.truck,
                  label: "Entregar",
                ),
              ),
            if (_cotization.deletedAt == null)
              Expanded(
                child: GradientAction(
                  onTap: (details) {
                    bloc.onEditCotization(_cotization, true);
                  },
                  icon: FontAwesomeIcons.solidCopy,
                  label: "Duplicar",
                ),
              ),
          ],
          colors: [
            ColorPalete.primary,
            ColorPalete.secondary,
          ],
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
      {super.key,
      required this.child,
      required this.movement,
      required this.rotation});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var distance = getDistance(constraints.maxWidth, constraints.maxHeight);
      var translateX = distance.dx * movement;
      var translateY = distance.dy * movement;

      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..translate(translateX, translateY)
          ..rotateX(-math.pi / 6 * rotation)
          ..rotateZ(math.pi / 4 * movement)
          ..scale(lerpDouble(1, 0.3, movement)!),
        child: child,
      );
    });
  }

  Offset getDistance(double width, double height) {
    var trashBox = _trashKey.currentContext?.findRenderObject() as RenderBox?;
    var trashOffset = trashBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    var cardBox = _cardkey.currentContext?.findRenderObject() as RenderBox?;
    var cardOffset = cardBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    var distance = (trashOffset - cardOffset.translate(0, height / 2));
    return distance;
  }
}
