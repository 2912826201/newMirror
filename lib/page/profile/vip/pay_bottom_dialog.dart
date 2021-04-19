import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/icon.dart';

typedef OnItemClickListener = void Function(PayTheWay pay);
enum PayTheWay { WECHAT, ZHIFUBAO }

Future payBottomSheet({@required BuildContext context, @required String title, @required int payNumber}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))),
      builder: (BuildContext context) {
        return SingleChildScrollView(
            child: PayBottomDialog(
          titleText: title,
          payNumber: payNumber,
        ));
      });
}

class PayBottomDialog extends StatefulWidget {
  String titleText;
  int payNumber;
  OnItemClickListener onItemClickListener;

  PayBottomDialog({this.titleText, this.payNumber, this.onItemClickListener});

  @override
  State<StatefulWidget> createState() {
    return _PayBottomDialogState();
  }
}

class _PayBottomDialogState extends State<PayBottomDialog> {
  bool weChat = true;
  bool zhifuBao = false;
  PayTheWay payTheWay;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270 + ScreenUtil.instance.bottomBarHeight,
      width: ScreenUtil.instance.screenWidthDp,
      padding: EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Column(
        children: [
          _title(),
          Container(
            height: 69,
            child: Center(
              child: Text(
                "￥${widget.payNumber}",
                style: AppStyle.textSemibold23,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                weChat = true;
                zhifuBao = false;
              });
            },
            child: _payButton("微信", weChat),
          ),
          InkWell(
            onTap: () {
              setState(() {
                weChat = false;
                zhifuBao = true;
              });
            },
            child: _payButton("支付宝", zhifuBao),
          ),
          SizedBox(height: 12,),
          InkWell(
            onTap: () {
              if (weChat) {
                print('选择了========================微信');
              } else {
                print('选择了========================支付宝');
              }
            },
            child: _bottomButton(),
          )
        ],
      ),
    );
  }

  Widget _payButton(String text, bool isChosen) {
    return Container(
      height: 48,
      child: Center(
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColor.mainBlue,
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              text,
              style: AppStyle.textMedium16,
            ),
            Spacer(),
            AppIcon.getAppIcon(isChosen ? AppIcon.selection_selected : AppIcon.selection_not_selected, 24),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
      height: 44,
      child: Center(
        child: Row(
          children: [
            Expanded(
                child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.centerLeft,
                child: AppIcon.getAppIcon(AppIcon.close_18, 18),
              ),
            )),
            Text(
              widget.titleText,
              style: AppStyle.textMedium16,
            ),
            Spacer()
          ],
        ),
      ),
    );
  }

  Widget _bottomButton() {
    return Container(
      height: 49,
      child: Center(
        child: Container(
          height: 40,
          width: ScreenUtil.instance.screenWidthDp * 0.91,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [AppColor.bgVip1, AppColor.bgVip2],
                begin: FractionalOffset(0.6, 0),
                end: FractionalOffset(1, 0.6)),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Center(
            child: Text(
              "立即开通",
              style: AppStyle.redMedium16,
            ),
          ),
        ),
      ),
    );
  }
}
