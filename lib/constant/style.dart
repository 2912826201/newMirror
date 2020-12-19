import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

class AppStyle {
  // 注：fontWeight的默认值为 w400-Regular

  // Regular主体文字黑色
  static const textRegular18 = TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: AppColor.textPrimary1);
  static const textRegular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.textPrimary1);
  static const textRegular14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textPrimary1);
  static const textRegular12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textPrimary1);

  // Regular 辅助字体灰色
  static const textSecondaryRegular12 =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textSecondary);
  static const textHintRegular12 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textHint);
  static const textHintRegular13 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.textHint);
  static const textHintRegular16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.textHint);
  static const textHintRegular16 = TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color:AppColor.textHint );
  // Regular 灰色
  static const textPrimary3Regular14 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColor.textPrimary3);

  // Medium主体文字黑色
  static const textMedium18 = TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium16 = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium15 = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);
  static const textMedium14 = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.textPrimary1);

  //红色
  static const textRegularRed16 = TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColor.mainRed);
}
