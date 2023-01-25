import 'package:cotizacion_dm/core/domain/employee/employee.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/bloc/bloc.dart';
import 'package:cotizacion_dm/ui/pages/employee_page/bloc/bloc.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CardEmployee extends StatelessWidget {
  final Uint8List? image;
  final double brightness;
  final String code;
  final bool onDetails;
  final Function()? onTap;
  const CardEmployee({
    Key? key,
    required this.color,
    this.brightness = 0.0,
    required this.code,
    this.onDetails = false,
    this.image,
    this.onTap,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    var haveImage = image != null;
    var borderRadius =
        onDetails ? BorderRadius.zero : BorderRadius.circular(40);
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: "card-employee-$code",
        child: Container(
          width: onDetails ? double.infinity : 250,
          height: onDetails ? double.infinity : 400,
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: haveImage
              ? ClipRRect(
                  borderRadius: borderRadius,
                  child: ImageFilterProvider.filter(
                    brightness: brightness,
                    child: Image.memory(
                      image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : !onDetails
                  ? Center(
                      child: Icon(
                        Icons.person,
                        color: BgFgColorUtility.getFgForBg(color.value),
                        size: 100,
                      ),
                    )
                  : null,
        ),
      ),
    );
  }
}

class CardEmployeeInfo extends StatelessWidget {
  final Employee employee;
  const CardEmployeeInfo(this.employee, {super.key});

  @override
  Widget build(BuildContext context) {
    final SnackbarBloc snackbarBloc = BlocProvider.of(context);
    return BlocProvider<EmployeeDetailsCubit>(
      create: (context) => EmployeeDetailsCubit(employee, getIt()),
      child: BlocListener<EmployeeDetailsCubit, EmployeeDetailsState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is OnActionFailed) {
            snackbarBloc.add(WarningSnackbarEvent(state.message));
          }
        },
        child: _CardEmployeeInfo(employee: employee),
      ),
    );
  }
}

class _CardEmployeeInfo extends StatelessWidget {
  final Employee employee;
  const _CardEmployeeInfo({
    Key? key,
    required this.employee,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FetchEmployeeCubit fetchBloc = BlocProvider.of(context);
    final EmployeeDetailsCubit detailsBloc = BlocProvider.of(context);

    var extentRatio = 0.65;
    var textStyleTitle = TextStyle(
      fontSize: 18,
      color: Colors.grey.shade600,
    );
    return Slidable(
      key: UniqueKey(),
      startActionPane: _leftActions(extentRatio, fetchBloc),
      endActionPane: _rightActions(extentRatio, detailsBloc),
      child: ListTile(
        onTap: () => fetchBloc.onShowEmployeeDetails(employee),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        leading: EmployeeAvatar(employee.image, id: employee.id ?? 0),
        title: Text("${employee.firstname} ${employee.lastname}",
            style: textStyleTitle),
      ),
    );
  }

  ActionPane _rightActions(
      double extentRatio, EmployeeDetailsCubit detailsBloc) {
    return ActionPane(
      motion: const BehindMotion(),
      extentRatio: extentRatio,
      children: [
        SlidableAction(
          label: "Llamar",
          icon: Icons.call,
          onPressed: (_) => detailsBloc.onCall(),
          foregroundColor: ColorPalete.white,
          backgroundColor: ColorPalete.primary,
        ),
        SlidableAction(
          label: "Whatsapp",
          icon: Icons.whatsapp,
          onPressed: (_) => detailsBloc.onWhatsappChat(),
          foregroundColor: ColorPalete.white,
          backgroundColor: ColorPalete.success,
        )
      ],
    );
  }

  ActionPane _leftActions(double extentRatio, FetchEmployeeCubit fetchBloc) {
    return ActionPane(
      extentRatio: extentRatio,
      motion: const BehindMotion(),
      children: [
        SlidableAction(
          label: "Eliminar",
          icon: Icons.delete,
          onPressed: (_) => fetchBloc.deleteEmployee(employee),
          foregroundColor: ColorPalete.white,
          backgroundColor: ColorPalete.error,
        ),
        SlidableAction(
          label: "Editar",
          icon: Icons.edit,
          onPressed: (_) => fetchBloc.onEditEmployee(employee),
          foregroundColor: ColorPalete.white,
          backgroundColor: ColorPalete.primary,
        )
      ],
    );
  }
}

class EmployeeAvatar extends StatelessWidget {
  const EmployeeAvatar(
    this.image, {
    Key? key,
    required this.id,
  }) : super(key: key);

  final Uint8List? image;
  final int id;

  @override
  Widget build(BuildContext context) {
    var bool = image is Uint8List;
    return Hero(
      tag: id,
      child: CircleAvatar(
        backgroundImage: bool ? MemoryImage(image!) : null,
        foregroundColor: bool ? Colors.transparent : null,
        child: const Icon(Icons.person),
      ),
    );
  }
}
