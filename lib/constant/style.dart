import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';

class AppStyle {
  // 注：fontWeight的默认值为 w400-Regular

  // Regular主体文字黑色
  static const textRegular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.mainBlack);
  static const textRegular15 = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColor.mainBlack);
  static const textRegular14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.mainBlack);
  static const textRegular13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.mainBlack);
  static const textRegular12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.mainBlack);

  // Medium主体文字黑色
  static const textMedium36 = TextStyle(fontSize: 36, fontWeight: FontWeight.w500, color: AppColor.mainBlack);
  static const textMedium23 = TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: AppColor.mainBlack);
  static const textMedium18 = TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColor.mainBlack);
  static const textMedium16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.mainBlack);
  static const textMedium15 = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColor.mainBlack);
  static const textMedium14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.mainBlack);
  static const textMedium12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColor.mainBlack);

  // Regular文字辅色1-白色60%
  static const text1Regular17 = TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: AppColor.textWhite60);
  static const text1Regular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.textWhite60);
  static const text1Regular15 = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColor.textWhite60);
  static const text1Regular14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textWhite60);
  static const text1Regular13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.textWhite60);
  static const text1Regular12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textWhite60);
  static const text1Regular11 = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColor.textWhite60);
  static const text1Regular10 = TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColor.textWhite60);

  static const text1Medium29 = TextStyle(fontSize: 29, fontWeight: FontWeight.w500, color: AppColor.textWhite60);
  static const text1Medium21 = TextStyle(fontSize: 21, fontWeight: FontWeight.w500, color: AppColor.textWhite60);
  static const text1Medium16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.textWhite60);

  // Regular文字辅色2-白色40%
  static const text2Regular14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textWhite40);
  static const text2Regular12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textWhite40);
  static const text2Regular10 = TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColor.textWhite40);

  //红色
  static const redRegular18 = TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColor.mainRed);
  static const redRegular17 = TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: AppColor.mainRed);
  static const redRegular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.mainRed);
  static const redRegular14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.mainRed);
  static const redRegular13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.mainRed);
  static const redRegular11 = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColor.mainRed);
  static const redMedium21 = TextStyle(fontSize: 21, fontWeight: FontWeight.w500, color: AppColor.mainRed);
  static const redMedium16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.mainRed);
  static const redMedium14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.mainRed);
  static const redMedium13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.mainRed);

  //蓝色
  static const blueRegular18 = TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColor.mainBlue);
  static const blueRegular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.mainBlue);
  static const blueRegular14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.mainBlue);

  //纯白色
  static const whiteRegular24 = TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular23 = TextStyle(fontSize: 23, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular18 = TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular17 = TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular15 = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular11 = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular10 = TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular9 = TextStyle(fontSize: 9, fontWeight: FontWeight.w400, color: AppColor.white);

  static const whiteMedium23 = TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium32 = TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium29 = TextStyle(fontSize: 29, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium21 = TextStyle(fontSize: 21, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium18 = TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium17 = TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium15 = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium10 = TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteBold40 = TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: AppColor.white);
  static const whiteBold21 = TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppColor.white);

  //=================================下面是旧的样式===============================================

  // Regular textSecondary 辅助字体灰色
  static const textSecondaryRegular16 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.textSecondary);
  static const textSecondaryRegular14 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textSecondary);
  static const textSecondaryRegular12 =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textSecondary);

  // textHint 提示字体灰色
  static const textHintRegular14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textHint);
  static const textHintRegular13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.textHint);
  static const textHintRegular12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textHint);

  // Regular primary3灰色
  static const textPrimary3Regular14 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textPrimary3);

  // Medium primary2 黑色
  static const textPrimary2Medium23 =
      TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: AppColor.textPrimary2);
  static const textPrimary2Medium14 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.textPrimary2);
  static const textPrimary2Medium12 =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColor.textPrimary2);

  static const textPrimary2Regular16 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.textPrimary2);

  //不在规范内style
  static const textDeleteHintRegular12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColor.textHint,
    decoration: TextDecoration.lineThrough,
    decorationColor: AppColor.textHint,
  );
  static const textSemibold23 = TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: AppColor.textVipPrimary1);

  static const redVipMedium11 = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColor.textVipPrimary1);
}
