import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'fetch_liquidations_state.dart';

class FetchLiquidationsCubit extends Cubit<FetchLiquidationsState> {
  final LiquidationService _service;
  final _liquidationsCtrl = BehaviorSubject<List<Liquidation>>();
  Stream<List<Liquidation>> get liquidationStream => _liquidationsCtrl.stream;
  FetchLiquidationsCubit(this._service) : super(FetchLiquidationsInitial());

  Future<void> refresh() async {
    await DelayUtility.delay();
    _liquidationsCtrl.add(await _service.all());
  }

  void resetState() => emit(FetchLiquidationsInitial());

  void fetchLiquidations() async {
    try {
      emit(FetchLiquidationOnLoading());
      await DelayUtility.delay();
      var records = await _service.all();
      if (records.isEmpty) {
        emit(FetchLiquidationOnEmpty());
      } else {
        _liquidationsCtrl.add(records);
        emit(FetchLiquidationOnSuccess());
      }
    } catch (e) {
      emit(FetchLiquidationFailed(e.toString()));
    }
  }

  void saveLiquidation(Liquidation liquidation) async {
    try {
      await _service.save(liquidation);
      emit(FetchLiquidationOnCreateSuccess());
    } catch (e) {
      emit(FetchLiquidationFailed(e.toString()));
    }
  }

  void onCreate() {
    emit(FetchLiquidationOnCreate());
  }
}
