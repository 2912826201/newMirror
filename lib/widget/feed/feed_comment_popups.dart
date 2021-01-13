import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_bottom_sheet.dart';
import 'package:mirror/util/screen_util.dart';

import '../bottom_sheet.dart';

Future openFeedCommentBottomSheet({
  @required BuildContext context,
  @required int feedId,
}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
            child: Container(
              height:
              ScreenUtil.instance.height * 0.75,
              color: AppColor.white,
              child: CommentBottomSheet(
                feedId: feedId,
              ) ,
            )

        );
      });
}