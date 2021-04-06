import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

/// count_badge
/// Created by yangjiayi on 2020/12/21.

//计数的小红点

class CountBadge extends StatelessWidget {
  final int count;
  final double height = 18.0;
  final double fontSize = 12.0;
  final bool isSilent;

  CountBadge(this.count, this.isSilent);

  @override
  Widget build(BuildContext context) {
    String text = count > 99 ? "99+" : "$count";
    double width = count > 99
        ? 32.0
        : count > 9
            ? 28.0
            : 18.0;
    return count == 0
        ? Container()
        : isSilent
            ? Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: AppColor.mainRed,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              )
            : Stack(//NOTE flutter的奇葩问题，同样大小的shape叠放上面的无法完美覆盖下面，留一丝丝边，用自带的border也有这个问题，只好用Stack叠放下方的写小点。。。
                children: [
                  Positioned(
                    top: 0.5,
                    left: 0.5,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: AppColor.mainRed,
                        shape: StadiumBorder(
                          side: BorderSide.none,
                        ),
                      ),
                      alignment: Alignment.center,
                      width: width - 1,
                      height: height - 1,
                      child: Text(
                        text,
                        style: TextStyle(fontSize: fontSize, color: AppColor.white),
                      ),
                    ),
                  ),
                  Container(
                    decoration: ShapeDecoration(
                      color: AppColor.transparent,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: AppColor.white,
                          width: 1,
                        ),
                      ),
                    ),
                    width: width,
                    height: height,
                  ),
                ],
              );
  }
}
