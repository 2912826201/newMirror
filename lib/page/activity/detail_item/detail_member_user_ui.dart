import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/user_avatar_image.dart';

class DetailMemberUserUi extends StatefulWidget {
  final List<UserModel> userList;

  DetailMemberUserUi(this.userList);

  @override
  _DetailMemberUserUiState createState() {
    List<UserModel> list = [];
    if (userList.length > 5) {
      list = userList.sublist(0, 5);
    } else {
      list.addAll(userList);
    }
    return _DetailMemberUserUiState(list);
  }
}

class _DetailMemberUserUiState extends State<DetailMemberUserUi> {
  List<UserModel> userList;

  _DetailMemberUserUiState(this.userList);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double itemWidth = (ScreenUtil.instance.width - 32 - 25) / 6;

    return Container(
      width: ScreenUtil.instance.width,
      height: 145,
      child: Column(
        children: [
          Container(
            width: ScreenUtil.instance.width,
            height: 45,
            child: Row(
              children: [
                Text("报名队员", style: AppStyle.whiteRegular16),
                SizedBox(width: 8),
                Text("共${userList.length}人", style: AppStyle.whiteRegular14),
                Spacer(),
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.mainYellow,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    child: Text("群聊", style: AppStyle.textRegular12),
                  ),
                  onTap: () {
                    print("进入群聊");
                  },
                )
              ],
            ),
          ),
          Container(
            width: ScreenUtil.instance.width,
            height: 100,
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: ListView.separated(
                itemCount: userList.length + 1,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (BuildContext context, int index) => VerticalDivider(
                      width: 6.0,
                      color: AppColor.mainBlack,
                    ),
                itemBuilder: (context, index) {
                  if (index != userList.length) {
                    return Container(
                      width: itemWidth,
                      height: 100.0 - 12.0 - 16.0,
                      child: Column(
                        children: [
                          UserAvatarImageUtil.init()
                              .getUserImageWidget(userList[index].avatarUri, userList[index].uid.toString(), 45),
                          SizedBox(height: 6),
                          Text(
                            userList[index].nickName,
                            style: AppStyle.text1Regular12,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      width: itemWidth,
                      height: 100.0 - 12.0 - 16.0,
                      child: UnconstrainedBox(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 47,
                          width: 47,
                          child: AppIconButton(
                            svgName: AppIcon.group_add,
                            iconSize: 24,
                            bgColor: AppColor.textWhite60,
                            isCircle: true,
                            buttonHeight: 47,
                            buttonWidth: 47,
                            iconColor: AppColor.mainBlack,
                            onTap: () {
                              print("点击了添加成员");
                            },
                          ),
                        ),
                      ),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}
