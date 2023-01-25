import 'package:cotizacion_dm/ui/utilities/utilities.dart';

class FieldValidation {
  final String _value;

  FieldValidation(this._value) {
    if (_value.isEmpty) {
      throw EmptyValidationException();
    }
  }

  @override
  String toString() => _value;
}

class NumberValidation {
  final String _value;
  NumberValidation(this._value) {
    if (_value.isEmpty) {
      throw EmptyValidationException();
    }
    if (_value.isNotEmpty) {
      try {
        var value = double.parse(_value);
        if (value == 0.0) {
          throw ZeroValidationException();
        }
      } catch (e) {
        throw NumberValidationException();
      }
    }
  }

  @override
  String toString() {
    return _value;
  }
}

class PhoneValidation {
  final String _value;

  PhoneValidation(this._value) {
    if (_value.isEmpty) {
      throw EmptyValidationException();
    }
    if (_value.isNotEmpty && _value.length < 12) {
      throw IncompletePhoneValidationException();
    }
  }

  @override
  String toString() => _value;
}

class CurrencyValidation {
  final String _value;

  CurrencyValidation(this._value) {
    if (_value.isEmpty && _value.length <= 1) {
      throw EmptyValidationException();
    }
    try {
      double format = CurrencyUtility.currencyToDouble(_value);
      if (format == 0) {
        throw ZeroValidationException();
      }
    } catch (e) {
      throw InvalidCurrencyValidationException();
    }
  }

  @override
  String toString() => _value;
}

abstract class BaseFormException implements Exception {
  final String message;

  BaseFormException(this.message);

  @override
  String toString() {
    return message;
  }
}

class InvalidCurrencyValidationException extends BaseFormException {
  InvalidCurrencyValidationException() : super("El valor es invalido");
}

class ZeroValidationException extends BaseFormException {
  ZeroValidationException() : super("El valor no puede ser cero");
}

class NumberValidationException extends BaseFormException {
  NumberValidationException() : super("El valor es invalido");
}

class IncompletePhoneValidationException extends BaseFormException {
  IncompletePhoneValidationException()
      : super("El campo telefonico esta incompleto");
}

class EmptyValidationException extends BaseFormException {
  EmptyValidationException() : super("El campo no puede estar vacio");
}

class CotizationItemExistException extends BaseFormException {
  CotizationItemExistException() : super("Este item ya existe");
}

class CotizationItemNotExistException extends BaseFormException {
  CotizationItemNotExistException() : super("Este item no existe");
}
