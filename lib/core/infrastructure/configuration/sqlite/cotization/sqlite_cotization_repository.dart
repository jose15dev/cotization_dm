import 'package:cotizacion_dm/core/domain/cotization/cotization.dart';
import 'package:cotizacion_dm/core/infrastructure/configuration/sqlite/sqlite_provider.dart';
import 'package:injectable/injectable.dart';

part 'sqlite_cotization_model.dart';

@Injectable(as: CotizationRepository)
class SQLiteCotizationRepository extends CotizationRepository {
  final SQLiteProvider _provider;
  static const table = "cotizations";
  static const foreignTable = "cotization_items";
  static const statements = [
    """
  CREATE TABLE $table(
    id INTEGER PRIMARY KEY, 
    name TEXT NOT NULL, 
    description TEXT,
    color INTEGER NOT NULL,
    is_account INTEGER NOT NULL,
    tax REAL,
    finished  INTEGER NOT NULL
  )
  """,
    """
  CREATE TABLE $foreignTable(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    unit TEXT NOT NULL,
    unit_value REAL NOT NULL,
    amount REAL NOT NULL,
    fk_cotization_id INTEGER NOT NULL,
  
    FOREIGN KEY(fk_cotization_id) REFERENCES $table(id)
  )
  """
  ];

  SQLiteCotizationRepository(this._provider);
  @override
  Future<List<Cotization>> cotizations() async {
    await _checkOpenDB();
    final db = await _provider.database;
    var records = <Map<String, Object?>>[]..addAll(await db.query(table));
    for (int i = 0; i < records.length; i++) {
      var sqlItems = await db.query(
        foreignTable,
        where: "fk_cotization_id = ?",
        whereArgs: [records[i]['id']],
      );
      var record = <String, Object?>{}
        ..addAll(records[i])
        ..addAll({
          "items": sqlItems,
        });
      records.removeAt(i);
      records.insert(i, record);
    }

    final models =
        records.map(((e) => SQLiteCotizationModel.fromMap(e))).toList();

    db.close();
    return models.map((e) => e.toCotization()).toList();
  }

  @override
  Future<int> delete(Cotization cotization) async {
    await _checkOpenDB();
    final db = await _provider.database;
    final index = await db.transaction((txn) async {
      await txn.delete(foreignTable,
          where: "fk_cotization_id = ?", whereArgs: [cotization.id]);
      var index =
          await txn.delete(table, where: "id = ?", whereArgs: [cotization.id]);
      return index;
    });
    await db.close();
    return index;
  }

  @override
  Future<Cotization?> findById(int id) async {
    await _checkOpenDB();
    final db = await _provider.database;

    final model = await (() async {
      final records = await db.query(table, where: "id = ?", whereArgs: [id]);
      if (records.isEmpty) {
        return null;
      }

      var sqlItems = await db
          .query(foreignTable, where: "fk_cotization_id = ?", whereArgs: [id]);

      var newModel = <String, Object?>{}
        ..addAll(records.first)
        ..addAll({
          "items": sqlItems,
        });
      return newModel;
    })();
    await db.close();

    if (model is Map<String, Object?>) {
      return SQLiteCotizationModel.fromMap(model).toCotization();
    }
    return null;
  }

  @override
  Future<int> save(Cotization cotization) async {
    await _checkOpenDB();
    var sqlModel = SQLiteCotizationModel.fromCotization(cotization);
    final db = await _provider.database;
    int index = await db.transaction((txn) async {
      int id = await txn.insert(table, sqlModel.toMap());
      var items = sqlModel.items;
      for (int i = 0; i < items.length; i++) {
        var map = items[i].toMap()
          ..addAll({
            "fk_cotization_id": id,
          });
        await txn.insert(foreignTable, map);
      }
      return id;
    });

    await db.close();
    return index;
  }

  @override
  Future<int> update(Cotization cotization) async {
    await _checkOpenDB();
    var sqlModel = SQLiteCotizationModel.fromCotization(cotization);
    final db = await _provider.database;
    await db.transaction((txn) async {
      await txn.delete(foreignTable,
          where: "fk_cotization_id = ?", whereArgs: [cotization.id]);

      var items = sqlModel.items;
      for (int i = 0; i < items.length; i++) {
        var map = items[i].toMap()
          ..addAll({
            "fk_cotization_id": cotization.id,
          });
        await txn.insert(foreignTable, map);
      }
      await txn.update(
        table,
        sqlModel.toMap(),
        where: "id = ?",
        whereArgs: [cotization.id],
      );
    });

    await db.close();
    return cotization.id!;
  }

  Future<void> _checkOpenDB() async {
    if (!await _provider.isOpen()) {
      await _provider.openDB();
    }
  }
}
