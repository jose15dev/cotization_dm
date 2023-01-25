import 'dart:ui';

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/bloc/snackbar/snackbar_bloc.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeDetailsPage extends StatelessWidget {
  final Employee employee;
  const EmployeeDetailsPage(this.employee, {super.key});

  @override
  Widget build(BuildContext context) {
    SnackbarBloc snackbarBloc = BlocProvider.of(context);
    LiquidationService liquidationService = getIt();
    return BlocProvider(
      create: (context) => EmployeeDetailsCubit(employee, liquidationService),
      child: BlocListener<EmployeeDetailsCubit, EmployeeDetailsState>(
        listener: (context, state) {
          if (state is OnActionFailed) {
            snackbarBloc.add(WarningSnackbarEvent(state.message));
          }
        },
        child: _EmployeeDetailsView(employee),
      ),
    );
  }
}

class _EmployeeDetailsView extends StatefulWidget {
  final Employee employee;

  const _EmployeeDetailsView(
    this.employee, {
    Key? key,
  }) : super(key: key);

  @override
  State<_EmployeeDetailsView> createState() => _EmployeeDetailsViewState();
}

class _EmployeeDetailsViewState extends State<_EmployeeDetailsView> {
  var _scroll = 0.0;
  late Employee employee;
  EmployeeDetailsCubit get bloc => BlocProvider.of(context);
  FetchEmployeeCubit get fetchBloc => BlocProvider.of(context);

  @override
  void initState() {
    super.initState();
    employee = widget.employee;
    bloc.getLiquidations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<FetchEmployeeCubit, FetchEmployeeState>(
        listener: (context, state) {
          if (state is OnUpdateEmployeeSuccess) {
            setState(() {
              employee = state.employee;
            });
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: "card-employee-${employee.id}",
                child: ImageFilterProvider.filter(
                  brightness: lerpDouble(-.1, -.5, _scroll)!,
                  child: Container(
                    decoration: BoxDecoration(
                      image: employee.image != null
                          ? DecorationImage(
                              image: MemoryImage(employee.image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ColorPalete.primary,
                          ColorPalete.secondary,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: FractionalOffset.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: EmployeeInfo(
                  employee,
                  onEdit: () => fetchBloc.onEditEmployee(employee),
                ),
              ),
            ),
            Positioned.fill(
              child: NotificationListener<DraggableScrollableNotification>(
                onNotification: ((notification) {
                  setState(() {
                    _scroll = (notification.extent - 0.03) / 0.47;
                  });
                  return true;
                }),
                child: DraggableScrollableSheet(
                  maxChildSize: 0.5,
                  minChildSize: 0.03,
                  initialChildSize: 0.03,
                  builder: (context, scrollController) {
                    return LiquidationsSection(
                      liquidations: bloc.liquidations,
                      controller: scrollController,
                      onRefresh: () async => bloc.getLiquidations(),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Transform.translate(
                offset: Offset(0, -180 * (1 - _scroll)),
                child: ContactBanner(
                  height: 180,
                  onCall: () => bloc.onCall(),
                  onChat: () => bloc.onWhatsappChat(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
