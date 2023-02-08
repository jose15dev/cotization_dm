import 'package:bloc/bloc.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/exceptions/exceptions.dart';
import 'package:cotizacion_dm/ui/pages/employee_page/bloc/form_employee_bloc/contact.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

part 'form_employee_state.dart';

class FormEmployeeCubit extends Cubit<FormEmployeeState> {
  int? id;
  final _firstnameCtrl = BehaviorSubject<String>();
  final _lastnameCtrl = BehaviorSubject<String>();
  final _phoneCtrl = BehaviorSubject<String>();
  final _salaryCtrl = BehaviorSubject<String>();
  final _imageCtrl = BehaviorSubject<Uint8List?>()..add(null);
  Stream<String> get firstnameStream => _firstnameCtrl.stream;
  Stream<String> get lastnameStream => _lastnameCtrl.stream;
  Stream<String> get phoneStream => _phoneCtrl.stream;
  Stream<Uint8List?> get imageStream => _imageCtrl.stream;
  Stream<String> get salaryStream => _salaryCtrl.stream;

  FormEmployeeCubit() : super(FormEmployeeInitial());

  void resetForm() {
    clearStreams();
    emit(FormEmployeeInitial());
  }

  void clearStreams() {
    _firstnameCtrl.add("");
    _lastnameCtrl.add("");
    _phoneCtrl.add("");
    _salaryCtrl.add("");
    _imageCtrl.add(null);
    id = null;
  }

  void onUpdateEmployee(Employee employee) {
    try {
      var firstname = employee.firstname;
      var lastname = employee.lastname;
      var phone = employee.phone;
      var salary = CurrencyUtility.doubleToCurrency(employee.salary);
      var image = employee.image;
      if (image != null) updateImage(image);
      updateFirstname(firstname);
      updateLastname(lastname);
      updatePhone(phone);
      updateSalary(salary);
      id = employee.id;
      emit(FormEmployeeOnEdit(firstname, lastname, phone, salary, image));
    } catch (e) {
      emit(FormEmployeeOnEditFailed(e.toString()));
    }
  }

  void getContacts() async {
    try {
      emit(OnContactsLoading());
      var status = (await Permission.contacts.request()).isGranted;
      if (status) {
        var list = await ContactsService.getContacts();
        if (list.isEmpty) {
          emit(OnContactsEmpty());
        }
        if (list.isNotEmpty) {
          var items = list
              .where((e) => e.phones?.isNotEmpty == true)
              .map((e) => CustomContact.fromContactService(e))
              .toList();
          emit(OnContactsSuccess(items));
        }
      } else {
        emit(const OnContactsFailed("No tiene permisos"));
      }
    } catch (e) {
      emit(OnContactsFailed(e.toString()));
    }
  }

  void loadContact(CustomContact contact) {
    try {
      emit(OnContactsSaveLoading());
      var avatar = contact.avatar;
      updateLastname("");
      updateSalary("");
      updatePhone(contact.phone);
      updateFirstname(contact.name);
      var validateImage = avatar != null && avatar.isNotEmpty;
      if (validateImage) updateImage(avatar);
      emit(FormEmployeeOnEdit(
        contact.name,
        "",
        contact.phone,
        "",
        validateImage ? avatar : null,
      ));
    } catch (e) {
      emit(OnContactsSaveFailed(e.toString()));
    }
  }

  void updateImage(Uint8List value) {
    try {
      emit(FormEmployeeValidationLoading());
      _imageCtrl.add(value);
      emit(FormEmployeeValidationSuccess());
    } on BaseFormException catch (e) {
      emit(FormEmployeeImageError(e.message));
    }
  }

  void updateFirstname(String value) {
    try {
      emit(FormEmployeeValidationLoading());
      FieldValidation(value);
      _firstnameCtrl.add(value);
      emit(FormEmployeeValidationSuccess());
    } on BaseFormException catch (e) {
      _firstnameCtrl.sink.addError(e.message);
      emit(FormEmployeeValidationFailed());
    }
  }

  void updateLastname(String value) {
    try {
      emit(FormEmployeeValidationLoading());
      FieldValidation(value);
      _lastnameCtrl.add(value);
      emit(FormEmployeeValidationSuccess());
    } on BaseFormException catch (e) {
      _lastnameCtrl.sink.addError(e.message);
      emit(FormEmployeeValidationFailed());
    }
  }

  void updatePhone(String value) {
    try {
      emit(FormEmployeeValidationLoading());
      PhoneValidation(value);
      _phoneCtrl.add(value);
      emit(FormEmployeeValidationSuccess());
    } on BaseFormException catch (e) {
      _phoneCtrl.sink.addError(e.message);
      emit(FormEmployeeValidationFailed());
    }
  }

  void updateSalary(String value) {
    try {
      emit(FormEmployeeValidationLoading());
      CurrencyValidation(value);
      _salaryCtrl.add(value);
      emit(FormEmployeeValidationSuccess());
    } on BaseFormException catch (e) {
      _salaryCtrl.sink.addError(e.message);
      emit(FormEmployeeValidationFailed());
    }
  }

  void saveInfo() async {
    try {
      emit(FormEmployeeSaveInfoLoading());
      var employee = Employee(
        id: id,
        firstname: _firstnameCtrl.value.trim(),
        lastname: _lastnameCtrl.value.trim(),
        phone: _phoneCtrl.value.trim(),
        image: _imageCtrl.value,
        salary: CurrencyUtility.currencyToDouble(_salaryCtrl.value),
      );
      emit(FormEmployeeSaveInfoSuccess(employee));
      clearStreams();
    } on ValueStreamError {
      emit(const FormEmployeeSaveInfoFailed("Campos vacios", true));
    } on Exception catch (e) {
      emit(FormEmployeeSaveInfoFailed(e.toString()));
    }
  }

  Stream<bool> get validateForm {
    return Rx.combineLatest4(
      firstnameStream,
      lastnameStream,
      phoneStream,
      salaryStream,
      (a, b, c, d) {
        try {
          FieldValidation(a);
          FieldValidation(b);
          PhoneValidation(c);
          CurrencyValidation(d);
          return true;
        } catch (e) {
          return false;
        }
      },
    );
  }
}
