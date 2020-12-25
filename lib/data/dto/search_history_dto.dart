/// SearchHistoryDto
/// Created by yangjiayi on 2020/12/25.

const String TABLE_NAME_SEARCHHISTORY = "search_history";
const String COLUMN_NAME_SEARCHHISTORY_ID = 'id';
const String COLUMN_NAME_SEARCHHISTORY_UID = 'uid';
const String COLUMN_NAME_SEARCHHISTORY_WORD = 'word';

class SearchHistoryDto {
  int id;
  int uid;
  String word;


  SearchHistoryDto(this.id, this.uid, this.word);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_NAME_SEARCHHISTORY_ID : id,
      COLUMN_NAME_SEARCHHISTORY_UID : uid,
      COLUMN_NAME_SEARCHHISTORY_WORD : word,
    };
    return map;
  }

  SearchHistoryDto.fromMap(Map<String, dynamic> map) {
    id = map[COLUMN_NAME_SEARCHHISTORY_ID];
    uid = map[COLUMN_NAME_SEARCHHISTORY_UID];
    word = map[COLUMN_NAME_SEARCHHISTORY_WORD];
  }
}