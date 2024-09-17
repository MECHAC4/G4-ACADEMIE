

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class SignUpDataManager {
  late Database signUpDatabase;
  int index = 1;

  Future<Map<String, dynamic>?> initSignDatabase() async {
    signUpDatabase = await openDatabase(
      path.join(await getDatabasesPath(), "sign_up$index.db"),
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE sign_up_info$index(id INTEGER PRIMARY KEY AUTOINCREMENT, "
                "uid TEXT, statut TEXT)");
      },
      version: 1,
    );
    return await _loadSignUpInfo();
  }

  Future<Map<String, dynamic>?> _loadSignUpInfo() async {
    final info = await signUpDatabase.query("sign_up_info$index");
    return info.isNotEmpty ? info.first : null;
  }

  Future<void> saveSignUpInfo(
      String uid,
      String statut,
      ) async {
    signUpDatabase = await openDatabase(
      path.join(await getDatabasesPath(), "sign_up$index.db"),
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE sign_up_info$index(id INTEGER PRIMARY KEY AUTOINCREMENT, "
                "uid TEXT, statut TEXT)");
      },
      version: 1,
    );

    // Check if data exists
    final existingData = await _loadSignUpInfo();
    if (existingData == null) {
      // Insert new data if none exists
      await signUpDatabase.insert(
        "sign_up_info$index",
        {
          "uid": uid,
          "statut": statut,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // Update existing data
      await signUpDatabase.update(
        "sign_up_info$index",
        {
          "uid": uid,
          "statut": statut,
        },
        where: "id = ?",
        whereArgs: [existingData['id']],
      );
    }
  }
}
