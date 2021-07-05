import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import '../message/util/message_chat_page_manager.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/Input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:mirror/widget/icon.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// share_popup
/// Created by Shipk on 2021/4/6.


showGroupPopup(BuildContext context,int excludeUId,Function(GroupChatModel groupChatModel) onClickCallBackListener) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      //可不受最大高度限制
      elevation: 0,
      backgroundColor: AppColor.transparent,
      builder: (context) {
        return _SharePopup(excludeUId,onClickCallBackListener);
      });
}

class _SharePopup extends StatefulWidget {
  final int excludeUId;
  final Function(GroupChatModel groupChatModel) onClickCallBackListener;

  _SharePopup(this.excludeUId,this.onClickCallBackListener);

  @override
  _SharePopupState createState() => _SharePopupState();
}

class _SharePopupState extends State<_SharePopup> {
  List<GroupChatModel> _groupList = [];

  @override
  void initState() {
    super.initState();
    _getGroupList();
  }

  _getGroupList() {
    getGroupChatList().then((groupChatListMap) {
      if (groupChatListMap != null && groupChatListMap["list"] != null) {
        groupChatListMap["list"].forEach((v) {
          _groupList.add(GroupChatModel.fromJson(v));
        });
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: AppColor.white,
      ),
      height: ScreenUtil.instance.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 4,
            color: AppColor.bgWhite,
            margin: const EdgeInsets.only(top: 16, bottom: 24),
          ),
          Expanded(
            child: _buildGroupListPage(),
          ),
        ],
      ),
    );
  }


  Widget _buildGroupListPage() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(right: 16),
          height: 48,
          child: Text(
            "我加入的群聊",
            style: AppStyle.textRegular16,
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          height: 0.5,
          color: AppColor.bgWhite,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _groupList.length,
            itemBuilder: _buildGroupItem,
          ),
        )
      ],
    );
  }

  Widget _buildGroupItem(BuildContext context, int index) {
    List<String> avatarList = _groupList[index].coverUrl.split(",");
    String name = _groupList[index].modifiedName ?? _groupList[index].name;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if(ClickUtil.isFastClick()){
            return;
          }
          print("点击了群名");
          if(widget.onClickCallBackListener!=null){
            widget.onClickCallBackListener(_groupList[index]);
          }
          Navigator.of(context).pop();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 32,
              width: 32,
              child: Stack(
                children: [
                  avatarList.length == 1
                      ? ClipOval(
                          child: CachedNetworkImage(
                            height: 32,
                            width: 32,
                            imageUrl: avatarList.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColor.bgWhite,
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColor.bgWhite,
                            ),
                          ),
                        )
                      : avatarList.length > 1
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  height: 20,
                                  width: 20,
                                  imageUrl: avatarList.first,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColor.bgWhite,
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: AppColor.bgWhite,
                                  ),
                                ),
                              ))
                          : Container(),
                  avatarList.length > 1
                      ? Positioned(
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, border: Border.all(width: 3, color: AppColor.white)),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                height: 20,
                                width: 20,
                                imageUrl: avatarList[1],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColor.bgWhite,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColor.bgWhite,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            SizedBox(
              width: 13,
            ),
            Expanded(
              child: Text(
                _groupList[index].modifiedName ?? _groupList[index].name,
                style: TextStyle(color: AppColor.textPrimary2, fontSize: 16),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 26,
            ),
            // AppIcon.getAppIcon(
            //   AppIcon.arrow_right_18,
            //   18,
            //   color: AppColor.textHint,
            // ),
          ],
        ),
      ),
    );
  }

}
