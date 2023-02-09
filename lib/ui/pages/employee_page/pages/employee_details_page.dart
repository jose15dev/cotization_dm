import 'dart:ui';

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/globals.dart';
import 'package:cotizacion_dm/ui/animations/animations.dart';
import 'package:cotizacion_dm/ui/bloc/snackbar/snackbar_bloc.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/employee_page/utilities/utilities.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/transitions/custom_transtion.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

final trashKey = GlobalKey();
final cardkey = GlobalKey();

class EmployeeDetailsPage extends StatefulWidget {
  final Employee employee;
  final List<Color> colors;
  const EmployeeDetailsPage(this.employee, {super.key, required this.colors});

  @override
  State<EmployeeDetailsPage> createState() => _EmployeeDetailsPageState();
}

class _EmployeeDetailsPageState extends State<EmployeeDetailsPage> {
  late Employee _employee;
  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
  }

  @override
  Widget build(BuildContext context) {
    SnackbarBloc snackbarBloc = BlocProvider.of(context);
    LiquidationService liquidationService = getIt();
    return BlocProvider(
      create: (context) => EmployeeDetailsCubit(_employee, liquidationService),
      child: MultiBlocListener(
        listeners: [
          BlocListener<EmployeeDetailsCubit, EmployeeDetailsState>(
            listener: (context, state) {
              if (state is OnActionFailed) {
                snackbarBloc.add(WarningSnackbarEvent(state.message));
              }
            },
          ),
          BlocListener<FetchEmployeeCubit, FetchEmployeeState>(
            listener: (context, state) {
              if (state is OnUpdateEmployeeSuccess) {
                setState(() {
                  _employee = state.employee;
                });
              }
            },
          ),
        ],
        child: _EmployeeDetailsView(_employee, colors: widget.colors),
      ),
    );
  }
}

class _EmployeeDetailsView extends StatefulWidget {
  final Employee employee;
  final List<Color> colors;
  const _EmployeeDetailsView(
    this.employee, {
    Key? key,
    this.colors = const [Colors.blue, Colors.blueAccent],
  }) : super(key: key);

  @override
  State<_EmployeeDetailsView> createState() => _EmployeeDetailsViewState();
}

class _EmployeeDetailsViewState extends State<_EmployeeDetailsView>
    with TickerProviderStateMixin {
  late Employee employee;
  EmployeeDetailsCubit get bloc => BlocProvider.of(context);
  FetchEmployeeCubit get fetchBloc => BlocProvider.of(context);

  // animation
  late AnimationController _animationController;
  late Animation _animation, _colorAnimation, _colorBackAnimation;

  @override
  void initState() {
    super.initState();
    employee = widget.employee;
    bloc.getLiquidations();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
        if (_animationController.isCompleted) {
          _animationController.reset();
          Navigator.of(context).pop(widget.employee);
        }
      });

    _animation = CurveTween(curve: const SineCurve(count: 6))
        .animate(_animationController);
    _colorAnimation =
        CurveTween(curve: const Interval(0.0, 0.5, curve: Curves.easeIn))
            .animate(_animationController);
    _colorBackAnimation =
        CurveTween(curve: const Interval(0.5, 1.0, curve: Curves.easeIn))
            .animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeeDetailsCubit, EmployeeDetailsState>(
      listener: ((context, state) {
        if (state is OnDeleteAnimationTrash) {
          _animationController
            ..reset()
            ..forward();
        }
      }),
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: ColorPalete.white,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    key: trashKey,
                    onTap: () {
                      bloc.onDeleteAnimation();
                    },
                    child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, _) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateZ(math.pi / 6 * _animation.value),
                            child: Icon(FontAwesomeIcons.trash,
                                color: Color.lerp(
                                    Colors.black,
                                    Colors.red,
                                    _colorAnimation.value +
                                        _colorBackAnimation.value)),
                          );
                        }),
                  ),
                )
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  "Información",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _CustomDelegate(
                employee: employee,
                colors: widget.colors,
                maxHeight: MediaQuery.of(context).size.height * 0.5,
                minHeight: MediaQuery.of(context).size.height * 0.3,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
                child: Text(
                  "LIQUIDACIONES",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            StreamBuilder<List<Liquidation>>(
                stream: bloc.liquidations,
                initialData: const [],
                builder: (context, snapshot) {
                  return SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _LiquidationItem(
                        liquidation: snapshot.data![index],
                      );
                    },
                    childCount: snapshot.data!.length,
                  ));
                }),
          ],
        ),
        bottomNavigationBar: GradientBottomBar(
          actions: [
            Expanded(
              child: GradientAction(
                onTap: (details) {
                  // Navigator.of(context)
                  //     .push(fadeTransition(const InitialLiquidationPage()))
                  //     .then((value) {
                  //   bloc.getLiquidations();
                  // });
                },
                icon: FontAwesomeIcons.handHoldingDollar,
                label: "Liquidar",
              ),
            ),
            Expanded(
              child: GradientAction(
                onTap: (details) {
                  bloc.onCall();
                },
                icon: FontAwesomeIcons.phone,
                label: "Llamar",
              ),
            ),
            Expanded(
              child: GradientAction(
                onTap: (details) {
                  bloc.onWhatsappChat();
                },
                icon: FontAwesomeIcons.whatsapp,
                label: "Mensaje",
              ),
            ),
            Expanded(
              child: GradientAction(
                onTap: (details) {
                  dialogEmployeeForm(context, details,
                      employee: employee, colors: widget.colors);
                },
                icon: FontAwesomeIcons.pencil,
                label: "Editar",
              ),
            ),
          ],
          colors: widget.colors,
        ),
      ),
    );
  }
}

