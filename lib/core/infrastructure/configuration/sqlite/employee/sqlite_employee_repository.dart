import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/configuration/sqlite/sqlite_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

part 'sqlite_employee_model.dart';

@Injectable(as: EmployeeRepository)
class SQLiteEmployeeRepository implements EmployeeRepository {
  final SQLiteProvider _provider;
  static const table = "employees";
  static const statements = [
    """
  CREATE TABLE $table(
    id INTEGER PRIMARY KEY, 
    firstname TEXT, 
    lastname TEXT, 
    phone TEXT, 
    salary REAL, 
    image BLOB
  )
"""
  ];

  SQLiteEmployeeRepository(this._provider);

  @override
  Future<int> delete(Employee employee) async {
    await _checkOpenDB();
    final db = await _provider.database;
    final int index =
        await db.delete(table, where: "id = ?", whereArgs: [employee.id]);
    await db.close();
    return index;
  }

  @override
  Future<Set<Employee>> employees() async {
    await _checkOpenDB();
    final db = await _provider.database;
    final records = await db.rawQuery(
        "SELECT id, firstname, lastname, phone, salary, image FROM $table");
    await db.close();
    final models = records.map((e) {
      final sqlModel = SQLiteEmployeeModel.fromMap(e);
      return sqlModel.toEmployee();
    }).toSet();
    return models;
  }

  Future<void> _checkOpenDB() async {
    if (!await _provider.isOpen()) {
      await _provider.openDB();
    }
  }

  @override
  Future<Employee?> findById(int id) async {
    await _checkOpenDB();
    final db = await _provider.database;
    final records = await db.query(table, where: "id = ?", whereArgs: [id]);
    db.close();
    if (records.isEmpty) {
      return null;
    }
    final model = (() {
      final sqlModel = SQLiteEmployeeModel.fromMap(records[0]);
      return sqlModel.toEmployee();
    })();

    return model;
  }

  @override
  Future<int> save(Employee employee) async {
    await _checkOpenDB();
    var sqlModel = SQLiteEmployeeModel.fromEmployee(employee);
    final db = await _provider.database;
    int id = await db.insert(table, sqlModel.toMap());
    db.close();
    return id;
  }

  @override
  Future<int> update(Employee employee) async {
    await _checkOpenDB();
    var sqlModel = SQLiteEmployeeModel.fromEmployee(employee);
    final db = await _provider.database;
    final index = await db.update(
      table,
      sqlModel.toMap(),
      where: "id = ?",
      whereArgs: [employee.id],
    );
    db.close();
    return index;
  }
}
