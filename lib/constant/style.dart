import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';

class AppStyle {
  // 注：fontWeight的默认值为 w400-Regular

  // Regular主体文字黑色
  static const textRegular18 = TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColor.textPrimary1);
  static const textRegular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.textPrimary1);
  static const textRegular15 = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColor.textPrimary1);
  static const textRegular14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textPrimary1);
  static const textRegular13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.textPrimary1);
  static const textRegular12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textPrimary1);

  // Medium主体文字黑色
  static const textMedium36 = TextStyle(fontSize: 36, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium29 = TextStyle(fontSize: 29, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium23 = TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium21 = TextStyle(fontSize: 21, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium18 = TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium15 = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);

  // Regular textSecondary 辅助字体灰色
  static const textSecondaryRegular16 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.textSecondary);
  static const textSecondaryRegular14 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textSecondary);
  static const textSecondaryRegular13 =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.textSecondary);
  static const textSecondaryRegular12 =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textSecondary);
  static const textSecondaryRegular11 =
      TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColor.textSecondary);

  // Medium textSecondary 辅助字体灰色
  static const textSecondaryMedium14 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.textSecondary);

  // textHint 提示字体灰色
  static const textHintRegular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.textHint);
  static const textHintRegular14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textHint);
  static const textHintRegular13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.textHint);
  static const textHintRegular12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textHint);
  static const textHintRegular10 = TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColor.textHint);

  // Regular primary3灰色
  static const textPrimary3Regular14 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textPrimary3);
  static const textPrimary3Regular13 =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.textPrimary3);
  static const textPrimary3Regular12 =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textPrimary3);

  // Medium primary3灰色
  static const textPrimary3Medium29 =
      TextStyle(fontSize: 29, fontWeight: FontWeight.w500, color: AppColor.textPrimary3);
  static const textPrimary3Medium23 =
      TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: AppColor.textPrimary3);
  static const textPrimary3Medium21 =
      TextStyle(fontSize: 21, fontWeight: FontWeight.w500, color: AppColor.textPrimary3);
  static const textPrimary3Medium16 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.textPrimary3);

  // Medium primary2 黑色
  static const textPrimary2Medium23 =
      TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: AppColor.textPrimary2);
  static const textPrimary2Medium16 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.textPrimary2);
  static const textPrimary2Medium15 =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColor.textPrimary2);
  static const textPrimary2Medium14 =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.textPrimary2);
  static const textPrimary2Medium12 =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColor.textPrimary2);

  static const textPrimary2Regular16 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.textPrimary2);
  static const textPrimary2Regular14 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textPrimary2);
  static const textPrimary2Regular12 =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textPrimary2);

  //红色
  static const redRegular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.mainRed);
  static const redRegular13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.mainRed);
  static const redRegular11 = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColor.mainRed);
  static const redMedium21 = TextStyle(fontSize: 21, fontWeight: FontWeight.w500, color: AppColor.mainRed);
  static const redMedium16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.mainRed);
  static const redMedium14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.mainRed);
  static const redMedium13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.mainRed);
  static const redVipMedium11 = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColor.textVipPrimary1);

  //纯白色
  static const whiteRegular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteRegular12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.white);
  static const whiteMedium18 = TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium15 = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColor.white);
  static const whiteMedium14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.white);

  //纯黑色
  static const blackBold21 = TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppColor.black);

  //不在规范内style
  static const textDeleteHintRegular12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColor.textHint,
    decoration: TextDecoration.lineThrough,
    decorationColor: AppColor.textHint,
  );
  static const textSemibold23 = TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: AppColor.textVipPrimary1);
  static const textAddressText = TextStyle(color: Color(0xFF000046), fontSize: 16.0, fontWeight: FontWeight.w500);
}
