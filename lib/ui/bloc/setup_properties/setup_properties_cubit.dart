import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/core/infrastructure/configuration/setup.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'setup_properties_state.dart';

class SetupPropertiesCubit extends Cubit<SetupPropertiesState> {
  final _taxtPercentOptionCtrl = BehaviorSubject<TaxPercentOption?>();
  final _locationCtrl = BehaviorSubject<String?>();
  final _nitCtrl = BehaviorSubject<String?>();
  final _businessNameCtrl = BehaviorSubject<String?>();

  Stream<TaxPercentOption?> get taxPercentOptionStream =>
      _taxtPercentOptionCtrl.stream;
  Stream<String?> get locationStream => _locationCtrl.stream;
  Stream<String?> get nitStream => _nitCtrl.stream;
  Stream<String?> get businessNameStream => _businessNameCtrl.stream;

  SetupPropertiesCubit() : super(SetupPropertiesInitial()) {
    _listenCtrl();
    checkProperties.listen((event) {
      if (state is! SetupPropertiesIsOnPreferences) {
        if (!event) {
          emit(SetupPropertiesBlockScreen());
        } else {
          emit(SetupPropertiesAppReady());
        }
      }
    });
  }

  void resetState() {
    emit(SetupPropertiesInitial());
  }

  void navigateToPreferences() {
    emit(SetupPropertiesIsOnPreferences());
  }

  void _listenCtrl() {
    _taxtPercentOptionCtrl.listen((value) {
      if (value != null) AppSetup.setTaxPercentOption(value);
    });
    _locationCtrl.listen((value) {
      if (value != null) AppSetup.setLocation(value.trim());
    });

    _nitCtrl.listen((value) {
      if (value != null) AppSetup.setNIT(value.trim());
    });

    _businessNameCtrl.listen((value) {
      if (value != null) AppSetup.setBusinessName(value.trim());
    });
  }

  void getProperties() {
    _taxtPercentOptionCtrl.add(AppSetup.getTaxPercentOption());
    _locationCtrl.add(AppSetup.getLocation());
    _nitCtrl.add(AppSetup.getNIT());
    _businessNameCtrl.add(AppSetup.getBusinessName());
    resetState();
  }

  void setTaxPercentOption(TaxPercentOption option) {
    _taxtPercentOptionCtrl.add(option);
  }

  void setLocation(String value) {
    _locationCtrl.add(value);
  }

  void setNIT(String nit) {
    _nitCtrl.add(nit);
  }

  void setBusinessName(String value) {
    _businessNameCtrl.add(value);
  }

  Stream<bool> requestStatusProperties() async* {
    yield* checkProperties;
  }

  Stream<bool> get checkProperties => Rx.combineLatest4(
          _taxtPercentOptionCtrl.stream,
          _locationCtrl.stream,
          _businessNameCtrl.stream,
          _nitCtrl.stream, (a, b, c, d) {
        if (a != null && b != null && c != null && d != null) {
          return true;
        }
        return false;
      });
}
