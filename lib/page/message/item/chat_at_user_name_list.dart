import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_enter_notifier.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/page/message/message_view/currency_msg.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:provider/provider.dart';

import '../message_chat_page_manager.dart';

typedef StringCallback = void Function(ChatGroupUserModel userModel, int index);


///群聊聊天-用户@界面
class ChatAtUserList extends StatefulWidget {
  final bool isShow;
  final StringCallback onItemClickListener;
  final String groupChatId;

  ChatAtUserList({this.isShow = false, this.onItemClickListener, this.groupChatId});

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
            print("取消艾特功能1");
            context.read<ChatEnterNotifier>().openAtCallback("");
          },
        ),
      );
    } else {
      return Container();
    }
  }

  //动画部分
  Widget getAnimatedContainer() {
    return Consumer<GroupUserProfileNotifier>(
        builder: (context, notifier, child) {
          int count=context.watch<GroupUserProfileNotifier>().getSearchUserModelList().length;
          return AnimatedContainer(
            height: widget.isShow ? (count<2?2:count>5?5:count)*48.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Container(
              height: (count<2?2:count>5?5:count)*48.0,
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
        },
    );
  }

  //list
  Widget listViewUi() {
    return Consumer<GroupUserProfileNotifier>(
      builder: (context, notifier, child) {
        if (context.watch<GroupUserProfileNotifier>().loadingStatus == LoadingStatus.STATUS_COMPLETED) {
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: context.watch<GroupUserProfileNotifier>().getSearchUserModelList().length,
            itemBuilder: (context, index) {
              return item(context.watch<GroupUserProfileNotifier>().getSearchUserModelList()[index], index);
            },
          );
        } else if (context.watch<GroupUserProfileNotifier>().len >= 0) {
          getChatGroupUserModelList1(widget.groupChatId, context);
        }
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: UnconstrainedBox(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
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
