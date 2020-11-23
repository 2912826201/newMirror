import 'package:sqflite/sqflite.dart';

/// db_helper
/// Created by yangjiayi on 2020/11/3.

// 数据库名 暂时只会用到一个库
const String _DB_NAME = "mirror.db";
// 数据库版本 从1开始
const int _DB_VERSION = 1;

class DBHelper {
  Future<Database> openDB() async {
    return await openDatabase(_DB_NAME, version: _DB_VERSION,
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
      print("数据库需要更新：${oldVersion}=>${newVersion}");
      await _updateDB(db, oldVersion, newVersion);
    }, onCreate: (Database db, int version) async {
      print("数据库创建：${version}");
      await _createDB(db, version);
    });
  }

  Future<void> closeDB(Database db) async {
    return await db.close();
  }
}

//TODO 创建数据库的方法需要根据需要写好
Future<void> _createDB(Database db, int version) async {
  //profile
  await db.execute("create table profile (" +
      "uid bigint(20) primary key," +
      "userName varchar(128) not null," +
      "avatarUri varchar(256) not null)");
  //token
  await db.execute("create table token (" +
      "accessToken varchar(1024) primary key," +
      "tokenType varchar(32)," +
      "refreshToken varchar(1024)," +
      "expiresIn bigint(20)," +
      "scope varchar(256)," +
      "isPerfect tinyint(1)," +
      "uid bigint(20)," +
      "anonymous tinyint(1)," +
      "isPhone tinyint(1)," +
      "jti varchar(128)," +
      "createTime bigint(20))");
}

Future<void> _updateDB(Database db, int oldVersion, int newVersion) async {}
