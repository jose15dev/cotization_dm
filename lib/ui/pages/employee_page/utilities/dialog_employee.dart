import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void dialogEmployeeForm(BuildContext context, TapDownDetails details,
    {Employee? employee,
    List<Color> colors = const [],
    bool withImagePicker = false}) {
  dialogScale<Employee?>(
      context,
      details.globalPosition,
      BlocProvider(
        create: (context) => FormEmployeeCubit(),
        child: EmployeeFormInfo(
          employee,
          withImagePicker: withImagePicker,
          colors: colors,
        ),
      )).then((value) {
    if (value is Employee) {
      BlocProvider.of<FetchEmployeeCubit>(context).saveEmployee(value);
    } else {
      BlocProvider.of<FetchEmployeeCubit>(context).resetState();
    }
  });
}
