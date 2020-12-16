import 'package:flutter/cupertino.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/data/model/home/home_feed.dart';
typedef CommentModelCallback = void Function(CommentDtoModel model);
// 发布评论接口
Future postComments({
  @required int targetId,
  @required int targetType,
  @required String content,
  @required CommentModelCallback commentModelCallback,
  String picUrl,
  String atUsers,
  int replyId,
  int replyCommentId,
}) async {
  CommentDtoModel comModel;
  Map<String, dynamic> modelMap = await publish(targetId: targetId, targetType: targetType, content: content,picUrl: picUrl,atUsers: atUsers,
      replyId: replyId,replyCommentId:replyCommentId );
  if (modelMap != null) {
    comModel = (CommentDtoModel.fromJson(modelMap));
  }
  commentModelCallback(comModel);
}
