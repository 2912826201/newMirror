import 'package:flutter/material.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/util/event_bus.dart';

/// conversation_notifier
/// Created by yangjiayi on 2020/12/21.

class ConversationNotifier with ChangeNotifier {
  //置顶
  List<String> _topIdList = [];

  //非置顶
  List<String> _commonIdList = [];

  List<String> get chatIdList => _commonIdList + _topIdList;

  Map<String, ConversationDto> _conversationMap = {};

  int get topListLength => _topIdList.length;

  int get commonListLength => _commonIdList.length;

  int get allListLength => _topIdList.length + _commonIdList.length;

  ConversationDto getConversationInTopList(int index) => _conversationMap[_topIdList[index]];

  ConversationDto getConversationInCommonList(int index) => _conversationMap[_commonIdList[index]];

  ConversationDto getConversationInAllList(int index) {
    if (index < _topIdList.length) {
      return _conversationMap[_topIdList[index]];
    } else {
      return _conversationMap[_commonIdList[index - _topIdList.length]];
    }
  }

  ConversationDto getConversationById(String id) => _conversationMap[id];

  clearAllData() {
    _topIdList.clear();
    _commonIdList.clear();
    _conversationMap.clear();

    _notifyListeners();
  }

  insertTopList(List<ConversationDto> topList) {
    for (ConversationDto dto in topList) {
      //为确保不重复添加 先删除一下 并且插在第一位 后进的排在前面
      _topIdList.remove(dto.id);
      _commonIdList.remove(dto.id);
      _topIdList.insert(0, dto.id);
      _conversationMap[dto.id] = dto;
    }

    _notifyListeners();
  }

  insertTop(ConversationDto dto) {
    //为确保不重复添加 先删除一下 并且插在第一位 后进的排在前面
    _topIdList.remove(dto.id);
    _commonIdList.remove(dto.id);
    _topIdList.insert(0, dto.id);
    if (_conversationMap[dto.id] == null) {
      _conversationMap[dto.id] = dto;
    } else {
      _conversationMap[dto.id].isTop = 1;
    }
    ConversationDBHelper().updateConversation(_conversationMap[dto.id]);
    _notifyListeners();
  }



  insertCommonList(List<ConversationDto> commonList) {
    for (ConversationDto dto in commonList) {
      //为确保不重复添加 先删除一下 并且插在第一位 后进的排在前面
      _commonIdList.remove(dto.id);
      _topIdList.remove(dto.id);
      _commonIdList.insert(0, dto.id);
      _conversationMap[dto.id] = dto;
    }

    _notifyListeners();
  }


  insertCommon(ConversationDto dto) {
    //为确保不重复添加 先删除一下 并且插在第一位 后进的排在前面
    _commonIdList.remove(dto.id);
    _topIdList.remove(dto.id);
    _commonIdList.insert(0, dto.id);
    if (_conversationMap[dto.id] == null) {
      _conversationMap[dto.id] = dto;
    } else {
      _conversationMap[dto.id].isTop = 0;
    }
    ConversationDBHelper().updateConversation(_conversationMap[dto.id]);
    _notifyListeners();
  }

  removeConversation(List<ConversationDto> dtoList) {
    for (ConversationDto dto in dtoList) {
      _topIdList.remove(dto.id);
      _commonIdList.remove(dto.id);
      _conversationMap.remove(dto.id);
    }

    _notifyListeners();
  }

  updateConversation(ConversationDto dto) {
    _conversationMap[dto.id] = dto;
    _notifyListeners();
  }

  updateConversationName(String name,ConversationDto dto){
    if(_conversationMap[dto.id]!=null){
      _conversationMap[dto.id].name=name;
      _notifyListeners();
    }
  }

  _notifyListeners(){
    notifyListeners();
    _updateUnreadMessageNumber();
  }

  _updateUnreadMessageNumber(){
    MessageManager.unreadMessageNumber=0;
    _conversationMap.forEach((key, value) {
      NoPromptUidModel model=NoPromptUidModel(type: value.type,targetId: int.parse(value.conversationId));
      if(!NoPromptUidModel.contains(MessageManager.queryNoPromptUidList,model)){
        MessageManager.unreadMessageNumber+=value.unreadCount;
      }
    });
    EventBus.getDefault().post(registerName: EVENTBUS_IF_TAB_BAR_UNREAD);
  }
}
