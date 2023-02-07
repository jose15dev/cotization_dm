import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/utilities/delay.utility.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

part 'fetch_cotization_state.dart';

class FetchCotizationCubit extends Cubit<FetchCotizationState> {
  final CotizationService service;
  final SharedPreferencesCacheCotizationService cacheService;
  final QueryCotizationService queryService;

  final BehaviorSubject<List<Cotization>> _cotizations =
      BehaviorSubject<List<Cotization>>();

  FetchCotizationCubit(this.service, this.cacheService, this.queryService)
      : super(FetchCotizationInitial()) {
    _cotizations.listen((value) {
      listenerFilterOptions();
    });
  }

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
        records = await reloadCotization();
      }
      _cotizations.add(records);
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
        res = await service.update(Cotization.update(cotization));
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
      var delete = Cotization.delete(cotization);
      await service.update(delete);

      await cacheService.update(delete);
      emit(const OnActionCotizationSuccess());
    } catch (e) {
      emit(OnActionCotizationFailed(e.toString()));
    }
  }

  void restoreCotization(Cotization cotization) async {
    try {
      emit(OnActionCotizationLoading());
      await DelayUtility.delay();
      var delete = Cotization.restore(cotization);
      await service.update(delete);

      await cacheService.update(delete);
      emit(const OnActionCotizationSuccess());
    } catch (e) {
      emit(OnActionCotizationFailed(e.toString()));
    }
  }

  void forceDeleteCotization(Cotization cotization) async {
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

  // Ordering and filtering
  List<
      List<Cotization> Function(
          List<Cotization> cotizations)> get orderingCallBacks => [
        (cotizations) => cotizations,
        // Last changes
        (cotizations) =>
            queryService.orderByLastUpdated(cotizations: cotizations),
        // Created at
        (cotizations) => queryService.orderByCreateAt(cotizations: cotizations),

        // Alphabetically
        (cotizations) => queryService.orderByName(cotizations: cotizations),
        // Costo
        (cotizations) => queryService.orderByPrice(cotizations: cotizations),
        // Finished
        (cotizations) => queryService.getOnlyFinished(cotizations: cotizations),
// Not Finished
        (cotizations) =>
            queryService.getOnlyNotFinished(cotizations: cotizations),
        // Deleted
        (cotizations) => queryService.getOnlyDeleted(cotizations: cotizations),
// Deleted
        (cotizations) =>
            queryService.getOnlyNotDeleted(cotizations: cotizations),
        // With Tax
        (cotizations) => queryService.getOnlyWithTax(cotizations: cotizations),
        // Without Tax
        (cotizations) =>
            queryService.getOnlyWithoutTax(cotizations: cotizations),
        // Cotizations
        (cotizations) =>
            queryService.getOnlyNotAccounts(cotizations: cotizations),
        // Accounts
        (cotizations) => queryService.getOnlyAccounts(cotizations: cotizations),
      ];

  final List<BehaviorSubject<bool>> orderingOptionStreams =
      List.generate(14, (index) => BehaviorSubject<bool>()..add(false));

  List<FilterOption> get orderingOptions => [
        FilterOption(
          isOrdering: true,
          title: 'Quitar filtros',
          icon: FontAwesomeIcons.filterCircleXmark,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(false);
            for (var element in orderingOptionStreams) {
              element.add(false);
            }
          },
        ),
        FilterOption(
          isOrdering: true,
          title: 'Cambios recientes',
          icon: FontAwesomeIcons.repeat,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
        FilterOption(
          isOrdering: true,
          title: 'Creación',
          icon: FontAwesomeIcons.calendarDay,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
        FilterOption(
          isOrdering: true,
          title: 'Alfabeto',
          icon: FontAwesomeIcons.arrowDownAZ,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
        FilterOption(
          isOrdering: true,
          title: 'Costo',
          icon: FontAwesomeIcons.arrowDownShortWide,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
        FilterOption(
          title: 'No Entregadas',
          icon: FontAwesomeIcons.handshakeSlash,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
        FilterOption(
          title: 'Entregadas',
          icon: FontAwesomeIcons.handshake,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
        FilterOption(
          title: 'Eliminadas',
          icon: FontAwesomeIcons.eye,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
        FilterOption(
          title: 'No Eliminadas',
          icon: FontAwesomeIcons.eyeSlash,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
        FilterOption(
          title: 'IVA',
          icon: FontAwesomeIcons.handHoldingDollar,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
        FilterOption(
          title: 'Sin IVA',
          icon: FontAwesomeIcons.handHoldingDroplet,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
        FilterOption(
          title: 'Cotización',
          icon: FontAwesomeIcons.listCheck,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
        FilterOption(
          title: 'Cuenta de cobro',
          icon: FontAwesomeIcons.fileInvoiceDollar,
          onTap: (int index, bool value) {
            var stream = orderingOptionStreams[index];
            stream.add(value);
          },
        ),
      ];

  void listenerFilterOptions() {
    Rx.combineLatest(orderingOptionStreams, (values) {
      var filteredList = _cotizations.value;

      var hasFilters = values.reduce((value, element) => value || element);
      if (hasFilters) {
        for (var i = 0; i < values.length; i++) {
          if (values[i] == true) {
            filteredList = orderingCallBacks[i](filteredList);
          }
        }
      } else {
        filteredList =
            queryService.getOnlyNotDeleted(cotizations: _cotizations.value);
      }
      return filteredList;
    }).listen((event) {
      emit(OnFetchCotizationLoading());
      DelayUtility.delay().then((value) {
        if (event.isNotEmpty) {
          emit(OnFetchCotizationSuccess(event));
        } else {
          emit(OnFetchCotizationEmpty());
        }
      });
    });
  }
}

class FilterOption extends Equatable {
  final String title;
  final IconData icon;
  final bool isOrdering;
  final Function(int index, bool value) onTap;

  const FilterOption({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isOrdering = false,
  });

  @override
  List<Object?> get props => [title];
}
