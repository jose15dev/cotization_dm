import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/exceptions/form_validation.dart';
import 'package:cotizacion_dm/ui/utilities/currency.utility.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'create_liquidation_state.dart';

class CreateLiquidationCubit extends Cubit<CreateLiquidationState> {
  final _employeeSelected = BehaviorSubject<Employee>();
  final _dayCtrl = BehaviorSubject<int>();
  final _realPriceCtrl = BehaviorSubject<double>();

  Stream<Employee> get employeeSelected => _employeeSelected.stream;
  Stream<int> get day => _dayCtrl.stream;
  Stream<double> get realPrice => _realPriceCtrl.stream;

  CreateLiquidationCubit() : super(CreateLiquidationInitial()) {
    _dayCtrl.listen((value) {
      _realPriceCtrl.add(value * _employeeSelected.value.salary);
    });
  }

  void resetState() {
    emit(CreateLiquidationInitial());
  }

  void selectEmployee(Employee employee) {
    _employeeSelected.add(employee);
    emit(CreateLiquidationOnEmployeeSelected());
  }

  void updateDay(String value) {
    try {
      NumberValidation(value);
      final day = int.parse(value);
      _dayCtrl.add(day);
    } on BaseFormException catch (e) {
      _dayCtrl.sink.addError(e);
    }
  }

  void increaseDay() {
    if (_dayCtrl.hasValue) {
      _dayCtrl.add(_dayCtrl.value + 1);
    } else {
      _dayCtrl.add(1);
    }
  }

  void decreaseDay() {
    if (_dayCtrl.hasValue && _dayCtrl.value > 1) {
      _dayCtrl.add(_dayCtrl.value - 1);
    }
  }

  void updateRealPrice(String value) {
    try {
      CurrencyValidation(value);
      final realPrice = CurrencyUtility.currencyToDouble(value);
      _realPriceCtrl.add(realPrice);
    } on BaseFormException catch (e) {
      _realPriceCtrl.sink.addError(e);
    }
  }

  void sendLiquidation() {
    final liquidation = Liquidation(
      employee: _employeeSelected.value,
      days: _dayCtrl.value,
      realPrice: _realPriceCtrl.value,
      createdAt: DateTime.now(),
    );
    emit(CreateLiquidationOnSend(liquidation));
  }

  Stream<bool> get enableInput =>
      Rx.combineLatest([employeeSelected], (values) => true);

  Stream<bool> get enableButton =>
      Rx.combineLatest([employeeSelected, day, realPrice], (values) => true);
}
