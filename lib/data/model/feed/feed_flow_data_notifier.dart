

import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/home/home_feed.dart';

class FeedFlowDataNotifier  extends ChangeNotifier {

  List<HomeFeedModel> homeFeedModelList = [];
  int pageSize;
  int pageSelectPosition;
  int pageLastTime;
  String pageName;
  String heroTagString="heroTagStringFeedFlowDataNotifier";

  FeedFlowDataNotifier(){
    homeFeedModelList=<HomeFeedModel>[];
    pageSize=0;
    pageSelectPosition=0;
    pageLastTime=null;
    pageName=null;
  }

  clear(){
    homeFeedModelList=<HomeFeedModel>[];
    pageSize=0;
    pageSelectPosition=0;
    pageLastTime=null;
  }


}