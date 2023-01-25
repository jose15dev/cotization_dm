import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/exceptions/form_validation.dart';
import 'package:cotizacion_dm/ui/utilities/currency.utility.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'form_cotization_item_state.dart';

class FormCotizationItemCubit extends Cubit<FormCotizationItemState> {
  final _nameCtrl = BehaviorSubject<String>(),
      _descCtrl = BehaviorSubject<String>()..add(""),
      _unitCtrl = BehaviorSubject<String>(),
      _unitValueCtrl = BehaviorSubject<String>(),
      _amountCtrl = BehaviorSubject<String>(),
      _totalValueCtrl = BehaviorSubject<double>();

  Stream<String> get nameStream => _nameCtrl.stream;
  Stream<String> get descStream => _descCtrl.stream;
  Stream<String> get unitStream => _unitCtrl.stream;
  Stream<String> get unitValueStream => _unitValueCtrl.stream;
  Stream<String> get amountStream => _amountCtrl.stream;
  Stream<double> get totalValueStream => _totalValueCtrl.stream;

  CotizationItem? oldItem;

  FormCotizationItemCubit() : super(FormCotizationItemInitial()) {
    validateForm.listen((event) {
      if (event) {
        emit(FormCotizationItemSuccess());
      } else {
        emit(const FormCotizationItemValidationFailed("Complete los campos"));
      }
    });
    calcTotal.listen((value) {
      _totalValueCtrl.add(value);
    });
  }

  void loadItem(CotizationItem item, [bool copy = false]) {
    updateName(item.name);
    updateDescription(item.description);
    updateAmount(item.amount.toString());
    updateUnit(item.unit);
    updateUnitValue(CurrencyUtility.doubleToCurrency(item.unitValue));
    if (!copy) oldItem = item;
  }

  void resetForm() {
    clearStreams();
    emit(FormCotizationItemInitial());
  }

  void clearStreams() {
    _nameCtrl.add("");
    _descCtrl.add("");
    _amountCtrl.add("");
    _unitCtrl.add("");
    _unitValueCtrl.add("");
    _totalValueCtrl.add(0);
  }

  void updateName(String value) {
    try {
      emit(FormCotizationItemValidationLoading());
      FieldValidation(value);
      _nameCtrl.add(value);
      emit(FormCotizationItemValidationSuccess());
    } on BaseFormException catch (e) {
      _nameCtrl.add("");
      emit(FormCotizationItemValidationFailed(e.message));
    }
  }

  void updateDescription(String value) {
    try {
      emit(FormCotizationItemValidationLoading());
      _descCtrl.add(value);
      emit(FormCotizationItemValidationSuccess());
    } catch (e) {
      _descCtrl.add("");
      emit(FormCotizationItemValidationFailed(e.toString()));
    }
  }

  void updateAmount(String value) {
    try {
      emit(FormCotizationItemValidationLoading());
      NumberValidation(value);
      _amountCtrl.add(value);
      emit(FormCotizationItemValidationSuccess());
    } on BaseFormException catch (e) {
      _amountCtrl.add("");
      emit(FormCotizationItemValidationFailed(e.message));
    }
  }

  void updateUnit(String value) {
    try {
      emit(FormCotizationItemValidationLoading());
      FieldValidation(value);
      _unitCtrl.add(value);
      emit(FormCotizationItemValidationSuccess());
    } on BaseFormException catch (e) {
      _unitCtrl.add("");
      emit(FormCotizationItemValidationFailed(e.message));
    }
  }

  void updateUnitValue(String value) {
    try {
      emit(FormCotizationItemValidationLoading());
      CurrencyValidation(value);
      _unitValueCtrl.add(value);
      emit(FormCotizationItemValidationSuccess());
    } on BaseFormException catch (e) {
      _unitValueCtrl.add("");
      emit(FormCotizationItemValidationFailed(e.message));
    }
  }

  Stream<double> get calcTotal {
    return Rx.combineLatest2(amountStream, unitValueStream, (a, b) {
      try {
        NumberValidation(a);
        CurrencyValidation(b);
        return double.parse(a) * CurrencyUtility.currencyToDouble(b);
      } on BaseFormException {
        _totalValueCtrl.done;
        return 0.0;
      }
    });
  }

  Stream<bool> get validateForm {
    return Rx.combineLatest4(
      nameStream,
      unitStream,
      amountStream,
      unitValueStream,
      (a, b, c, d) {
        if (a.isNotEmpty && b.isNotEmpty && c.isNotEmpty && d.isNotEmpty) {
          if (double.parse(c) > 0 && CurrencyUtility.currencyToDouble(d) > 0) {
            return true;
          }
        }
        return false;
      },
    );
  }

  void save() async {
    try {
      emit(FormCotizationItemSaveLoading());
      var item = CotizationItem(
        name: _nameCtrl.value.trim(),
        description: _descCtrl.value.trim(),
        unit: _unitCtrl.value.trim(),
        unitValue: CurrencyUtility.currencyToDouble(_unitValueCtrl.value),
        amount: double.parse(_amountCtrl.value),
      );
      emit(FormCotizationItemSaveSuccess(item, oldItem));
    } catch (e) {
      emit(FormCotizationItemSaveFailed(e.toString()));
    }
  }
}
