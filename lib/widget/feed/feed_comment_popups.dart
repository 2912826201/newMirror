import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_bottom_sheet.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:provider/provider.dart';
import '../bottom_sheet.dart';
    typedef ValueChangedCallback = void Function();
Future openFeedCommentBottomSheet({
  @required BuildContext context,
  @required int feedId,
  ValueChangedCallback callback
}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: AppColor.white,
      context: context,
      // 圆角
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      builder: (BuildContext context) {
        return SizedBox(
          height: ScreenUtil.instance.height * 0.75,
          child: CommentBottomSheet(
            feedId: feedId,
          ),
        );
      }).then((value){
          callback();
  });
}
