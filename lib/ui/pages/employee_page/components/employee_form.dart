import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/bloc/bloc.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/styled/styled.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/form_employee_bloc/contact.dart';

void dialogEmployeeForm(BuildContext context, [Employee? editItem]) {
  showGeneralDialog<Employee?>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Label",
    barrierColor: ColorPalete.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 700),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      var scaleAnimation = CurveTween(
        curve: Interval(
          0.5,
          1.0,
          curve: Curves.easeOut,
        ),
      ).animate(animation);
      var translateAnimation = CurveTween(
        curve: Interval(
          0.0,
          0.5,
          curve: Curves.easeOut,
        ),
      ).animate(animation);

      return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Transform(
              alignment: FractionalOffset.topCenter,
              transform: Matrix4.translationValues(
                  0.0, translateAnimation.value * 100, 0.0)
                ..scale(scaleAnimation.value),
              child: child,
            );
          });
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
          alignment: FractionalOffset.topCenter,
          child: FormEmployeeDialog(editItem));
    },
  ).then((employee) {
    if (employee is Employee) {
      BlocProvider.of<FetchEmployeeCubit>(context).saveEmployee(employee);
    } else {
      BlocProvider.of<FetchEmployeeCubit>(context).resetState();
    }
  });
}

class FormEmployeeDialog extends StatelessWidget {
  final Employee? employee;
  const FormEmployeeDialog(this.employee, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Container(
        margin: const EdgeInsets.only(top: 30.0, right: 24, left: 24),
        child: BlocProvider(
          create: (context) => FormEmployeeCubit(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Material(
              color: ColorPalete.white,
              child: EmployeeFormInfo(employee),
            ),
          ),
        ),
      ),
    );
  }
}

class EmployeeFormInfo extends StatefulWidget {
  final Employee? employee;
  const EmployeeFormInfo(
    this.employee, {
    Key? key,
  }) : super(key: key);

  @override
  State<EmployeeFormInfo> createState() => _EmployeeFormInfoState();
}

class _EmployeeFormInfoState extends State<EmployeeFormInfo> {
  late ProfileImagePickerCubit imageBloc;
  FormEmployeeCubit get formBloc => BlocProvider.of(context);
  late TextEditingController firstnameCtrl, lastnameCtrl, phoneCtrl, salaryCtrl;

  SnackbarBloc get snackbarBloc => BlocProvider.of(context);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firstnameCtrl =
        TextEditingController(text: widget.employee?.firstname ?? "");
    lastnameCtrl = TextEditingController(text: widget.employee?.lastname ?? "");
    phoneCtrl = TextEditingController(text: widget.employee?.phone ?? "");
    salaryCtrl = TextEditingController(
        text: CurrencyUtility.doubleToCurrency(widget.employee?.salary ?? 0));

