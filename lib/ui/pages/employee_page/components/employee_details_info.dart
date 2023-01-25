import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class EmployeeInfo extends StatefulWidget {
  final Function() onEdit;
  final Employee employee;
  const EmployeeInfo(this.employee, {super.key, required this.onEdit});

  @override
  State<EmployeeInfo> createState() => _EmployeeInfoState();
}

class _EmployeeInfoState extends State<EmployeeInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _fullnameAnimation, _salaryAnimation, _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    _fullnameAnimation =
        CurveTween(curve: const Interval(0.1, 0.5, curve: Curves.decelerate))
            .animate(_controller);
    _salaryAnimation =
        CurveTween(curve: const Interval(0.55, 0.8, curve: Curves.decelerate))
            .animate(_controller);

    _buttonAnimation =
        CurveTween(curve: const Interval(0.8, 1.0, curve: Curves.decelerate))
            .animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: [
            Align(
              alignment: FractionalOffset.lerp(const FractionalOffset(0.5, 1.5),
                  const FractionalOffset(0.5, 0.35), _fullnameAnimation.value)!,
              child: Text(
                "${widget.employee.firstname} ${widget.employee.lastname}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Align(
              alignment: FractionalOffset.lerp(
                const FractionalOffset(0.5, 1.5),
                const FractionalOffset(0.5, 0.6),
                _salaryAnimation.value,
              )!,
              child: Text(
                CurrencyUtility.doubleToCurrency(widget.employee.salary),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Align(
              alignment: FractionalOffset.lerp(
                const FractionalOffset(0.95, -0.5),
                const FractionalOffset(0.95, 0.1),
                _buttonAnimation.value,
              )!,
              child: FloatingActionButton(
                heroTag: "employee-details-edit",
                onPressed: widget.onEdit,
                child: const Icon(Icons.edit),
              ),
            ),
          ],
        );
      },
    );
  }
}
