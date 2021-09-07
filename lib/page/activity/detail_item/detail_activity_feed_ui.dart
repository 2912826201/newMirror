import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/widget/icon.dart';

class DetailActivityFeedUi extends StatefulWidget {
  final ActivityModel activityModel;

  DetailActivityFeedUi(this.activityModel);

  @override
  _DetailActivityFeedUiState createState() => _DetailActivityFeedUiState();
}

class _DetailActivityFeedUiState extends State<DetailActivityFeedUi> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppRouter.navigateActivityFeedPage(context, widget.activityModel);
      },
      child: getBody(),
    );
  }

  Widget getBody() {
    if (widget.activityModel.pics == null || widget.activityModel.pics.length < 1) {
      return noFeedUi();
    } else {
      return haveDataUi();
    }
  }

  Widget haveDataUi() {
    return Container(
      width: double.infinity,
      height: 66,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text("动态", style: AppStyle.text1Regular16),
          SizedBox(width: 18),
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < widget.activityModel.pics.length; i++)
                  Container(
                    child: _getImage(widget.activityModel.pics[i], i, widget.activityModel.pics.length),
                  ),
              ],
            ),
          ),
          SizedBox(width: 18),
          AppIcon.getAppIcon(
            AppIcon.arrow_right_18,
            18,
            color: AppColor.textWhite60,
          )
        ],
      ),
    );
  }

  //顶部图片
  Widget _getImage(String url, int index, int len) {
    return CachedNetworkImage(
      height: 46,
      width: index + 1 < len ? 23 : 46,
      imageUrl: url == null ? "" : FileUtil.getImageSlim(url),
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColor.imageBgGrey,
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColor.imageBgGrey,
      ),
    );
  }

  Widget noFeedUi() {
    return Container(
      width: double.infinity,
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text("动态", style: AppStyle.text1Regular16),
          Expanded(
            child: Text(
              "该活动还没有发布过动态哦",
              style: AppStyle.text1Regular14,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
