import 'dart:ui';
import 'dart:math' as math;

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/styled/styled.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void liquidationDialog(BuildContext context, TapDownDetails details) {
  dialogScale<Liquidation?>(
    context,
    details.globalPosition,
    BlocProvider(
      create: (context) => CreateLiquidationCubit(),
      child: const CreateLiquidationDialog(),
    ),
  ).then((value) {
    if (value is Liquidation) {
      final liquidationBloc = BlocProvider.of<FetchLiquidationsCubit>(context);
      liquidationBloc.saveLiquidation(value);
    }
  });
}

class CreateLiquidationDialog extends StatefulWidget {
  const CreateLiquidationDialog({super.key});

  @override
  State<CreateLiquidationDialog> createState() =>
      _CreateLiquidationDialogState();
}

class _CreateLiquidationDialogState extends State<CreateLiquidationDialog> {
  FetchEmployeeCubit get employeeBloc => BlocProvider.of(context);
  CreateLiquidationCubit get liquidationBloc =>
      BlocProvider.of<CreateLiquidationCubit>(context);

  Employee? _selectedEmployee;
  final _controller = PageController(
    initialPage: 0,
  );

  final _duration = const Duration(milliseconds: 500);
  bool _isLastPage = false;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.page == 1) {
        setState(() {
          _isLastPage = true;
        });
      }
      if (_controller.page == 0) {
        setState(() {
          _isLastPage = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width * 0.8,
      height: size.height * 0.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size.width * 0.05),
        child: Material(
          color: ColorPalete.white,
          child: BlocListener<CreateLiquidationCubit, CreateLiquidationState>(
            listener: (context, state) {
              if (state is CreateLiquidationOnEmployeeSelected) {
                _goNextPage();
              }
              if (state is CreateLiquidationOnSend) {
                Navigator.of(context).pop(state.liquidation);
              }
            },
            child: Stack(
              children: [
                Positioned.fill(
                  top: size.height * .14,
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _controller,
                    children: [
                      // Select Employee
                      BlocBuilder<FetchEmployeeCubit, FetchEmployeeState>(
                        builder: (context, state) {
                          if (state is OnFetchEmployeeSuccess) {
                            return RefreshIndicator(
                              onRefresh: () => employeeBloc.fetchEmployees(),
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: state.employees.length,
                                itemBuilder: ((context, index) {
                                  return EmployeeListTile(
                                    active: _selectedEmployee ==
                                        state.employees[index],
                                    employee: state.employees[index],
                                    onTap: () {
                                      setState(() {
                                        _selectedEmployee =
                                            state.employees[index];
                                      });
                                    },
                                  );
                                }),
                              ),
                            );
                          }
                          return const Center(
                            child: LoadingIndicator(),
                          );
                        },
                      ),
                      // Select Period
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dias de trabajo",
                              style: TextStyle(
                                color: ColorPalete.primary,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    liquidationBloc.decreaseDay();
                                  },
                                  child: Icon(
                                    FontAwesomeIcons.circleMinus,
                                    color: ColorPalete.primary,
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: CustomTextfield(
                                    stream: liquidationBloc.day.map((event) {
                                      return event.toString();
                                    }),
                                    filled: true,
                                    readOnly: true,
                                    formatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    type: TextInputType.number,
                                    enableError: true,
                                    onChanged: (value) {
                                      liquidationBloc.updateDay(value);
                                    },
                                    label: "",
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                GestureDetector(
                                  onTap: () {
                                    liquidationBloc.increaseDay();
                                  },
                                  child: Icon(FontAwesomeIcons.circlePlus,
                                      color: ColorPalete.primary),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Total a pagar",
                              style: TextStyle(
                                color: ColorPalete.primary,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextfield(
                              label: "",
                              filled: true,
                              readOnly: true,
                              stream: liquidationBloc.realPrice.map((event) {
                                return CurrencyUtility.doubleToCurrency(event);
                              }),
                              formatters: [
                                CurrencyTextInputFormatter(
                                  symbol: "\$",
                                  decimalDigits: 0,
                                ),
                              ],
                              type: TextInputType.number,
                              enableError: true,
                              onChanged: (value) {
                                liquidationBloc.updateRealPrice(value);
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // Tab Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: size.height * .14,
                  child: ClipPath(
                    clipper: const _TopBarClipper(),
                    child: Container(
                      color: ColorPalete.secondary,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                      ),
                      child: AnimatedSwitcher(
                        switchInCurve: Curves.easeInCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        duration: _duration,
                        child: _isLastPage
                            ? Padding(
                                key: UniqueKey(),
                                padding:
                                    EdgeInsets.only(bottom: size.height * 0.04),
                                child: Text(
                                  "Liquidación de ${_selectedEmployee!.firstname}",
                                  style: TextStyle(
                                    color: ColorPalete.primary,
                                    fontSize: size.width * 0.05,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Padding(
                                key: UniqueKey(),
                                padding:
                                    EdgeInsets.only(bottom: size.height * 0.04),
                                child: Text(
                                  "Seleccione el empleado a liquidar",
                                  style: TextStyle(
                                    color: ColorPalete.primary,
                                    fontSize: size.width * 0.05,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                // Floating Action Button
                StreamBuilder(
                  stream: liquidationBloc.enableButton,
                  builder: (BuildContext context, snapshot) {
                    return TweenAnimationBuilder<double>(
                      tween: snapshot.hasData
                          ? snapshot.data! && _isLastPage
                              ? Tween(begin: 0.0, end: 1.0)
                              : Tween(begin: 1.0, end: 0.0)
                          : Tween(begin: 0.0, end: 0.0),
                      duration: _duration,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Align(
                          alignment: const FractionalOffset(0.95, 0.95),
                          child: FloatingActionButton(
                            onPressed: () {
                              liquidationBloc.sendLiquidation();
                            },
                            child: const Icon(
                              FontAwesomeIcons.check,
                            ),
                          )),
                    );
                  },
                ),
                if (_selectedEmployee != null)
                  LayoutBuilder(builder: (context, constraints) {
                    return TweenAnimationBuilder<double>(
                      tween: _isLastPage
                          ? Tween(begin: 0.0, end: 1.0)
                          : Tween(begin: 1.0, end: 0.0),
                      duration: _duration,
                      builder: (context, value, child) {
                        return Align(
                          alignment: FractionalOffset(
                              lerpDouble(0.05, 0.95, 1 - value)!, 0.95),
                          child: FloatingActionButton(
                            onPressed: () {
                              if (_isLastPage) {
                                _goBackPage();
                              } else {
                                liquidationBloc
                                    .selectEmployee(_selectedEmployee!);
                              }
                            },
                            child: Transform.rotate(
                              angle: -value * math.pi,
                              child: const Icon(
                                FontAwesomeIcons.arrowRight,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goNextPage() {
    _controller.animateToPage(
      1,
      duration: _duration,
      curve: Curves.easeIn,
    );
    liquidationBloc.resetState();
  }

  void _goBackPage() {
    _controller.animateToPage(
      0,
      duration: _duration,
      curve: Curves.easeIn,
    );
  }
}

class _TopBarClipper extends CustomClipper<Path> {
  const _TopBarClipper();
  @override
  Path getClip(Size size) {
    var w = size.width;
    var h = size.height;
    var path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * .5)
      ..quadraticBezierTo(
        w * .5,
        h,
        0,
        h * .5,
      )
      ..lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
