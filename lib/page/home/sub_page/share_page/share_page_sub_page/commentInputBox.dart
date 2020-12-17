// 隐藏评论的输入框
import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:provider/provider.dart';
import 'package:mirror/api/home/home_feed_api.dart';

class CommentInputBox extends StatefulWidget {
  CommentInputBox({Key key, this.isUnderline = false, this.feedModel}) : super(key: key);
  bool isUnderline;

  // 动态model
  HomeFeedModel feedModel;

  // 子评论model
  // commentDtoModel
  CommentInputBoxState createState() => CommentInputBoxState();
}

class CommentInputBoxState extends State<CommentInputBox> {
  var offstage = true;

  inputHide() {
    setState(() {
      offstage = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    print("底部键盘高度${MediaQuery.of(context).viewInsets.bottom}");
    return Offstage(
      offstage: false,
      child: Container(
        // color: Colors.limeAccent,
        height: 48,
        width: ScreenUtil.instance.screenWidthDp,
        decoration: BoxDecoration(
          // border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
          border: Border(top: BorderSide(width: widget.isUnderline ? 0.5 : 0.000000001, color: Color(0xffe5e5e5))),
        ),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(left: 16),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        // ProfileNotifier value.profile.avatarUri
                        image: context.watch<TokenNotifier>().isLoggedIn
                            ? NetworkImage(context.select((ProfileNotifier value) => value.profile.avatarUri))
                            : AssetImage("images/test/yxlm1.jpeg"),
                        fit: BoxFit.cover)),
              ),
              GestureDetector(
                child: Container(
                  width: ScreenUtil.instance.screenWidthDp - 32 - 40,
                  height: 28,
                  margin: EdgeInsets.only(left: 12),
                  padding: EdgeInsets.only(left: 16),
                  alignment: Alignment(-1, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    color: AppColor.bgWhite_65,
                  ),
                  child: Text(widget.isUnderline ? "说点什么吧~" : "喜欢就评论吧~",
                      style: TextStyle(fontSize: 14, color: AppColor.textHint)),
                ),
                onTap: () {
                  openInputBottomSheet(
                    context: this.context,
                    hintText: widget.isUnderline ? "说点什么吧~" : "喜欢就评论吧~",
                    voidCallback: (String text, BuildContext context) {
                      // 发布评论
                      postComments(
                          targetId: widget.feedModel.id,
                          targetType: 0,
                          content: text,
                          commentModelCallback: (CommentDtoModel commentModel) {
                            if (commentModel != null) {
                              print(commentModel.toString());
                              print(widget.feedModel.id);
                              print(context);
                              context.read<FeedMapNotifier>().feedPublishComment(commentModel, widget.feedModel.id);
                            }
                            // 关闭评论输入框
                            Navigator.of(context).pop(1);
                          });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
