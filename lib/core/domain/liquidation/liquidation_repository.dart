part of 'liquidation.dart';

abstract class LiquidationRepository {
  Future<List<Liquidation>> liquidations();

  Future<List<Liquidation>> findByEmployeeId(int id);

  Future<int> save(Liquidation liquidation);

  Future<int> delete(Liquidation liquidation);

  Future<int> update(Liquidation liquidation);
}
