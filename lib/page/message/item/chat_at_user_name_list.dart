import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/page/message/chat_page.dart';
import 'package:mirror/page/message/message_view/currency_msg.dart';
import 'package:mirror/util/toast_util.dart';

typedef StringCallback = void Function(ChatGroupUserModel userModel, int index);

class ChatAtUserList extends StatefulWidget {
  final bool isShow;
  final StringCallback onItemClickListener;

  ChatAtUserList({this.isShow = false, this.onItemClickListener});

  @override
  createState() => _ChatAtUserListState();
}

class _ChatAtUserListState extends State<ChatAtUserList> {

  @override
  Widget build(BuildContext context) {
    if (widget.isShow) {
      return Offstage(
        offstage: !widget.isShow,
        child: GestureDetector(
          child: Container(
            color: Colors.grey.withOpacity(0.3),
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            child: UnconstrainedBox(
              child: getAnimatedContainer(),
            ),
          ),
          onTap: () {
            print("取消弹窗");
            ToastShow.show(msg: "取消弹窗", context: context);
          },
          onTapDown: (v) {
            print("取消弹窗");
          },
          onTapUp: (v) {
            print("取消弹窗");
          },
        ),
      );
    } else {
      return Container();
    }
  }

  //动画部分
  Widget getAnimatedContainer() {
    return AnimatedContainer(
      height: widget.isShow ? 5 * 48.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        height: 5 * 48.0,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
        child: listViewUi(),
      ),
    );
  }

  //list
  Widget listViewUi() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: Application.chatGroupUserModelList.length,
      itemBuilder: (context, index) {
        return item(Application.chatGroupUserModelList[index], index);
      },
    );
  }

  //每一个item
  Widget item(ChatGroupUserModel groupUserModel, int index) {
    return Material(
        color: AppColor.white,
        child: new InkWell(
          child: Container(
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                getUserImage(groupUserModel.avatarUri, 36, 36),
                SizedBox(width: 12),
                Text(
                  groupUserModel.groupNickName,
                  style: AppStyle.textRegular16,
                )
              ],
            ),
          ),
          splashColor: AppColor.textHint,
          onTap: () {
            if (widget.onItemClickListener != null) {
              widget.onItemClickListener(groupUserModel, index);
            }
          },
        ));
  }
}
