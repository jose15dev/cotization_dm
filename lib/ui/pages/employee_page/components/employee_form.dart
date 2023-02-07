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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/form_employee_bloc/contact.dart';

class EmployeeFormInfo extends StatefulWidget {
  final Employee? employee;
  final List<Color> colors;
  final bool withImagePicker;
  const EmployeeFormInfo(this.employee,
      {Key? key, required this.withImagePicker, this.colors = const []})
      : super(key: key);

  @override
  State<EmployeeFormInfo> createState() => _EmployeeFormInfoState();
}

class _EmployeeFormInfoState extends State<EmployeeFormInfo> {
  FormEmployeeCubit get formBloc => BlocProvider.of(context);
  late TextEditingController firstnameCtrl, lastnameCtrl, phoneCtrl, salaryCtrl;

  SnackbarBloc get snackbarBloc => BlocProvider.of(context);
  late Color _foreground;
  late List<Color> _colors;
  late Uint8List? _image;

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

    _foreground =
        widget.colors.isNotEmpty ? widget.colors[0] : ColorPalete.primary;
    _colors = widget.colors;
    _image = widget.employee?.image;
  }

  @override
  Widget build(BuildContext context) {
    final CurrencyTextInputFormatter formatter = CurrencyTextInputFormatter(
      symbol: "\$",
      decimalDigits: 0,
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
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .8,
        child: BlocProvider(
          create: (context) => FormEmployeeCubit(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Material(
              color: ColorPalete.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.withImagePicker) _imagePicker(),
                  _form(formatter),
                  _actions(),
                  const SizedBox(
                    height: 10,
                  ),
                  _contactAction(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
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
          child: CustomButton(
            "Usar contacto del telefono",
            foreground: _foreground,
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
                return CustomButton(
                  "Guardar",
                  onTap: formBloc.saveInfo,
                  gradientColors: _colors,
                );
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
      child: InkWell(
        onTapDown: (details) async {
          var result = (await dialogScale<ResultImagePicker>(
                  context, details.globalPosition, const SelectImageMenu())) ??
              ResultImagePicker();
          setState(() {
            if (result.remove) {
              _image = null;
            } else {
              _image = result.image;
              if (_image is Uint8List) formBloc.updateImage(_image!);
            }
          });
        },
        child: Ink(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: _foreground.withOpacity(0.2),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: FractionalOffset.center,
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: _foreground,
                ),
              ),
              if (_image is Uint8List)
                Image.memory(
                  _image!,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        ),
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
            enableError: true,
            fontSize: fontSize,
            foreground: _foreground,
            stream: formBloc.firstnameStream,
            controller: firstnameCtrl,
            type: TextInputType.name,
            onChanged: formBloc.updateFirstname,
          ),
          CustomTextfield(
            label: "Apellidos",
            fontSize: fontSize,
            foreground: _foreground,
            align: TextAlign.start,
            filled: true,
            stream: formBloc.lastnameStream,
            enableError: true,
            controller: lastnameCtrl,
            type: TextInputType.name,
            onChanged: formBloc.updateLastname,
          ),
          CustomTextfield(
            label: "Telefono",
            fontSize: fontSize,
            foreground: _foreground,
            align: TextAlign.start,
            filled: true,
            controller: phoneCtrl,
            stream: formBloc.phoneStream,
            type: TextInputType.phone,
            enableError: true,
            formatters: [
              PhoneInputFormatter(),
            ],
            onChanged: formBloc.updatePhone,
          ),
          CustomTextfield(
            controller: salaryCtrl,
            fontSize: fontSize,
            foreground: _foreground,
            label: "Salario diario",
            enableError: true,
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
  }

  void clearFields() {
    loadFields("", "", "", "");
    setState(() {
      _image = null;
    });
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
