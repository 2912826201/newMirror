import 'package:flutter/cupertino.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/profile/black_model.dart';

// 发布接口返回
typedef CommentModelCallback = void Function(BaseResponseModel model);
// 查询是否拉黑接口返回
typedef InquireCheckBlackCallback = void Function(BlackModel model);
// 发布评论接口
Future postComments({
  @required int targetId,
  @required int targetType,
  @required String contentext,
  @required CommentModelCallback commentModelCallback,
  String picUrl,
  String atUsers,
  int replyId,
  int replyCommentId,
}) async {
  BaseResponseModel model = await publish(
      targetId: targetId,
      targetType: targetType,
      content: contentext,
      picUrl: picUrl,
      atUsers: atUsers,
      replyId: replyId,
      replyCommentId: replyCommentId);
  commentModelCallback(model);
}

// 查询是否拉黑
Future InquireCheckBlack({
  @required int checkId,
  @required InquireCheckBlackCallback inquireCheckBlackCallback,
}) async {
  BlackModel blackModel = await ProfileCheckBlack(checkId);
  inquireCheckBlackCallback(blackModel);
}
