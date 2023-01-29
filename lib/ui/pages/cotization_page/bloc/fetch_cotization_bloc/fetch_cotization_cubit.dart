import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/utilities/delay.utility.dart';
import 'package:equatable/equatable.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

part 'fetch_cotization_state.dart';

class FetchCotizationCubit extends Cubit<FetchCotizationState> {
  final CotizationService service;
  final SharedPreferencesCacheCotizationService cacheService;

  FetchCotizationCubit(this.service, this.cacheService)
      : super(FetchCotizationInitial());

  void resetState() {
    emit(FetchCotizationInitial());
  }

  Future<List<Cotization>> reloadCotization() async {
    var records = await service.all();
    cacheService.setCotizations(records);
    return records;
  }

  void fetchCotizations() async {
    try {
      var records = await cacheService.all();
      if (records.isEmpty) {
        emit(OnFetchCotizationLoading());
        await DelayUtility.delay();
        records = await reloadCotization();
      }
      if (records.isEmpty) {
        emit(OnFetchCotizationEmpty());
      } else {
        emit(OnFetchCotizationSuccess(records));
      }
    } catch (e) {
      emit(OnActionCotizationFailed(e.toString()));
    }
  }

  void saveCotization(Cotization cotization) async {
    try {
      emit(OnActionCotizationLoading());
      await DelayUtility.delay();
      late Cotization res;
      if (cotization.id is int) {
        res = await service.update(cotization);
        await cacheService.update(res);
      } else {
        res = await service.save(cotization);
        await cacheService.save(res);
      }
      emit(OnActionCotizationSuccess(res));
    } catch (e) {
      emit(OnActionCotizationFailed(e.toString()));
    }
  }

  void deleteCotization(Cotization cotization) async {
    try {
      emit(OnActionCotizationLoading());
      await DelayUtility.delay();
      await service.delete(cotization);

      await cacheService.delete(cotization);
      emit(const OnActionCotizationSuccess());
    } catch (e) {
      emit(OnActionCotizationFailed(e.toString()));
    }
  }

  void onEditCotization(Cotization cotization, [bool copy = false]) {
    emit(OnEditCotization(cotization, copy));
  }

  void onCreateCotization() {
    emit(OnCreateCotization());
  }

  void onFinishCotization(Cotization cotization) async {
    var finished = Cotization.finished(cotization);
    saveCotization(finished);
    emit(OnActionCotizationSuccess(finished));
  }

  void exportToPDF(Cotization cotization, PDFCotizationService service) async {
    final document = await service.exportToPDF(cotization);

    var bytes = await document.save();

    document.dispose();

    final path = (await getExternalCacheDirectories())?.first.path;
    if (path is String) {
      var fullpath = "$path/${cotization.name}-cotizacion.pdf";
      await File(fullpath).writeAsBytes(bytes, flush: true);
      await OpenFile.open(fullpath);
    }
  }
}
