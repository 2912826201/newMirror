import 'dart:typed_data';

import 'package:amap_location_muka/amap_location_muka.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/size_transition_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

import '../release_page.dart';

// 发布动态输入框下的所有部件
class ReleaseFeedMainView extends StatefulWidget {
  ReleaseFeedMainView({this.permissions, this.selectedMediaFiles, this.pois, this.currentAddressInfo});

  PermissionStatus permissions;
  SelectedMediaFiles selectedMediaFiles;
  List<PeripheralInformationPoi> pois;
  Location currentAddressInfo;

  @override
  ReleaseFeedMainViewState createState() => ReleaseFeedMainViewState();
}

class ReleaseFeedMainViewState extends State<ReleaseFeedMainView> {
  // // 选择的地址
  // String seletedAddressText = "你在哪儿";

  // 是否显示推荐地址列表
  bool isShowList = true;

  // 展示勾选的索引
  int checkIndex = 0;

  // 传入选择地址
  PeripheralInformationPoi selectAddress = PeripheralInformationPoi();

  Widget _showDialog(BuildContext context) {
    return showAppDialog(context,
        title: "获取系统定位权限",
        info: "获取周边地址信息",
        cancel: AppDialogButton("取消", () {
          return true;
        }),
        confirm: AppDialogButton("去打开", () {
          AppSettings.openLocationSettings();
          return true;
        }));
  }

  // 选择地址
  seletedAddress(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        // 获取定位权限
        var status = await Permission.locationWhenInUse.status;

        ///尚未请求许可。请求权限
        //fixme 权限枚举变化
        // if (status == PermissionStatus.undetermined) {
        //   await Permission.locationWhenInUse.request();
        // }
        // 请求了许可但是未授权，弹窗提醒
        //fixme 权限枚举变化
        // if (status != PermissionStatus.granted && status != PermissionStatus.undetermined) {
        if (status.isGranted) {
          if (widget.currentAddressInfo != null) {
            AppRouter.navigateSearchOrLocationPage(context, checkIndex, selectAddress, widget.currentAddressInfo,
                (result) {
              PeripheralInformationPoi poi = result as PeripheralInformationPoi;
              return childrenACallBack(poi);
            });
          }
        } else {
          PermissionStatus status = await Permission.locationWhenInUse.request();
          if (status.isPermanentlyDenied) {
            _showDialog(context);
          } else if (status.isGranted) {
            AppRouter.navigateSearchOrLocationPage(context, checkIndex, selectAddress, widget.currentAddressInfo,
                (result) {
              PeripheralInformationPoi poi = result as PeripheralInformationPoi;
              return childrenACallBack(poi);
            });
          }
        }
        print("跳转选择地址页面");
      },
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
        height: 48,
        width: ScreenUtil.instance.screenWidthDp,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            context.watch<ReleaseFeedInputNotifier>().seletedAddressText != "你在哪儿"
                ? AppIcon.getAppIcon(AppIcon.location_feed, 24, color: AppColor.mainBlue)
                : AppIcon.getAppIcon(AppIcon.location_feed, 24, color: AppColor.black),
            const SizedBox(
              width: 12,
            ),
            Container(
              width: ScreenUtil.instance.width - 32 - 24 - 24 - 18,
              child: Text(
                context.watch<ReleaseFeedInputNotifier>().seletedAddressText,
                style: TextStyle(
                    fontSize: 16,
                    color: context.watch<ReleaseFeedInputNotifier>().seletedAddressText != "你在哪儿"
                        ? AppColor.mainBlue
                        : AppColor.textPrimary1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            AppIcon.getAppIcon(AppIcon.arrow_right_18, 18),
          ],
        ),
      ),
    );
  }

  // 推荐地址
  recommendAddress() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 12.5),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 7,
          itemBuilder: (context, index) {
            return addressItem(widget.pois[index], index);
          }),
    );
  }

  // 子页面回调
  childrenACallBack(PeripheralInformationPoi poi) {
    if (poi.name != "不显示所在位置") {
      isShowList = false;
      if (poi != null) {
        context.read<ReleaseFeedInputNotifier>().seletedAddressText = poi.name;
      }
      selectAddress = poi;
      checkIndex = 1;
      // 选择后就不展示附近推荐
      widget.pois.clear();
    } else {
      context.read<ReleaseFeedInputNotifier>().seletedAddressText = "你在哪儿";
      selectAddress = PeripheralInformationPoi();
      checkIndex = 0;
    }
    print("子页面回调${poi.toString()}");
    context.read<ReleaseFeedInputNotifier>().setPeripheralInformationPoi(poi);
    if (mounted) {
      setState(() {});
    }
  }

  // 推荐地址Item
  addressItem(PeripheralInformationPoi address, int index) {
    return GestureDetector(
        onTap: () {
          if (index != 6) {
            context.read<ReleaseFeedInputNotifier>().seletedAddressText = addressText(address, index);
            isShowList = false;
            selectAddress = address;
            checkIndex = 1;
            context.read<ReleaseFeedInputNotifier>().setPeripheralInformationPoi(address);
            // 选择后就不展示附近推荐
            widget.pois.clear();
            if (mounted) {
              setState(() {});
            }
          } else {
            AppRouter.navigateSearchOrLocationPage(context, checkIndex, selectAddress, widget.currentAddressInfo,
                (result) {
              PeripheralInformationPoi poi = result as PeripheralInformationPoi;
              return childrenACallBack(poi);
            });
          }
        },
        child: Container(
          // height: 23,
          margin: EdgeInsets.only(left: index == 0 ? 16 : 12, right: index == 6 ? 16 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          alignment: const Alignment(0, 0),
          decoration: BoxDecoration(
              color: AppColor.textHint.withOpacity(0.24), borderRadius: const BorderRadius.all(Radius.circular(3))),
          child: Text(
            addressText(address, index),
            style: const TextStyle(fontSize: 12),
          ),
        ));
  }

  // 地址
  addressText(PeripheralInformationPoi poi, int index) {
    String address;
    if (index != 6) {
      address = poi.name;
    }
    if (index == 6) {
      address = "查看更多";
    }
    return address;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.selectedMediaFiles != null && widget.selectedMediaFiles.list != null
            ? SeletedPhoto(
                selectedMediaFiles: widget.selectedMediaFiles,
              )
            : Container(),
        seletedAddress(context),
        widget.pois.isNotEmpty ? Offstage(offstage: isShowList == false, child: recommendAddress()) : Container()
      ],
    );
  }
}

