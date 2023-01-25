import 'package:cotizacion_dm/core/infrastructure/configuration/sqlite/sqlite.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import 'employee/sqlite_employee_repository.dart';
import 'cotization/sqlite_cotization_repository.dart';

abstract class SQLiteProvider {
  static const String fullpath = "cotization_dm.db";
  Future<bool> isOpen();
  Future<Database> get database;
  Future<Database> createDB();
  Future<Database> openDB();
  Future<void> closeDB();
  Future<void> dropDB();
}

@Injectable(as: SQLiteProvider)
class MainSQLiteProvider implements SQLiteProvider {
  Database? _database;
  @override
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    return createDB();
  }

  @override
  Future<bool> isOpen() async {
    final db = await database;
    return db.isOpen;
  }

  @override
  Future<Database> createDB() async {
    return openDatabase(
      SQLiteProvider.fullpath,
      version: 1,
      onCreate: (Database db, int version) async {
        for (int i = 0; i < SQLiteEmployeeRepository.statements.length; i++) {
          await db.execute(SQLiteEmployeeRepository.statements[i]);
        }
        for (int i = 0; i < SQLiteCotizationRepository.statements.length; i++) {
          await db.execute(SQLiteCotizationRepository.statements[i]);
        }
        for (int i = 0;
            i < SQLiteLiquidationRepository.statements.length;
            i++) {
          await db.execute(SQLiteLiquidationRepository.statements[i]);
        }
      },
    );
  }

  @override
  Future<Database> openDB() async {
    return await openDatabase(
      SQLiteProvider.fullpath,
      version: 1,
      onOpen: (db) {},
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys=ON');
      },
    );
  }

  @override
  Future<void> closeDB() async {
    final db = await database;
    await db.close();
  }

  @override
  Future<void> dropDB() async {
    await deleteDatabase(SQLiteProvider.fullpath);
  }
}
