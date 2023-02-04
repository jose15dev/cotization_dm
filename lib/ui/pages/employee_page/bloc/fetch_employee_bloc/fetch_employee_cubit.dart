import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'fetch_employee_state.dart';

class FetchEmployeeCubit extends Cubit<FetchEmployeeState> {
  final EmployeeService _service;
  final SharedPreferencesCacheEmployeeService _cacheService;

  FetchEmployeeCubit(this._service, this._cacheService)
      : super(FetchEmployeeInitial());

  void resetState() {
    emit(FetchEmployeeInitial());
  }

  Future<List<Employee>> reloadEmployees() async {
    var records = (await _service.all()).toList();
    _cacheService.setEmployees(records);
    return records;
  }

  Future<void> fetchEmployees() async {
    try {
      List<Employee> records = await _cacheService.all();
      if (records.isEmpty) {
        emit(OnFetchEmployeeLoading());
        await DelayUtility.delay();
        records = await reloadEmployees();
      }
      if (records.isEmpty) {
        emit(OnFetchEmployeeEmpty());
      }
      if (records.isNotEmpty) {
        emit(OnFetchEmployeeSuccess(records));
      }
    } catch (e) {
      emit(OnActionEmployeeFailed(e.toString()));
    }
  }

  Future<void> deleteEmployee(Employee employee) async {
    try {
      emit(OnActionEmployeeLoading());
      await _service.delete(employee);
      await _cacheService.delete(employee);
      emit(OnActionEmployeeSuccess());
    } catch (e) {
      emit(OnActionEmployeeFailed(e.toString()));
    }
  }

  Future<void> saveEmployee(Employee employee) async {
    try {
      emit(OnActionEmployeeLoading());
      if (employee.id is int) {
        var res = await _service.update(employee);
        await _cacheService.update(employee);
        emit(OnUpdateEmployeeSuccess(res));
      } else {
        var res = await _service.save(employee);
        await _cacheService.save(res);
        emit(OnActionEmployeeSuccess());
      }
    } catch (e) {
      emit(OnActionEmployeeFailed(e.toString()));
    }
  }
}