// 图片
class SeletedPhoto extends StatefulWidget {
  SeletedPhoto({Key key, this.selectedMediaFiles}) : super(key: key);
  SelectedMediaFiles selectedMediaFiles;

  SeletedPhotoState createState() => SeletedPhotoState();
}

class SeletedPhotoState extends State<SeletedPhoto> with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  Map<int, AnimationController> animationMap = {};

  // 解析数据
  // resolveData() async {
  //   for (MediaFileModel model in widget.selectedMediaFiles.list) {
  //     if (model.croppedImage != null && model.croppedImageData == null) {
  //       ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
  //       Uint8List picBytes = byteData.buffer.asUint8List();
  //       model.croppedImageData = picBytes;
  //     }
  //   }
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  @override
  void initState() {
    // resolveData();
    if (widget.selectedMediaFiles.type != mediaTypeKeyVideo) {
      widget.selectedMediaFiles.list.forEach((element) {
        print("查看数据￥${element.toString()}");
        animationMap[element.croppedImage.hashCode] =
            AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
      });
    }
  }

  // 进入相册的添加视图
  addView() {
    if ((widget.selectedMediaFiles.type == mediaTypeKeyImage && widget.selectedMediaFiles.list.length < 9) ||
        (widget.selectedMediaFiles.type == null)) {
      return GestureDetector(
        key: ValueKey("addView"),
        onTap: () {
          int type = typeImage;
          if (widget.selectedMediaFiles.type == null) {
            type = typeImageAndVideo;
          } else if (widget.selectedMediaFiles.type == mediaTypeKeyImage) {
            type = typeImage;
          }
          int fixedWidth;
          int fixedHeight;
          if (widget.selectedMediaFiles.list.isNotEmpty) {
            fixedWidth = widget.selectedMediaFiles.list.first.sizeInfo.width;
            fixedHeight = widget.selectedMediaFiles.list.first.sizeInfo.height;
          }
          AppRouter.navigateToMediaPickerPage(
              context, 9 - widget.selectedMediaFiles.list.length, type, true, startPageGallery, false, (result) async {
            SelectedMediaFiles files = RuntimeProperties.selectedMediaFiles;
            if (true != result || files == null) {
              print("没有选择媒体文件");
              return;
            }
            if (widget.selectedMediaFiles.type == null) {
              widget.selectedMediaFiles.type = files.type;
            }
            RuntimeProperties.selectedMediaFiles = null;
            print(files.type + ":" + files.list.toString());
            // for (MediaFileModel model in files.list) {
            //   if (model.croppedImage != null && model.croppedImageData == null) {
            //     print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
            //     ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
            //     print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
            //     Uint8List picBytes = byteData.buffer.asUint8List();
            //     print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
            //     model.croppedImageData = picBytes;
            //   }
            // }
            if (files.type == mediaTypeKeyImage) {
              files.list.forEach((element) {
                animationMap[element.croppedImage.hashCode] =
                    AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
              });
            }
            widget.selectedMediaFiles.list.addAll(files.list);
            setState(() {});
            // context.read<ReleaseFeedInputNotifier>().setSelectedMediaFiles(widget.selectedMediaFiles);
          }, fixedWidth: fixedWidth, fixedHeight: fixedHeight, startCount: widget.selectedMediaFiles.list.length);
        },
        child: Container(
          margin: const EdgeInsets.only(left: 10, top: 9, right: 16),
          width: 86,
          height: 86,
          decoration: const BoxDecoration(
            color: AppColor.bgWhite,
            borderRadius: BorderRadius.all(Radius.circular(3.0)),
          ),
          child: Center(
            child: AppIcon.getAppIcon(AppIcon.add_gallery, 13),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      margin: const EdgeInsets.only(top: 14),
      child: _canPullReorderRow(),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    MediaFileModel model = widget.selectedMediaFiles.list[oldIndex];
    widget.selectedMediaFiles.list.removeAt(oldIndex);
    widget.selectedMediaFiles.list.insert(newIndex, model);
    setState(() {});
  }

  Widget _canPullReorderRow() {
    return ReorderableRow(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.selectedMediaFiles.list.map((e) {
          return  widget.selectedMediaFiles.type == mediaTypeKeyVideo ?
               listItem(widget.selectedMediaFiles.list.indexOf(e),key: ValueKey(e.filePath)) :
            SizeTransition(
              key: ValueKey(e.filePath),
              sizeFactor: Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
                parent: animationMap[e.croppedImage.hashCode],
                curve: Curves.fastOutSlowIn,
              )),
              axis: Axis.horizontal,
              axisAlignment: 1.0,
              child: listItem(widget.selectedMediaFiles.list.indexOf(e),fileModel: e)
          );

        }).toList(),
        onReorder: _onReorder,
        onNoReorder: (index) {
          print('${DateTime.now().toString().substring(5, 22)} 重新排序已取消。index :$index ');
        },
        footer: addView());
  }

  Widget listItem(int index,{Key key,MediaFileModel fileModel}) {
    return Container(
      key: key,
      width: 92,
      height: 92,
      margin: EdgeInsets.only(left: index == 0 ? 16 : 10),
      child: Stack(
        // overflow: Overflow.visible,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 9),
            width: 86,
            height: 86,
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(3.0))),
          ),
          Positioned(
            top: 9,
            left: 0,
            child: widget.selectedMediaFiles.type == mediaTypeKeyVideo
                ? Image.memory(
                    widget.selectedMediaFiles.list[index].thumb,
                    fit: BoxFit.cover,
                    width: 86,
                    height: 86,
                  )
                : widget.selectedMediaFiles.list[index].croppedImageData != null
                    ? Image.memory(
                        widget.selectedMediaFiles.list[index].croppedImageData,
                        fit: BoxFit.cover,
                        // color: Colors.,
                        width: 86,
                        height: 86,
                      )
                    : widget.selectedMediaFiles.list[index].croppedImage != null
                        ? RawImage(
                            image: widget.selectedMediaFiles.list[index].croppedImage,
                            width: 86,
                            height: 86,
                            fit: BoxFit.cover,
                          )
                        : widget.selectedMediaFiles.list[index].file != null
                            ? Image.file(
                                widget.selectedMediaFiles.list[index].file,
                                fit: BoxFit.cover,
                                width: 86,
                                height: 86,
                              )
                            : Container(
                                width: 86,
                                height: 86,
                                child: Center(
                                  child: CupertinoActivityIndicator(
                                    radius: 10,
                                  ),
                                ),
                              ),
          ),
          Positioned(
            right: 0,
            child: AppIconButton(
              svgName: AppIcon.delete,
              iconSize: 18,
              onTap: () {
                print("关闭");
                animationMap.forEach((key, value) {
                  print("查看唯一路径：${key}");
                });

                if (mounted) {
                  if (widget.selectedMediaFiles.list.length == 1) {
                    ToastShow.show(msg: "最后一个了", context: context, gravity: Toast.CENTER);
                    return;
                    // widget.selectedMediaFiles.type = null;
                  }
                  if (animationMap.containsKey(fileModel.croppedImage.hashCode)) {
                    animationMap[fileModel.croppedImage.hashCode].forward().then((value) {
                      animationMap.removeWhere((key, value) => key == fileModel.croppedImage.hashCode);
                      widget.selectedMediaFiles.list.removeWhere((element) => element == fileModel);
                    });
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
