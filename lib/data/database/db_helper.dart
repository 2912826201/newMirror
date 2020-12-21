import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:sqflite/sqflite.dart';

/// db_helper
/// Created by yangjiayi on 2020/11/3.

// 数据库名 暂时只会用到一个库
const String _DB_NAME = "mirror.db";
// 数据库版本 从1开始
const int _DB_VERSION = 1;

//TODO 需要考虑是否需要单例，每次操作都要开关DB是否必要
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
  await db.execute("create table $TABLE_NAME_PROFILE (" +
      "$COLUMN_NAME_PROFILE_UID bigint(20) primary key," +
      "$COLUMN_NAME_PROFILE_PHONE varchar(16)," +
      "$COLUMN_NAME_PROFILE_TYPE tinyint(1)," +
      "$COLUMN_NAME_PROFILE_PASSWORD varchar(128)," +
      "$COLUMN_NAME_PROFILE_NICKNAME varchar(64)," +
      "$COLUMN_NAME_PROFILE_AVATARURI varchar(256)," +
      "$COLUMN_NAME_PROFILE_DESCRIPTION varchar(128)," +
      "$COLUMN_NAME_PROFILE_BIRTHDAY varchar(16)," +
      "$COLUMN_NAME_PROFILE_SEX tinyint(1)," +
      "$COLUMN_NAME_PROFILE_CONSTELLATION varchar(32)," +
      "$COLUMN_NAME_PROFILE_ADDRESS varchar(64)," +
      "$COLUMN_NAME_PROFILE_SOURCE varchar(2048)," +
      "$COLUMN_NAME_PROFILE_CREATETIME bigint(20)," +
      "$COLUMN_NAME_PROFILE_UPDATETIME bigint(20)," +
      "$COLUMN_NAME_PROFILE_DELETEDTIME bigint(20)," +
      "$COLUMN_NAME_PROFILE_STATUS tinyint(1)," +
      "$COLUMN_NAME_PROFILE_AGE smallint(1)," +
      "$COLUMN_NAME_PROFILE_SUBTYPE tinyint(1)," +
      "$COLUMN_NAME_PROFILE_CITYCODE varchar(16)," +
      "$COLUMN_NAME_PROFILE_LONGITUDE decimal(10,6)," +
      "$COLUMN_NAME_PROFILE_LATITUDE decimal(10,6)," +

      "$COLUMN_NAME_PROFILE_ISPERFECT tinyint(1)," +
      "$COLUMN_NAME_PROFILE_ISPHONE tinyint(1)," +

      "$COLUMN_NAME_PROFILE_RELATION tinyint(1)," +
      "$COLUMN_NAME_PROFILE_MUTUALFRIENDCOUNT int" +
          ")");
  //token
  await db.execute("create table $TABLE_NAME_TOKEN (" +
      "$COLUMN_NAME_TOKEN_ACCESSTOKEN varchar(1024) primary key," +
      "$COLUMN_NAME_TOKEN_TOKENTYPE varchar(32)," +
      "$COLUMN_NAME_TOKEN_REFRESHTOKEN varchar(1024)," +
      "$COLUMN_NAME_TOKEN_EXPIRESIN bigint(20)," +
      "$COLUMN_NAME_TOKEN_SCOPE varchar(256)," +
      "$COLUMN_NAME_TOKEN_ISPERFECT tinyint(1)," +
      "$COLUMN_NAME_TOKEN_UID bigint(20)," +
      "$COLUMN_NAME_TOKEN_ANONYMOUS tinyint(1)," +
      "$COLUMN_NAME_TOKEN_ISPHONE tinyint(1)," +
      "$COLUMN_NAME_TOKEN_JTI varchar(128)," +
      "$COLUMN_NAME_TOKEN_CREATETIME bigint(20)" +
          ")");
  //conversation
  await db.execute("create table $TABLE_NAME_CONVERSATION (" +
      "$COLUMN_NAME_CONVERSATION_ID varchar(64) primary key," +
      "$COLUMN_NAME_CONVERSATION_CONVERSATIONID varchar(32)," +
      "$COLUMN_NAME_CONVERSATION_UID bigint(20)," +
      "$COLUMN_NAME_CONVERSATION_TYPE tinyint(1)," +
      "$COLUMN_NAME_CONVERSATION_AVATARURI varchar(512)," +
      "$COLUMN_NAME_CONVERSATION_NAME varchar(128)," +
      "$COLUMN_NAME_CONVERSATION_CONTENT varchar(256)," +
      "$COLUMN_NAME_CONVERSATION_UPDATETIME bigint(20)," +
      "$COLUMN_NAME_CONVERSATION_CREATETIME bigint(20)," +
      "$COLUMN_NAME_CONVERSATION_ISTOP tinyint(1)," +
      "$COLUMN_NAME_CONVERSATION_UNREADCOUNT int"+
          ")");
}

Future<void> _updateDB(Database db, int oldVersion, int newVersion) async {}
