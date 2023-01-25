import 'dart:ui';

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/liquidation_page/bloc/bloc.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateLiquidationPage extends StatelessWidget {
  const CreateLiquidationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateLiquidationCubit(),
      child: const CreateLiquidationView(),
    );
  }
}

class CreateLiquidationView extends StatefulWidget {
  const CreateLiquidationView({super.key});

  @override
  State<CreateLiquidationView> createState() => _CreateLiquidationViewState();
}

class _CreateLiquidationViewState extends State<CreateLiquidationView> {
  CreateLiquidationCubit get bloc => BlocProvider.of(context);

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateLiquidationCubit, CreateLiquidationState>(
      listener: (context, state) {
        if (state is CreateLiquidationOnSend) {
          Navigator.of(context).pop(state.liquidation);
        }
      },
      child: Scaffold(
        body: _buildBody(),
        floatingActionButton: _floating(),
      ),
    );
  }

  StreamBuilder<bool> _floating() {
    return StreamBuilder<bool>(
        stream: bloc.enableButton,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton.extended(
              onPressed: () {
                bloc.sendLiquidation();
              },
              icon: const Icon(
                Icons.check,
              ),
              label: StreamBuilder<double>(
                  stream: bloc.realPrice,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                          CurrencyUtility.doubleToCurrency(snapshot.data!));
                    }
                    return Container();
                  }),
            );
          }
          return Container();
        });
  }

  Widget _buildBody() {
    var height = 130.0;
    var movement = height / 4;
    return StreamBuilder<bool>(
        stream: bloc.enableInput,
        initialData: false,
        builder: (context, snapshot) {
          return TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              tween: snapshot.data!
                  ? Tween(begin: 0.0, end: 1.0)
                  : Tween(begin: 1.0, end: 0.0),
              builder: (context, value, _) {
                return Center(
                  child: SizedBox(
                    height: height,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: Offset(
                              0,
                              lerpDouble(movement * 2, movement * 3, value) ??
                                  movement),
                          child: _selectDayWidget(),
                        ),
                        Transform.translate(
                          offset: Offset(0, -movement * value),
                          child: _selectEmployeeWidget(),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  Offset? _tapPosition;

  Widget _selectDayWidget() {
    return Container(
      width: 250,
      height: 50,
      decoration: BoxDecoration(
        color: ColorPalete.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
              onTap: bloc.decreaseDay,
              child: Icon(Icons.arrow_back_ios, color: ColorPalete.primary)),
          StreamBuilder<int>(
              stream: bloc.day,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text("${snapshot.data} dias",
                      style: TextStyle(
                        color: ColorPalete.primary,
                        fontSize: 16,
                      ));
                }
                return Text(
                  "Dias trabajados",
                  style: TextStyle(
                    color: ColorPalete.primary,
                    fontSize: 16,
                  ),
                );
              }),
          GestureDetector(
              onTap: bloc.increaseDay,
              child: Icon(Icons.arrow_forward_ios, color: ColorPalete.primary)),
        ],
      ),
    );
  }

  Widget _selectEmployeeWidget() {
    var borderRadius = BorderRadius.circular(10);
    return Material(
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          showSelectEmployeeDialog(context).then((value) {
            if (value is Employee) {
              bloc.selectEmployee(value);
            }
          });
        },
        child: StreamBuilder<Employee>(
            stream: bloc.employeeSelected,
            builder: (context, snapshot) {
              return Ink(
                width: 300,
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: snapshot.hasData
                      ? ColorPalete.secondary
                      : ColorPalete.primary,
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 7,
                      offset: const Offset(0, -3), // changes position of shadow
                    ),
                  ],
                ),
                child: Center(
                  child: snapshot.hasData
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            EmployeeAvatar(snapshot.data!.image,
                                id: snapshot.data!.id ?? 0),
                            Text(
                              snapshot.data!.firstname,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              CurrencyUtility.doubleToCurrency(
                                  snapshot.data!.salary),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "SELECCIONE",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ColorPalete.white,
                          ),
                        ),
                ),
              );
            }),
      ),
    );
  }
}
