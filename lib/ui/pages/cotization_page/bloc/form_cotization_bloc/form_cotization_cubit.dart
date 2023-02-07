import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/exceptions/exceptions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/gestures.dart';
import 'package:rxdart/rxdart.dart';

part 'form_cotization_state.dart';

class FormCotizationCubit extends Cubit<FormCotizationState> {
  int? id;
  final _nameCtrl = BehaviorSubject<String>()..add(""),
      _descCtrl = BehaviorSubject<String>()..add("");
  final _itemsCtrl = BehaviorSubject<List<CotizationItem>>()..add([]);
  final _totalCtrl = BehaviorSubject<double>();
  final _taxCtrl = BehaviorSubject<double?>()..add(null);
  final _colorCtrl = BehaviorSubject<int>();
  final _isAccountCtrl = BehaviorSubject<bool>()..add(false);

  Stream<String> get nameStream => _nameCtrl.stream;
  Stream<String> get descStream => _descCtrl.stream;
  Stream<double> get totalStream => _totalCtrl.stream;
  Stream<List<CotizationItem>> get itemsStream => _itemsCtrl.stream;
  Stream<double?> get taxStream => _taxCtrl.stream;
  Stream<bool> get isAccountStream => _isAccountCtrl.stream;

  FormCotizationCubit() : super(FormCotizationInitial()) {
    _itemsCtrl.listen((value) {
      _totalCtrl.add(value.fold(
          0.0, (previousValue, element) => previousValue + element.total));
    });
  }

  void loadCotization(Cotization cotization, bool onCopy) {
    if (!onCopy) id = cotization.id;
    _nameCtrl.add(cotization.name);
    _descCtrl.add(cotization.description);
    _itemsCtrl.add([...cotization.items]);
    _colorCtrl.add(cotization.color);
    _taxCtrl.add(cotization.tax);
    _isAccountCtrl.add(cotization.isAccount);
    emit(FormOnLoadCotization());
  }

  void resetForm() {
    clearStreams();
    emit(FormCotizationInitial());
  }

  void clearStreams() {
    _nameCtrl.add("");
    _descCtrl.add("");
    _itemsCtrl.add([]);
  }

  void updateName(String value) {
    try {
      FieldValidation(value);
      _nameCtrl.add(value.trim());
    } on BaseFormException catch (e) {
      _nameCtrl.addError(e.toString());
    }
  }

  void updateTax(double? value) {
    _taxCtrl.add(value);
  }

  void updateIsAccount(bool value) {
    _isAccountCtrl.add(value);
  }

  void updateColor(int value) {
    _colorCtrl.add(value);
  }

  void updateDescription(String value) {
    try {
      FieldValidation(value);
      _descCtrl.add(value..trim());
    } on BaseFormException catch (e) {
      _descCtrl.addError(e.toString());
    }
  }

  void onAddNewItem() => emit(OnAddNewItem());

  void resetState() => emit(FormCotizationInitial());

  void updateItem(CotizationItem oldItem, CotizationItem newItem) {
    try {
      emit(ActionItemLoading());

      if (_itemsCtrl.hasValue) {
        var items = _itemsCtrl.value;
        if (items.contains(oldItem)) {
          var index = items.indexOf(oldItem);
          items[index] = newItem;
          _itemsCtrl.add([...items]);
        }
      } else {
        throw CotizationItemNotExistException();
      }
      emit(ActionItemSuccess());
    } catch (e) {
      emit(ActionItemFailed(e.toString()));
    }
  }

  void addItem(CotizationItem item) async {
    try {
      emit(ActionItemLoading());
      if (_itemsCtrl.hasValue) {
        var items = _itemsCtrl.value;
        if (items.contains(item)) {
          throw CotizationItemExistException();
        } else {
          items.add(item);
        }
        _itemsCtrl.add([...items]);
      } else {
        _itemsCtrl.add([item]);
      }
      emit(ActionItemSuccess());
    } catch (e) {
      emit(ActionItemFailed(e.toString()));
    }
  }

  void removeItem(CotizationItem item) async {
    try {
      emit(ActionItemLoading());
      var items = _itemsCtrl.value;
      if (items.contains(item)) {
        items.remove(item);
      } else {
        throw CotizationItemNotExistException();
      }

      _itemsCtrl.add([...items]);

      emit(ActionItemSuccess());
    } catch (e) {
      emit(ActionItemFailed(e.toString()));
    }
  }

  void onEditItem(CotizationItem item, Offset position) {
    emit(FormOnEditItem(item, position: position));
  }

  void onCopyItem(CotizationItem item, Offset position) {
    emit(FormOnEditItem(item, copy: true, position: position));
  }

  void onMoveUp(CotizationItem item) {
    try {
      emit(ActionItemLoading());
      if (_itemsCtrl.hasValue) {
        var items = _itemsCtrl.value;
        if (items.contains(item)) {
          var index = items.indexOf(item);
          var beforeIndex = index - 1;
          var beforeItem = items.elementAt(beforeIndex);
          items.removeAt(index);
          items.removeAt(beforeIndex);
          items.insert(beforeIndex, item);
          items.insert(index, beforeItem);

          _itemsCtrl.add([...items]);
        }
      }
      emit(ActionItemSuccess());
    } on RangeError catch (e) {
      emit(const ActionItemFailed("No se puede mover hacia arriba"));
    } on Exception catch (e) {
      emit(ActionItemFailed(e.toString()));
    }
  }

  void onMoveDown(CotizationItem item) {
    try {
      emit(ActionItemLoading());
      if (_itemsCtrl.hasValue) {
        var items = _itemsCtrl.value;
        if (items.contains(item)) {
          var index = items.indexOf(item);
          var afterIndex = index + 1;
          var afterItem = items.elementAt(afterIndex);
          items.removeAt(index);
          items.insert(index, afterItem);
          items.removeAt(afterIndex);
          items.insert(afterIndex, item);
          _itemsCtrl.add([...items]);
        }
      }
      emit(ActionItemSuccess());
    } on RangeError catch (e) {
      emit(const ActionItemFailed("No se puede mover hacia abajo"));
    } on Exception catch (e) {
      emit(ActionItemFailed(e.toString()));
    }
  }

  Stream<Cotization> get cotizationStream => Rx.combineLatest6(
          _nameCtrl.stream,
          _descCtrl.stream,
          _itemsCtrl.stream,
          _colorCtrl.stream,
          _taxCtrl.stream,
          _isAccountCtrl.stream, (a, b, c, d, e, f) {
        return Cotization(
          id: id,
          name: a.isEmpty ? "Cotización sin nombre" : a,
          description: b.isEmpty ? "Sin descripción" : b,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          items: c,
          color: d,
          tax: e,
          isAccount: f,
        );
      });

  Stream<bool> get validateForm =>
      Rx.combineLatest4(nameStream, itemsStream, taxStream, _colorCtrl.stream,
          (a, b, c, d) {
        if (a.isNotEmpty && b.isNotEmpty) {
          return true;
        }
        return false;
      });

  void tryToSave() {
    emit(FormOnSaveCotizationLoading());
  }

  void save([bool finish = false]) async {
    try {
      var cotization = Cotization(
        id: id,
        items: _itemsCtrl.value,
        name: _nameCtrl.value.trim(),
        description: _descCtrl.value.trim(),
        color: _colorCtrl.value,
        tax: _taxCtrl.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isAccount: _isAccountCtrl.value,
      );

      emit(FormOnSaveCotizationSuccess(cotization));
    } catch (e) {
      emit(FormOnSaveCotizationFailed(e.toString()));
    }
  }
}
