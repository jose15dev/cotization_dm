import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:injectable/injectable.dart';

part 'sqlite_liquidation_model.dart';

@Injectable(as: LiquidationRepository)
class SQLiteLiquidationRepository implements LiquidationRepository {
  final SQLiteProvider _provider;
  static const table = "liquidations";
  static const statements = [
    """
  CREATE TABLE $table(
    id INTEGER PRIMARY KEY, 
    days INTEGER NOT NULL,
    real_price REAL NOT NULL,
    fk_employee_id INTEGER NOT NULL,
    created_at INTEGER NOT NULL,

    FOREIGN KEY(fk_employee_id) REFERENCES ${SQLiteEmployeeRepository.table}(id)
  );
"""
  ];

  SQLiteLiquidationRepository(this._provider);

  @override
  Future<int> delete(Liquidation liquidation) async {
    await _checkOpenDB();
    final db = await _provider.database;
    final int index =
        await db.delete(table, where: "id = ?", whereArgs: [liquidation.id]);
    await db.close();
    return index;
  }

  @override
  Future<List<Liquidation>> liquidations() async {
    await _checkOpenDB();
    final db = await _provider.database;
    final records = [...(await db.query(table))];
    for (int i = 0; i < records.length; i++) {
      var record = records[i];
      record = {
        ...record,
        "employee": (await db.query(SQLiteEmployeeRepository.table,
            where: "id = ?", whereArgs: [record["fk_employee_id"]]))[0]
      };
      records.removeAt(i);
      records.insert(i, record);
    }
    await db.close();

    return records
        .map((e) => SQLiteLiquidationModel.fromMap(e).toLiquidation())
        .toList();
  }

  Future<void> _checkOpenDB() async {
    if (!await _provider.isOpen()) {
      await _provider.openDB();
    }
  }

  @override
  Future<int> save(Liquidation liquidation) async {
    await _checkOpenDB();
    final db = await _provider.database;
    int id = await db.transaction((txn) async {
      var sqlModel = SQLiteLiquidationModel.fromLiquidation(liquidation);
      var id = await txn.insert(table, sqlModel.toMap());
      return id;
    });
    db.close();
    return id;
  }

  @override
  Future<int> update(Liquidation liquidation) async {
    await _checkOpenDB();
    final db = await _provider.database;
    await db.transaction((txn) async {
      var sqlModel = SQLiteLiquidationModel.fromLiquidation(liquidation);
      var id = await txn.update(table, sqlModel.toMap(),
          where: "id = ?", whereArgs: [liquidation.id]);
    });
    db.close();
    return liquidation.id ?? 0;
  }

  @override
  Future<List<Liquidation>> findByEmployeeId(int id) async {
    await _checkOpenDB();
    final db = await _provider.database;
    final records = [
      ...(await db.query(table, where: "fk_employee_id = ?", whereArgs: [id]))
    ];
    for (int i = 0; i < records.length; i++) {
      var record = records[i];
      record = {
        ...record,
        "employee": (await db.query(SQLiteEmployeeRepository.table,
            where: "id = ?", whereArgs: [record["fk_employee_id"]]))[0]
      };
      records.removeAt(i);
      records.insert(i, record);
    }
    await db.close();

    return records
        .map((e) => SQLiteLiquidationModel.fromMap(e).toLiquidation())
        .toList();
  }
}
