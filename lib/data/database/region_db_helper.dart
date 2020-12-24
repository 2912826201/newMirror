import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/region_dto.dart';

import 'db_helper.dart';

/// region_db_helper
/// Created by yangjiayi on 2020/12/24.

class RegionDBHelper {

  Future<List<RegionDto>> queryRegionList() async {

    List<RegionDto> list = [];
    List<Map<String, dynamic>> result = await DBHelper.instance.db.query(TABLE_NAME_REGION);
    for (Map<String, dynamic> map in result) {
      list.add(RegionDto.fromMap(map));
    }

    return list;
  }

}