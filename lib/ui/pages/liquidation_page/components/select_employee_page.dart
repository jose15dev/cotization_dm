import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/bloc/snackbar/snackbar_bloc.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/styled/styled.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<Employee?> showSelectEmployeeDialog(BuildContext context) {
  return showGeneralDialog<Employee>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Label",
      barrierColor: ColorPalete.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Align(
          alignment: FractionalOffset.topCenter,
          child: SelectEmployeeDialog(),
        );
      });
}

class SelectEmployeeDialog extends StatelessWidget {
  const SelectEmployeeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const SelectEmployeeView();
  }
}

class SelectEmployeeView extends StatefulWidget {
  const SelectEmployeeView({super.key});

  @override
  State<SelectEmployeeView> createState() => _SelectEmployeeViewState();
}

class _SelectEmployeeViewState extends State<SelectEmployeeView> {
  FetchEmployeeCubit get employeeBloc => BlocProvider.of(context);
  SnackbarBloc get snackbarBloc => BlocProvider.of(context);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    employeeBloc.fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Container(
        margin: const EdgeInsets.only(top: 30.0, right: 24, left: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Material(
            color: ColorPalete.white,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return _items();
  }

  Widget _items() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return BlocBuilder<FetchEmployeeCubit, FetchEmployeeState>(
      builder: (context, state) {
        if (state is OnFetchEmployeeLoading) {
          return SizedBox(
            width: width,
            height: height / 1.5,
            child: const LoadingIndicator(),
          );
        }

        if (state is OnFetchEmployeeEmpty) {
          return SizedBox(
            width: width,
            height: height / 1.5,
            child: MessageInfo(
              "No hay trabajadores.\n Presione para añadir",
              icon: Icons.person_add,
              onTap: () {},
            ),
          );
        }
        return BlocBuilder<FetchEmployeeCubit, FetchEmployeeState>(
          builder: (context, state) {
            if (state is OnFetchEmployeeSuccess) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var employee = state.employees[index];
                  return EmployeeListTile(employee: employee);
                },
                itemCount: state.employees.length,
              );
            }
            return const SizedBox.shrink();
          },
        );
        ;
      },
    );
  }
}

class EmployeeListTile extends StatelessWidget {
  const EmployeeListTile({
    Key? key,
    required this.employee,
  }) : super(key: key);

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).pop(employee),
      textColor: Colors.grey.shade600,
      // leading: EmployeeAvatar(employee.image, id: employee.id ?? 0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(employee.firstname),
          Text(employee.lastname),
        ],
      ),
      trailing: Text(
        CurrencyUtility.doubleToCurrency(employee.salary),
      ),
    );
  }
}
