part of 'cotization.dart';

abstract class CotizationService {
  Future<List<Cotization>> all();
  Future<Cotization> findById(int id);
  Future<Cotization> save(Cotization cotization);
  Future<Cotization> update(Cotization cotization);
  Future<int> delete(Cotization cotization);
}

abstract class QueryCotizationService {
  List<Cotization> orderByLastUpdated({required List<Cotization> cotizations});
  List<Cotization> orderByName({required List<Cotization> cotizations});
  List<Cotization> orderByCreateAt({required List<Cotization> cotizations});
  List<Cotization> orderByPrice({required List<Cotization> cotizations});
  List<Cotization> getOnlyWithTax({required List<Cotization> cotizations});
  List<Cotization> getOnlyWithoutTax({required List<Cotization> cotizations});
  List<Cotization> getOnlyFinished({required List<Cotization> cotizations});
  List<Cotization> getOnlyNotFinished({required List<Cotization> cotizations});
  List<Cotization> getOnlyNotDeleted({required List<Cotization> cotizations});
  List<Cotization> getOnlyDeleted({required List<Cotization> cotizations});
  List<Cotization> getOnlyAccounts({required List<Cotization> cotizations});
  List<Cotization> getOnlyNotAccounts({required List<Cotization> cotizations});
}

@Injectable(as: CotizationService)
class DomainCotizationService implements CotizationService {
  final CotizationRepository _repository;

  const DomainCotizationService(this._repository);

  @override
  Future<List<Cotization>> all() {
    return _repository.cotizations();
  }

  @override
  Future<int> delete(Cotization cotization) {
    return _repository.delete(cotization);
  }

  @override
  Future<Cotization> findById(int id) async {
    var cotization = await _repository.findById(id);
    if (cotization != null) {
      return cotization;
    } else {
      throw Exception("No existe");
    }
  }

  @override
  Future<Cotization> save(Cotization cotization) async {
    int id = await _repository.save(cotization);
    var res = await findById(id);
    return res;
  }

  @override
  Future<Cotization> update(Cotization cotization) async {
    var id = await _repository.update(cotization);
    var res = await findById(id);
    return res;
  }
}

@Injectable(as: QueryCotizationService)
class DomainQueryCotizationService implements QueryCotizationService {
  @override
  List<Cotization> getOnlyAccounts({required List<Cotization> cotizations}) {
    return cotizations.where((cotization) => cotization.isAccount).toList();
  }

  @override
  List<Cotization> getOnlyDeleted({required List<Cotization> cotizations}) {
    return cotizations
        .where((cotization) => cotization.deletedAt != null)
        .toList();
  }

  @override
  List<Cotization> getOnlyFinished({required List<Cotization> cotizations}) {
    return cotizations.where((element) => element.finished != null).toList();
  }

  @override
  List<Cotization> getOnlyNotAccounts({required List<Cotization> cotizations}) {
    return cotizations.where((cotization) => !cotization.isAccount).toList();
  }

  @override
  List<Cotization> getOnlyNotDeleted({required List<Cotization> cotizations}) {
    return cotizations
        .where((cotization) => cotization.deletedAt == null)
        .toList();
  }

  @override
  List<Cotization> getOnlyNotFinished({required List<Cotization> cotizations}) {
    return cotizations.where((element) => element.finished == null).toList();
  }

  @override
  List<Cotization> getOnlyWithTax({required List<Cotization> cotizations}) {
    return cotizations.where((cotization) => cotization.tax != null).toList();
  }

  @override
  List<Cotization> orderByCreateAt({required List<Cotization> cotizations}) {
    return [...cotizations]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  List<Cotization> orderByLastUpdated({required List<Cotization> cotizations}) {
    return [...cotizations]..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
  }

  @override
  List<Cotization> orderByName({required List<Cotization> cotizations}) {
    return [...cotizations]..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  List<Cotization> orderByPrice({required List<Cotization> cotizations}) {
    return [...cotizations]..sort((a, b) => a.total.compareTo(b.total));
  }

  @override
  List<Cotization> getOnlyWithoutTax({required List<Cotization> cotizations}) {
    return cotizations.where((cotization) => cotization.tax == null).toList();
  }
}
