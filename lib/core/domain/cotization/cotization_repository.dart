part of 'cotization.dart';

abstract class CotizationRepository {
  Future<List<Cotization>> cotizations();

  Future<Cotization?> findById(int id);

  Future<int> save(Cotization cotization);

  Future<int> delete(Cotization cotization);

  Future<int> update(Cotization cotization);
}
