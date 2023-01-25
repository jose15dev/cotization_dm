import 'dart:math' as math;
import 'dart:ui';

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const radius = 70.0;
const padding = 7.0;

class FetchEmployeeList extends StatefulWidget {
  const FetchEmployeeList({super.key});

  @override
  State<FetchEmployeeList> createState() => _FetchEmployeeListState();
}

class _FetchEmployeeListState extends State<FetchEmployeeList>
    with SingleTickerProviderStateMixin {
  late AnimationController _deleteController;
  final _nameScrollController = PageController();
  final _cardScrollController = PageController(
    viewportFraction: 0.77,
  );

  late Animation _elevateTrashAnimation;
  late Animation _moveToTrashAnimation;
  late Animation _rotateCardAnimation;
  late Animation _destroyInfoAnimation;
  late Animation _backTrashAnimation;
  double _currentPage = 0;
  int _currentEmployeeIndex = 0;
  int _deleteEmployeeIndex = 0;

  FetchEmployeeCubit get bloc => BlocProvider.of(context);
  Employee? _currentEmployee;

  @override
  void initState() {
    super.initState();
    bloc.fetchEmployees();
    _deleteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _elevateTrashAnimation = CurveTween(
        curve: const Interval(
      0.1,
      0.3,
      curve: Curves.easeInCubic,
    )).animate(_deleteController);
    _rotateCardAnimation = CurveTween(
        curve: const Interval(
      0.3,
      0.4,
      curve: Curves.easeIn,
    )).animate(_deleteController);
    _moveToTrashAnimation = CurveTween(
        curve: const Interval(
      0.45,
      0.6,
      curve: Curves.easeIn,
    )).animate(_deleteController);
    _destroyInfoAnimation = CurveTween(
        curve: const Interval(
      0.6,
      0.8,
      curve: Curves.easeIn,
    )).animate(_deleteController);
    _backTrashAnimation = CurveTween(
        curve: const Interval(
      0.8,
      1.0,
      curve: Curves.easeInCubic,
    )).animate(_deleteController);

    _cardScrollController.addListener(() {
      setState(() {
        _currentPage = _cardScrollController.page!;
        _currentEmployeeIndex = _cardScrollController.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var getHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(
          height: getHeight * .035,
        ),
        SizedBox(
          width: double.infinity,
          height: getHeight * 0.5,
          child: _employeeCardList(),
        ),
        Expanded(
          child: _employeeDetails(),
        ),
        SizedBox(
          height: kBottomNavigationBarHeight,
          child: _employeeActions(),
        ),
      ],
    );
  }

  Row _employeeActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () async {
            setState(() {
              _deleteEmployeeIndex = _currentEmployeeIndex;
            });
            if (_currentEmployee is Employee) {
              await _deleteController.forward();
              await bloc.deleteEmployee(_currentEmployee!);
              var current = _currentEmployeeIndex - 1;
              current = current < 0 ? 0 : current;
              await _goToPage(current);
              await _goToName(current);
              _deleteController.reset();
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                  animation: _deleteController,
                  builder: (context, _) {
                    var t = _elevateTrashAnimation.value -
                        _backTrashAnimation.value;
                    return Transform(
                      transform: Matrix4.identity()
                        ..translate(
                          lerpDouble(0, -10, t)!,
                          lerpDouble(0, -30, t)!,
                        )
                        ..scale(lerpDouble(1, 2, t)!),
                      child: Icon(
                        FontAwesomeIcons.solidTrashCan,
                        color: ColorPalete.error,
                      ),
                    );
                  }),
              Text("Eliminar",
                  style: TextStyle(
                    color: ColorPalete.error,
                  )),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            if (_currentEmployee != null) {
              bloc.onEditEmployee(_currentEmployee!);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.solidPenToSquare,
                color: ColorPalete.primary,
              ),
              Text("Editar",
                  style: TextStyle(
                    color: ColorPalete.primary,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  StreamBuilder<List<Employee>> _employeeCardList() {
    return StreamBuilder<List<Employee>>(
      stream: bloc.employeesStream,
      initialData: const [],
      builder: (BuildContext context, snapshot) {
        return PageView.builder(
          clipBehavior: Clip.none,
          controller: _cardScrollController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (value) {
            setState(() {
              _currentEmployee = snapshot.data![value];
            });
            _goToName(value);
          },
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var employee = snapshot.data![index];
            if (_deleteEmployeeIndex == index) {
              return AnimatedBuilder(
                  animation: _deleteController,
                  builder: (context, _) {
                    return Transform(
                      alignment: Alignment.lerp(
                        Alignment.center,
                        Alignment.bottomLeft,
                        _moveToTrashAnimation.value * 4,
                      ),
                      transform: Matrix4.identity()
                        ..translate(
                          0.0,
                          MediaQuery.of(context).size.height *
                              1.5 *
                              _moveToTrashAnimation.value,
                        )
                        ..scale(lerpDouble(1, 0.8, _rotateCardAnimation.value)!)
                        ..setEntry(3, 2, 0.001)
                        ..scale(lerpDouble(
                            1.0, 0.1, _moveToTrashAnimation.value * 4)!),
                      child: _employeeItem(employee, index),
                    );
                  });
            }
            return _employeeItem(employee, index);
          },
        );
      },
    );
  }

  Widget _employeeItem(Employee employee, int index) {
    var progress = (_currentPage - index);
    var scale = lerpDouble(1, .8, progress.abs())!;
    var isCurrentPage = index == _currentEmployeeIndex;
    var hasImage = employee.image != null;
    var indexColor = 0;

    if (index >= 18) {
      indexColor = index % 18;
    } else {
      indexColor = index;
    }
    var listColors =
        Colors.primaries.getRange(indexColor, indexColor + 2).toList();
    return Transform.scale(
      alignment: Alignment.lerp(Alignment.topLeft, Alignment.center, -progress),
      scale: scale,
      child: GestureDetector(
        onTap: () => bloc.onShowEmployeeDetails(employee),
        child: AnimatedContainer(
          transform: Matrix4.identity()
            ..translate(
                isCurrentPage ? 0.0 : -20.0, isCurrentPage ? 0.0 : 60.0),
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 6,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: listColors,
                stops: const [0.0, 0.7]),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: hasImage
              ? RotateBackground(
                  padding: padding,
                  radius: radius,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius - padding),
                    child: Hero(
                      tag: 'card-employee-${employee.id}',
                      child: Image.memory(
                        employee.image!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                )
              : Icon(
                  FontAwesomeIcons.userLarge,
                  size: 120,
                  color: ColorPalete.white,
                ),
        ),
      ),
    );
  }

  Future<void> _goToName(int value) {
    return _nameScrollController.animateToPage(
      value,
      duration: const Duration(
        milliseconds: 500,
      ),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goToPage(int value) {
    return _cardScrollController.animateToPage(
      value,
      duration: const Duration(
        milliseconds: 500,
      ),
      curve: Curves.easeOut,
    );
  }

  StreamBuilder<List<Employee>> _employeeDetails() {
    return StreamBuilder<List<Employee>>(
      stream: bloc.employeesStream,
      initialData: const [],
      builder: (BuildContext context, snapshot) {
        return PageView.builder(
          physics: const NeverScrollableScrollPhysics(),
          controller: _nameScrollController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var result = (_currentPage - index).abs();
            var employee = snapshot.data![index];
            return AnimatedBuilder(
                animation: _deleteController,
                builder: (context, _) {
                  return Opacity(
                    opacity: 1.0 - _destroyInfoAnimation.value,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(lerpDouble(1.5, 1.0, result)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            employee.firstname,
                            style: TextStyle(
                                fontSize: 30, color: Colors.grey.shade700),
                          ),
                          Text(
                            CurrencyUtility.doubleToCurrency(employee.salary),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          },
        );
      },
    );
  }
}