    if (widget.employee is Employee) {
      formBloc.onUpdateEmployee(widget.employee!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CurrencyTextInputFormatter formatter = CurrencyTextInputFormatter(
      symbol: "\$",
      decimalDigits: 1,
    );

    return BlocListener<FormEmployeeCubit, FormEmployeeState>(
      listener: (context, state) {
        if (state is FormEmployeeSaveInfoSuccess) {
          Navigator.of(context).pop(state.employee);
        }
        if (state is FormEmployeeSaveInfoSuccess ||
            state is FormEmployeeInitial) {
          clearFields();
        }
        if (state is FormEmployeeOnEdit) {
          loadFields(state.firstname, state.lastname, state.phone, state.salary,
              state.image);
        }

        if (state is FormEmployeeFailed) {
          snackbarBloc.add(WarningBannerEvent(state.message));
          if (state is OnContactsFailed) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
        }
        if (state is OnContactsSaveSuccess) {
          snackbarBloc.add(SuccessBannerEvent("Genial!!"));
        }

        if (state is OnContactsLoading) {
          _contactDialog();
        }

        if (state is FormEmployeeOnEdit) {
          loadFields(state.firstname, state.lastname, state.phone, state.salary,
              state.image);
        }
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _imagePicker(),
          ),
          SliverToBoxAdapter(
            child: _form(formatter),
          ),
          SliverToBoxAdapter(
            child: _actions(),
          ),
          spacer,
          SliverToBoxAdapter(
            child: _contactAction(),
          ),
        ],
      ),
    );
  }

  Widget _contactAction() {
    return BlocBuilder<FormEmployeeCubit, FormEmployeeState>(
      builder: (context, state) {
        Function()? getContacts;
        if (state is! OnContactsLoading) {
          getContacts = formBloc.getContacts;
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: PrimaryButton(
            "Usar contacto del telefono",
            fontSize: 18,
            textOnly: true,
            bordered: true,
            onTap: getContacts,
          ),
        );
      },
    );
  }

  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: StreamBuilder<bool>(
          stream: formBloc.validateForm,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!) {
                return PrimaryButton("Guardar", onTap: formBloc.saveInfo);
              }
            }
            return Container();
          }),
    );
  }

  SizedBox _imagePicker() {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: ProfileImagePicker(
        onChange: formBloc.updateImage,
        controller: ((p0) {
          var image = widget.employee?.image;
          if (image is Uint8List) {
            p0.loadImage(image);
          }

          imageBloc = p0;
        }),
      ),
    );
  }

  Widget _form(CurrencyTextInputFormatter formatter) {
    var fontSize = 20.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
      child: Column(
        children: [
          CustomTextfield(
            label: "Nombres",
            align: TextAlign.start,
            filled: true,
            fontSize: fontSize,
            stream: formBloc.firstnameStream,
            controller: firstnameCtrl,
            type: TextInputType.name,
            onChanged: formBloc.updateFirstname,
          ),
          CustomTextfield(
            label: "Apellidos",
            fontSize: fontSize,
            align: TextAlign.start,
            filled: true,
            stream: formBloc.lastnameStream,
            controller: lastnameCtrl,
            type: TextInputType.name,
            onChanged: formBloc.updateLastname,
          ),
          CustomTextfield(
            label: "Telefono",
            fontSize: fontSize,
            align: TextAlign.start,
            filled: true,
            controller: phoneCtrl,
            stream: formBloc.phoneStream,
            type: TextInputType.phone,
            formatters: [
              PhoneInputFormatter(),
            ],
            onChanged: formBloc.updatePhone,
          ),
          CustomTextfield(
            controller: salaryCtrl,
            fontSize: fontSize,
            label: "Salario diario",
            align: TextAlign.start,
            filled: true,
            type: TextInputType.number,
            stream: formBloc.salaryStream,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              formatter,
            ],
            onChanged: formBloc.updateSalary,
          ),
        ],
      ),
    );
  }

  void loadFields(
      String firstname, String lastname, String phone, String salary,
      [Uint8List? image]) {
    setState(() {
      firstnameCtrl = TextEditingController(text: firstname);
      lastnameCtrl = TextEditingController(text: lastname);
      phoneCtrl = TextEditingController(text: phone);
      salaryCtrl = TextEditingController(text: salary);
    });
    if (image is Uint8List) {
      imageBloc.loadImage(image);
    }
  }

  void clearFields() {
    loadFields("", "", "", "");
    imageBloc.resetImage();
  }

  void _contactDialog() async {
    var contact = await showDialog<CustomContact>(
      context: context,
      builder: ((context) {
        return BlocBuilder<FormEmployeeCubit, FormEmployeeState>(
          bloc: formBloc,
          builder: (context, state) {
            if (state is OnContactsSuccess) {
              return SelectContactDialog(contacts: state.contacts);
            }
            return const LoadingIndicator();
          },
        );
      }),
    );
    if (contact != null) {
      formBloc.loadContact(contact);
    }
  }
}
