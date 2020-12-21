import 'package:flutter/material.dart';
import 'package:mirror/data/dto/conversation_dto.dart';

/// conversation_notifier
/// Created by yangjiayi on 2020/12/21.

class ConversationNotifier with ChangeNotifier {
  List<String> _topIdList = [];
  List<String> _commonIdList = [];

  Map<String, ConversationDto> _conversationMap = {};

  int get topListLength => _topIdList.length;
  int get commonListLength => _commonIdList.length;
  ConversationDto getConversationInTopList(int index) => _conversationMap[_topIdList[index]];
  ConversationDto getConversationInCommonList(int index) => _conversationMap[_commonIdList[index]];
  ConversationDto getConversationById(String id) => _conversationMap[id];

  clearAllData(){
    _topIdList.clear();
    _commonIdList.clear();
    _conversationMap.clear();

    notifyListeners();
  }

  insertTopList(List<ConversationDto> topList){
    for(ConversationDto dto in topList){
      //为确保不重复添加 先删除一下
      _topIdList.remove(dto.id);
      _topIdList.add(dto.id);
      _conversationMap[dto.id] = dto;
    }

    notifyListeners();
  }

  insertCommonList(List<ConversationDto> commonList){
    for(ConversationDto dto in commonList){
      //为确保不重复添加 先删除一下
      _commonIdList.remove(dto.id);
      _commonIdList.add(dto.id);
      _conversationMap[dto.id] = dto;
    }

    notifyListeners();
  }
}