import 'dart:ui';

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/globals.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/styled/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const radius = 70.0;

class FetchEmployeeList extends StatefulWidget {
  const FetchEmployeeList({super.key});

  @override
  State<FetchEmployeeList> createState() => _FetchEmployeeListState();
}

class _FetchEmployeeListState extends State<FetchEmployeeList> {
  final _nameScrollController = PageController();
  final _cardScrollController = PageController(
    viewportFraction: 0.77,
  );

  double _currentPage = 0;
  int _currentEmployeeIndex = 0;

  FetchEmployeeCubit get bloc => BlocProvider.of(context);

  @override
  void initState() {
    super.initState();
    bloc.fetchEmployees();
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
      ],
    );
  }

  Widget _employeeCardList() {
    return BlocBuilder<FetchEmployeeCubit, FetchEmployeeState>(
      builder: (context, state) {
        if (state is OnFetchEmployeeLoading) {
          return const Center(child: LoadingIndicator());
        }
        if (state is OnFetchEmployeeEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.faceSadTear,
                size: 100.0,
                color: Colors.grey.shade400,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "No hay empleados",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          );
        }
        if (state is OnFetchEmployeeSuccess) {
          return PageView.builder(
            clipBehavior: Clip.none,
            controller: _cardScrollController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (value) {
              _goToName(value);
            },
            itemCount: state.employees.length,
            itemBuilder: (context, index) {
              var employee = state.employees[index];

              return _employeeItem(employee, index);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _employeeItem(Employee employee, int index) {
    var progress = (_currentPage - index);
    var scale = lerpDouble(1, .8, progress.abs())!;
    var isCurrentPage = index == _currentEmployeeIndex;
    var indexColor = 0;

    if (index >= 18) {
      indexColor = index % 18;
    } else {
      indexColor = index;
    }
    var listColors =
        Colors.primaries.getRange(indexColor, indexColor + 2).toList();
    return _TransformCard(
        progress: progress,
        scale: scale,
        isCurrentPage: isCurrentPage,
        child: Hero(
            tag: 'card-employee-${employee.id}',
            child: AnimatedEmployeeCard(
                employee: employee, listColors: listColors)));
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

  Widget _employeeDetails() {
    return BlocBuilder<FetchEmployeeCubit, FetchEmployeeState>(
      builder: (context, state) {
        if (state is OnFetchEmployeeSuccess) {
          return PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: _nameScrollController,
            itemCount: state.employees.length,
            itemBuilder: (context, index) {
              var result = (_currentPage - index).abs();
              var employee = state.employees[index];
              return Hero(
                tag: "details-employee-${employee.id}",
                child: EmployeeDetails(progress: result, employee: employee),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _TransformCard extends StatelessWidget {
  final Widget child;
  const _TransformCard({
    super.key,
    required this.child,
    required this.progress,
    required this.scale,
    required this.isCurrentPage,
  });
  final double progress;
  final double scale;
  final bool isCurrentPage;
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: AnimatedContainer(
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
          ),
          transform: Matrix4.identity()
            ..translate(
                isCurrentPage ? 0.0 : -20.0, isCurrentPage ? 0.0 : 60.0),
          child: child),
    );
  }
}
