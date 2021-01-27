import 'package:flutter/material.dart';
import 'package:mirror/data/dto/conversation_dto.dart';

/// conversation_notifier
/// Created by yangjiayi on 2020/12/21.

class ConversationNotifier with ChangeNotifier {
  //置顶
  List<String> _topIdList = [];

  //非置顶
  List<String> _commonIdList = [];

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

    notifyListeners();
  }

  insertTopList(List<ConversationDto> topList) {
    for (ConversationDto dto in topList) {
      //为确保不重复添加 先删除一下 并且插在第一位 后进的排在前面
      _topIdList.remove(dto.id);
      _topIdList.insert(0, dto.id);
      _conversationMap[dto.id] = dto;
    }

    notifyListeners();
  }

  insertCommonList(List<ConversationDto> commonList) {
    for (ConversationDto dto in commonList) {
      //为确保不重复添加 先删除一下 并且插在第一位 后进的排在前面
      _commonIdList.remove(dto.id);
      _commonIdList.insert(0, dto.id);
      _conversationMap[dto.id] = dto;
    }

    notifyListeners();
  }

  removeConversation(List<ConversationDto> dtoList) {
    for (ConversationDto dto in dtoList) {
      _topIdList.remove(dto.id);
      _commonIdList.remove(dto.id);
      _conversationMap.remove(dto.id);
    }

    notifyListeners();
  }

  updateConversation(ConversationDto dto) {
    _conversationMap[dto.id] = dto;
    notifyListeners();
  }
}
