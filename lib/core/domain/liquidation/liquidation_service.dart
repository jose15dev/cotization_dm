part of 'liquidation.dart';

abstract class LiquidationService {
  Future<List<Liquidation>> all();
  Future<List<Liquidation>> findByEmployee(Employee employee);
  Future<Liquidation> save(Liquidation liquidation);
  Future<Liquidation> update(Liquidation liquidation);
  Future<int> delete(Liquidation liquidation);
}

@Injectable(as: LiquidationService)
class DomainLiquidationService implements LiquidationService {
  final LiquidationRepository _repository;

  const DomainLiquidationService(this._repository);

  @override
  Future<List<Liquidation>> all() async {
    return (await _repository.liquidations()).toList();
  }

  @override
  Future<int> delete(Liquidation liquidation) {
    return _repository.delete(liquidation);
  }

  @override
  Future<Liquidation> save(Liquidation liquidation) async {
    int id = await _repository.save(liquidation);
    return Liquidation.withId(liquidation, id);
  }

  @override
  Future<Liquidation> update(Liquidation liquidation) async {
    await _repository.update(liquidation);
    return liquidation;
  }

  @override
  Future<List<Liquidation>> findByEmployee(Employee employee) {
    return _repository.findByEmployeeId(employee.id!);
  }
}
