
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import '../page/message/util/chat_page_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/string_util.dart';
import 'dart:math' as math;

import 'icon.dart';

class UserAvatarImageUtil{
  static UserAvatarImageUtil util;

  static UserAvatarImageUtil init(){
    if(util==null){
      util=UserAvatarImageUtil();
    }
    return util;
  }


//获取用户的头像
  Widget getUserImageWidget(String imageUrl,String userId, double width,[double height] ) {

    if(height==null||height!=width){
      height=width;
    }

    if(ChatPageUtil.init(Application.appContext).isSystemMsg(userId)){
      return _getSystemIdAvatar(height,width);
    }

    if (!StringUtil.isURL(imageUrl)) {
      imageUrl = "http://devpic.aimymusic.com/app/system_message_avatar.png";
      imageUrl=FileUtil.getSmallImage(imageUrl);
    }

    if(ChatPageUtil.init(Application.appContext).isOfficialMsg(userId)){
      return _getOfficialAvatar(imageUrl,height,width);
    }

    return _getUserImageAvatar(imageUrl,height,width);

  }

  //获取群聊的头像
  Widget getGroupImageWidget(List<String> avatarList, int isTop,String userId) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: ClipOval(
            child: CachedNetworkImage(
              height: 28,
              width: 28,
              imageUrl: avatarList.first,
              fit: BoxFit.cover,
              memCacheWidth: 150,
              memCacheHeight: 150,

              /// imageUrl的淡入动画的持续时间。
              fadeInDuration: Duration(milliseconds: 0),
              placeholder: (context, url) => Container(
                color: AppColor.imageBgGrey,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColor.imageBgGrey,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                //这里的边框颜色需要随背景变化
                border: Border.all(width: 3, color: isTop == 1 ? AppColor.layoutBgGrey : AppColor.mainBlack)),
            child: ClipOval(
              child: CachedNetworkImage(
                height: 28,
                width: 28,
                imageUrl: avatarList[1],
                fit: BoxFit.cover,
                memCacheWidth: 150,
                memCacheHeight: 150,

                /// imageUrl的淡入动画的持续时间。
                fadeInDuration: Duration(milliseconds: 0),
                placeholder: (context, url) => Container(
                  color: AppColor.imageBgGrey,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColor.imageBgGrey,
                ),
              ),
            ),
          ),
        ),
      ],
    );

  }





  Widget _getUserImageAvatar(String imageUrl,double height, double width){
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: CachedNetworkImage(
        height: height,
        width: width,
        imageUrl: imageUrl == null ? "" : imageUrl,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        placeholder: (context, url) => Container(
          color: AppColor.imageBgGrey,
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColor.imageBgGrey,
        ),
      ),
    );
  }


  Widget _getSystemIdAvatar(double height, double width){
    int type=OFFICIAL_TYPE;
    return Stack(
      children: [
        Container(
          height: math.max(height,36),
          width:  math.max(width,36),
          decoration: BoxDecoration(
            color: AppColor.imageBgGrey,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: AppIcon.getAppIcon(
              type == OFFICIAL_TYPE
                  ? AppIcon.avatar_system
                  : type == LIVE_TYPE
                  ? AppIcon.avatar_live
                  : type == TRAINING_TYPE
                  ? AppIcon.avatar_training
                  : AppIcon.avatar_system,
              24),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            //NOTE flutter的奇葩问题，同样大小的shape叠放上面的无法完美覆盖下面，留一丝丝边，用自带的border也有这个问题，只好用嵌套方式里面的尺寸写小点。。。
            decoration: ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(color: AppColor.white, width: 1),
              ),
            ),
            height: 16,
            width: 16,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.imageBgGrey,
                shape: BoxShape.circle,
              ),
              height: 15,
              width: 15,
              alignment: Alignment.center,
              child: AppIcon.getAppIcon(AppIcon.official, 10),
            ),
          ),
        ),
      ],
    );
  }


  Widget _getOfficialAvatar(String imageUrl,double height, double width) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: CachedNetworkImage(
            height: height,
            width: width,
            imageUrl: imageUrl == null ? "" : FileUtil.getSmallImage(imageUrl),
            fit: BoxFit.cover,
            fadeInDuration: Duration(milliseconds: 0),
            placeholder: (context, url) => Container(
              color: AppColor.imageBgGrey,
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColor.imageBgGrey,
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            //NOTE flutter的奇葩问题，同样大小的shape叠放上面的无法完美覆盖下面，留一丝丝边，用自带的border也有这个问题，只好用嵌套方式里面的尺寸写小点。。。
            decoration: ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(color: AppColor.white, width: 1),
              ),
            ),
            height: 16,
            width: 16,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.imageBgGrey,
                shape: BoxShape.circle,
              ),
              height: 15,
              width: 15,
              alignment: Alignment.center,
              child: AppIcon.getAppIcon(AppIcon.official, 10),
            ),
          ),
        ),
      ],
    );
  }

}