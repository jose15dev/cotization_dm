import 'dart:developer';
import 'dart:ui';

import 'package:cotizacion_dm/core/domain/employee/employee.dart';
import 'package:cotizacion_dm/globals.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/transitions/transitions.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

class AnimatedEmployeeCard extends StatefulWidget {
  const AnimatedEmployeeCard({
    Key? key,
    required this.listColors,
    required this.employee,
    this.isDetail = false,
    this.isSmall = false,
  }) : super(key: key);

  final List<Color> listColors;
  final Employee employee;
  final bool isDetail, isSmall;

  @override
  State<AnimatedEmployeeCard> createState() => _AnimatedEmployeeCardState();
}

class _AnimatedEmployeeCardState extends State<AnimatedEmployeeCard>
    with TickerProviderStateMixin {
  Offset _currentDraggingOffset = Offset.zero;
  double _lastOffsetDy = 0.0;
  late AnimationController _animationController;

  bool get hasImage => _image != null;
  Uint8List? _image;
  bool _isEditing = false;
  void _onDragEnd(DragEndDetails details) {
    _lastOffsetDy = _currentDraggingOffset.dy;
    final animation = Tween<double>(begin: _lastOffsetDy, end: 0.0)
        .animate(_animationController);
    animation.addListener(() {
      if (mounted) {
        setState(() {
          _lastOffsetDy = animation.value;
          _currentDraggingOffset = Offset(0.0, _lastOffsetDy);
        });
      }
    });
    if (!_animationController.isAnimating) {
      _animationController.forward(from: 0.0);
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _lastOffsetDy += details.primaryDelta!;
    if (_lastOffsetDy < -180) {
      _lastOffsetDy = -180.0;
    }
    if (_lastOffsetDy > 180) {
      _lastOffsetDy = 180.0;
    }
    setState(() {
      _currentDraggingOffset = Offset(0.0, _lastOffsetDy);
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _image = widget.employee.image;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final Color foreground = Colors.grey.shade900;
  final Color colorIcon = ColorPalete.white;
  double get currentAngle => (math.pi / 180) * (_currentDraggingOffset.dy);
  bool get canAnimate =>
      widget.isDetail && (ModalRoute.of(context)?.animation?.value == 1.0);
  double get currentAngleBack =>
      (math.pi / 180) * (_currentDraggingOffset.dy + 180);

  bool get displayBack => (currentAngle < -1.5 || currentAngle > 1.5);

  FetchEmployeeCubit get bloc => BlocProvider.of<FetchEmployeeCubit>(context);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return LayoutBuilder(builder: (context, constraints) {
            var radius = constraints.maxWidth * 0.3;
            var padding = 5.0;
            var iconSize = constraints.maxHeight / 4;
            var fontSize = constraints.maxWidth / 10;
            return Material(
              color: Colors.transparent,
              child: GestureDetector(
                onVerticalDragUpdate: canAnimate ? _onDragUpdate : null,
                onVerticalDragEnd: canAnimate ? _onDragEnd : null,
                onTap: !canAnimate
                    ? () => Navigator.of(context)
                            .push(fadeTransition(EmployeeDetailsPage(
                                widget.employee,
                                colors: widget.listColors)))
                            .then((value) {
                          if (value is Employee) {
                            bloc.deleteEmployee(value);
                          } else {
                            bloc.resetState();
                          }
                        })
                    : null,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                        child: _front(radius, padding, iconSize, fontSize)),
                    if (displayBack && canAnimate)
                      Positioned.fill(child: _back(radius, padding, fontSize)),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget _back(double radius, double padding, double fontSize) {
    return Transform(
        alignment: Alignment.center,
        transform: canAnimate ? Matrix4.identity() : Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateX(currentAngleBack),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              if (!widget.isDetail)
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 6,
                  offset: const Offset(0, 8),
                ),
            ],
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: widget.listColors,
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.isDetail && !widget.isSmall)
                Align(
                  alignment: const FractionalOffset(1.0, 0.95),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: ColorPalete.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                          ),
                        ]),
                  ),
                ),
              RotateBackground(
                colors: widget.listColors,
                padding: padding,
                radius: radius,
                child: _phone(fontSize),
              )
            ],
          ),
        ));
  }

  Widget _phone(double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(FontAwesomeIcons.phone, color: colorIcon, size: fontSize),
        const SizedBox(width: 10.0),
        Text(
          PhoneNumberUtility.toAppNumber(widget.employee.phone),
          style: TextStyle(
            color: ColorPalete.white,
            fontSize: fontSize,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _front(
      double radius, double padding, double iconSize, double fontSize) {
    return Transform(
      alignment: Alignment.center,
      transform: canAnimate ? Matrix4.identity() : Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateX(currentAngle),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            if (!widget.isDetail)
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 6,
              ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.listColors,
          ),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RotateBackground(
              padding: padding,
              radius: radius,
              colors: widget.listColors,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius - padding),
                child: hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageFilterProvider.filter(
                            brightness: _isEditing ? -.15 : 0.0,
                            child: Image.memory(
                              _image!,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                          ),
                          if (_isEditing)
                            GestureDetector(
                              onTapDown: _editImage,
                              child: Center(
                                child: Icon(
                                  FontAwesomeIcons.pencil,
                                  size: 50,
                                  color: ColorPalete.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Icon(
                        FontAwesomeIcons.userLarge,
                        size: iconSize,
                        color: ColorPalete.white,
                      ),
              ),
            ),
            if (widget.isDetail && !widget.isSmall)
              Align(
                alignment: const FractionalOffset(1.0, 0.05),
                child: GestureDetector(
                  onTapDown: ((details) {
                    _isEditing ? _saveImage() : _editImage(details);
                  }),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: ColorPalete.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                          ),
                        ]),
                    child: Icon(
                        _isEditing
                            ? FontAwesomeIcons.solidFloppyDisk
                            : FontAwesomeIcons.pencil,
                        color: ColorPalete.black),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  void _saveImage() {
    bloc.saveEmployee(Employee(
      id: widget.employee.id,
      firstname: widget.employee.firstname,
      lastname: widget.employee.lastname,
      salary: widget.employee.salary,
      phone: widget.employee.phone,
      image: _image,
    ));
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _editImage(TapDownDetails details) async {
    var result = (await dialogScale<ResultImagePicker>(
            context, details.globalPosition, SelectImageMenu())) ??
        ResultImagePicker();
    if (result.remove) {
      setState(() {
        _image = null;
        _isEditing = true;
      });
      return;
    }
    if (result.image == null) return;
    setState(() {
      _image = result.image;
      if (result.image is Uint8List) {
        _isEditing = true;
      } else {
        _isEditing = false;
      }
    });
  }
}

class EmployeeDetails extends StatefulWidget {
  const EmployeeDetails({
    Key? key,
    this.progress = 1.0,
    required this.employee,
    this.isDetail = false,
    this.isSmall = false,
    this.fontSize = 25.0,
  }) : super(key: key);

  final double progress, fontSize;
  final bool isDetail, isSmall;
  final Employee employee;

  @override
  State<EmployeeDetails> createState() => _EmployeeDetailsState();
}

class _EmployeeDetailsState extends State<EmployeeDetails> {
  late Employee _employee;
  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(lerpDouble(1.5, 1.0, widget.progress)),
        child: Column(
          crossAxisAlignment: widget.isDetail && widget.isSmall
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isDetail && !widget.isSmall)
              Text(
                _employee.firstname,
                style: TextStyle(
                    fontSize: widget.fontSize, color: Colors.grey.shade700),
              ),
            if (widget.isDetail && !widget.isSmall)
              Text(
                "${_employee.firstname} ${_employee.lastname}",
                style: TextStyle(
                    fontSize: widget.fontSize, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            if (widget.isDetail && widget.isSmall)
              Text(
                _employee.firstname,
                style: TextStyle(
                    fontSize:
                        widget.isDetail ? widget.fontSize - 5 : widget.fontSize,
                    color: Colors.grey.shade700),
              ),
            if (widget.isDetail && widget.isSmall)
              Text(
                _employee.lastname,
                style: TextStyle(
                    fontSize:
                        widget.isDetail ? widget.fontSize - 5 : widget.fontSize,
                    color: Colors.grey.shade700),
              ),
            const SizedBox(height: 10),
            Text(
              "Cobra ${CurrencyUtility.doubleToCurrency(_employee.salary)} COP",
              style: TextStyle(
                fontSize: widget.fontSize - 8,
                color: Colors.grey.shade500,
              ),
            ),
            if (widget.isDetail && widget.isSmall) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.phone,
                    size: widget.fontSize - 10,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    PhoneNumberUtility.toAppNumber(
                      _employee.phone,
                    ),
                    style: TextStyle(
                      fontSize: widget.fontSize - 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
