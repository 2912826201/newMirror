import 'package:mirror/data/database/db_helper.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:sqflite/sqflite.dart';

/// profile_db_helper
/// Created by yangjiayi on 2020/11/3.

class ProfileDBHelper {
  Future<bool> insertProfile(ProfileDto profile) async {
    // Database db = await DBHelper().openDB();
    //因为此表只存当前用户自己的数据 所以插入数据前先清掉表中所有数据
    var transactionResult = await DBHelper.instance.db.transaction((txn) async {
      //事务中只能用txn不能用db
      await txn.delete(TABLE_NAME_PROFILE);
      var result = await txn.insert(TABLE_NAME_PROFILE, profile.toMap());
      return result;
    });
    // await DBHelper().closeDB(db);
    return transactionResult == 1;
  }

  Future<void> clearProfile() async {
    // Database db = await DBHelper().openDB();
    await DBHelper.instance.db.delete(TABLE_NAME_PROFILE);
    // await DBHelper().closeDB(db);
  }

  Future<ProfileDto> queryProfile(int uid) async {
    // Database db = await DBHelper().openDB();
    ProfileDto profile;
    //只取第一条数据
    List<Map<String, dynamic>> result = await DBHelper.instance.db.query(TABLE_NAME_PROFILE, where: "$COLUMN_NAME_PROFILE_UID = $uid",
        limit: 1);
    if (result.isNotEmpty) {
      profile = ProfileDto.fromMap(result.first);
    }
    // await DBHelper().closeDB(db);
    return profile;
  }
}
