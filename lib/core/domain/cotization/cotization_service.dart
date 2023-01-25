part of 'cotization.dart';

abstract class CotizationService {
  Future<List<Cotization>> all();
  Future<Cotization> findById(int id);
  Future<Cotization> save(Cotization cotization);
  Future<Cotization> update(Cotization cotization);
  Future<int> delete(Cotization cotization);
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
