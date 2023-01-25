import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

part 'employee_details_state.dart';

class EmployeeDetailsCubit extends Cubit<EmployeeDetailsState> {
  final LiquidationService _service;
  final Employee employee;
  final _liquidationsCtrl = BehaviorSubject<List<Liquidation>>();
  Stream<List<Liquidation>> get liquidations => _liquidationsCtrl.stream;

  Map<String, void Function()> get exceptions => <String, Function()>{
        'ACTIVITY_NOT_FOUND': () =>
            emit(const OnActionFailed("No se encontro la aplicacion")),
        'UNKNOWN': () => emit(const OnActionFailed("Error desconocido")),
      };

  EmployeeDetailsCubit(this.employee, this._service)
      : super(EmployeeDetailsInitial());

  void onCall() async {
    try {
      emit(OnCallLoading());
      var callnumber = PhoneNumberUtility.toCallNumber(employee.phone);
      var uri = Uri.parse("tel:$callnumber");
      await launchUrl(uri);
      emit(OnCallSuccess());
    } on PlatformException catch (e) {
      var emit = exceptions[e.code];
      emit ??= exceptions['UNKNOWN'];
      emit!();
    }
  }

  void onWhatsappChat() async {
    try {
      emit(OnWhatsappChatLoading());
      var callnumber = PhoneNumberUtility.toCallNumber(employee.phone);
      var uri = Uri.parse("whatsapp://send?phone=+57$callnumber");
      await launchUrl(uri);
      emit(OnWhatsappChatSuccess());
    } on PlatformException catch (e) {
      var emit = exceptions[e.code];
      emit ??= exceptions['UNKNOWN'];
      emit!();
    }
  }

  void getLiquidations() async {
    try {
      var liquidations = await _service.findByEmployee(employee);
      if (liquidations.isEmpty) {
        emit(OnGetLiquidationsEmpty());
      } else {
        _liquidationsCtrl.add(liquidations);
        emit(OnGetLiquidationsSuccess());
      }
    } catch (e) {
      emit(OnActionFailed(e.toString()));
    }
  }

  Stream<bool> get hasLiquidations =>
      _liquidationsCtrl.stream.map((e) => e.isNotEmpty);
}