class _LiquidationItem extends StatelessWidget {
  final Liquidation liquidation;
  const _LiquidationItem({
    Key? key,
    required this.liquidation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(FontAwesomeIcons.moneyBillTransfer, size: 40.0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${CurrencyUtility.doubleToCurrency(liquidation.realPrice)} COP",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${liquidation.days} días",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            TimeAgoUtility.toTimeAgo(liquidation.createdAt),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight, minHeight;
  final Employee employee;
  final List<Color> colors;

  _CustomDelegate({
    required this.employee,
    required this.maxHeight,
    required this.minHeight,
    required this.colors,
  });
  final _duration = const Duration(milliseconds: 300);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var animate = shrinkOffset > 0;
    return _HeadWidget(
      duration: _duration,
      animate: animate,
      employee: employee,
      colors: colors,
    );
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

class _HeadWidget extends StatefulWidget {
  const _HeadWidget({
    Key? key,
    required Duration duration,
    required this.animate,
    required this.employee,
    required this.colors,
  })  : _duration = duration,
        super(key: key);

  final Duration _duration;
  final bool animate;
  final Employee employee;
  final List<Color> colors;

  @override
  State<_HeadWidget> createState() => _HeadWidgetState();
}

class _HeadWidgetState extends State<_HeadWidget>
    with TickerProviderStateMixin {
  // animations
  late AnimationController _controller;
  late Animation _rotateZCardAnimation;
  late Animation _rotateXCardAnimation;
  late Animation _sendCardAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _rotateZCardAnimation = CurveTween(
        curve: const Interval(
      0.1,
      0.5,
      curve: Curves.decelerate,
    )).animate(_controller);
    _rotateXCardAnimation = CurveTween(
        curve: const Interval(
      0.55,
      0.7,
      curve: Curves.easeIn,
    )).animate(_controller);
    _sendCardAnimation =
        CurveTween(curve: const Interval(0.75, 1.0, curve: Curves.easeOut))
            .animate(_controller);
  }

  EmployeeDetailsCubit get bloc => BlocProvider.of(context);

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeeDetailsCubit, EmployeeDetailsState>(
      listener: (context, state) {
        if (state is OnDeleteAnimationCard) {
          setState(() {
            _controller
              ..reset()
              ..forward().then((value) {
                bloc.animateTrash();
              });
          });
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
        var fontSize = constraints.maxWidth * 0.065;
        return Container(
          color: ColorPalete.white,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    bottom:
                        constraints.maxHeight * (widget.animate ? 0.0 : 0.3),
                    right: constraints.maxWidth * (widget.animate ? 0.5 : 0.0),
                    child: Center(
                      child: Hero(
                        tag: "card-employee-${widget.employee.id}",
                        child: _TransformCard(
                          key: cardkey,
                          rotateX: _rotateXCardAnimation.value,
                          rotateZ: _rotateZCardAnimation.value,
                          translate: _sendCardAnimation.value,
                          child: SizedBox(
                            height: constraints.maxHeight *
                                (widget.animate ? 0.6 : 0.8),
                            width: constraints.maxWidth *
                                (widget.animate ? 0.4 : 0.55),
                            child: AnimatedEmployeeCard(
                              employee: widget.employee,
                              listColors: widget.colors,
                              isDetail: true,
                              isSmall: widget.animate,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: constraints.maxHeight * (widget.animate ? 0.0 : 0.7),
                    left: constraints.maxWidth * (widget.animate ? 0.5 : 0.0),
                    child: Center(
                      child: Hero(
                          tag: "details-employee-${widget.employee.id}",
                          child: EmployeeDetails(
                            fontSize: fontSize,
                            employee: widget.employee,
                            isDetail: true,
                            isSmall: widget.animate,
                          )),
                    ),
                  )
                ],
              );
            },
          ),
        );
      }),
    );
  }
}

class _TransformCard extends StatelessWidget {
  final Widget child;
  final double rotateZ, translate, rotateX;
  const _TransformCard({
    Key? key,
    required this.child,
    required this.rotateZ,
    required this.translate,
    required this.rotateX,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rotationZ = 4 * math.pi * rotateZ;
    var translateRotationZ = math.pi / 4 * translate;
    var translateRotationX = -math.pi / 6 * rotateX;
    var translateScale = 1 - translate;

    return LayoutBuilder(builder: (context, constraints) {
      var distance = getDistance(constraints.maxWidth, constraints.maxHeight);
      var translateX = distance.dx * translate;
      var translateY = distance.dy * translate;

      return Opacity(
        opacity: 1 - translate,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(translateX, translateY)
            ..rotateZ(rotationZ + translateRotationZ)
            ..rotateX(translateRotationX)
            ..scale(translateScale),
          child: child,
        ),
      );
    });
  }

  Offset getDistance(double width, double height) {
    var trashBox = trashKey.currentContext?.findRenderObject() as RenderBox?;
    var trashOffset = trashBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    var cardBox = cardkey.currentContext?.findRenderObject() as RenderBox?;
    var cardOffset = cardBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    var distance = (trashOffset - cardOffset.translate(0, height / 2));
    return distance;
  }
}
