import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/api/qiniu_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/database/download_db_helper.dart';
import 'package:mirror/data/dto/download_dto.dart';
import 'package:mirror/data/model/upload/qiniu_token_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/util/chunk_download.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'string_util.dart';

/// file_util
/// Created by yangjiayi on 2020/12/9.

//七牛的视频第一帧是视频地址后加上?vframe/jpg/offset/1
//七牛的瘦身图片--初级-?imageslim

const String downloadPortName = "downloader_send_port";

const int downloadTypeCommon = 0;
const int downloadTypeCourse = 1;

class FileUtil {
  //===========================上传部分start===========================
  Future<QiniuTokenModel> _getQiniuToken(int type) async {
    return requestQiniuToken(type);
  }

  // 当上传失败时返回的是null
  Future<UploadResults> _upload(List<File> fileList, int type, Function(double percent) progressCallback) async {
    UploadResults uploadResults = UploadResults();
    QiniuTokenModel token = await _getQiniuToken(type);
    if (token == null) {
      print("未取到上传token");
      uploadResults.isSuccess = false;
      return uploadResults;
    }
    //预先设为成功 当有失败文件时则改为失败
    uploadResults.isSuccess = true;

    final storage = Storage();
    int _finishedCount = 0;
    print("上传文件:${fileList.length}");
    for (int i = 0; i < fileList.length; i++) {
      PutController putController = PutController();
      // 设置进度监听
      putController.addProgressListener((double percent) {
        print("单文件进度））））））））））））））$percent");
        double totalPercent = (1.0 * _finishedCount + percent) / (1.0 * fileList.length);
        print("总进度））））））））））））））$totalPercent");
        if (percent == 1.0) {
          _finishedCount++;
        }
        progressCallback(totalPercent);
      });
      // 设置状态监听
      StorageStatus fileStatus;
      putController.addStatusListener((StorageStatus status) {
        fileStatus = status;
      });
      // 生成文件名
      String key = await _genKey(fileList[i]);
      // 上传文件
      UploadResultModel resultModel = UploadResultModel();
      resultModel.isSuccess = false;
      resultModel.error = "";
      try {
        await storage.putFile(
          fileList[i],
          token.upToken,
          options: PutOptions(
            key: key,
            controller: putController,
          ),
        );
        if (fileStatus != null && fileStatus == StorageStatus.Success) {
          resultModel.isSuccess = true;
        }
      } catch (error) {
        if (error is StorageError) {
          switch (error.type) {
            case StorageErrorType.CONNECT_TIMEOUT:
              print('发生错误: 连接超时');
              break;
            case StorageErrorType.SEND_TIMEOUT:
              print('发生错误: 发送数据超时');
              break;
            case StorageErrorType.RECEIVE_TIMEOUT:
              print('发生错误: 响应数据超时');
              break;
            case StorageErrorType.RESPONSE:
              print('发生错误: ${error.message}');
              break;
            case StorageErrorType.CANCEL:
              print('发生错误: 请求取消');
              break;
            case StorageErrorType.UNKNOWN:
              print('发生错误: 未知错误');
              break;
            case StorageErrorType.NO_AVAILABLE_HOST:
              print('发生错误: 无可用 Host');
              break;
            case StorageErrorType.IN_PROGRESS:
              print('发生错误: 已在队列中');
              break;
          }
        } else {
          print('发生错误: ${error.toString()}');
        }
        resultModel.isSuccess = false;
        resultModel.error = error.toString();
      }

      // print("&@@@@@@@@@@@@@@${file.path}");
      // print(result);
      resultModel.filePath = fileList[i].path;
      resultModel.url = token.domain + "/" + key;
      uploadResults.resultMap[fileList[i].path] = resultModel;
      if (resultModel.isSuccess == false) {
        // 只要有一个文件上传失败就将总结果设为失败 成功不需要更改状态
        uploadResults.isSuccess = false;
      }
    }
    // 保险起见 检查一下数量
    if (uploadResults.resultMap.length < fileList.length) {
      uploadResults.isSuccess = false;
    }
    return uploadResults;
  }

  Future<UploadResults> uploadFiles(List<File> fileList, Function(double percent) progressCallback) {
    return _upload(fileList, 0, progressCallback);
  }

  Future<UploadResults> uploadMedias(List<File> fileList, Function(double percent) progressCallback) {
    return _upload(fileList, 1, progressCallback);
  }

  Future<UploadResults> uploadPics(List<File> fileList, Function(double percent) progressCallback) {
    return _upload(fileList, 2, progressCallback);
  }

  Future<String> _genKey(File file) async {
    String ext = "";
    if (file.path.contains('.')) {
      ext = '.' + file.path.split('.').last;
    }
    //有可能是在完善用户资料前上传的头像 这里uid要做判断
    int uid;
    if (Application.token.anonymous == 1 && Application.tempToken != null) {
      uid = Application.tempToken.uid;
    } else {
      uid = Application.token.uid;
    }
    String fileMd5 = await StringUtil.calculateMD5SumAsyncWithPlugin(file.path);

    // return "ifapp/$uid/" + DateTime.now().millisecondsSinceEpoch.toString() + ext;
    return "ifapp/$uid/" + fileMd5 + ext;
  }

  Future<File> writeImageDataToFile(Uint8List imageData, String fileName, {bool isPublish = false}) async {
    // 由入参来控制文件名 避免同一时间生成的文件名相同
    String filePath = (isPublish ? AppConfig.getAppPublishDir() : AppConfig.getAppPicDir()) + "/" + fileName + ".png";
    File file = File(filePath);
    file.writeAsBytesSync(imageData);
    return file;
  }

  //===========================上传部分end===========================

  //获取视频第一帧的图片
  static String getVideoFirstPhoto(String videoUrl) {
    if (videoUrl == null || videoUrl.length < 1) {
      return videoUrl;
    }
    return "$videoUrl?vframe/jpg/offset/1";
  }

  //获取瘦身后的图片
  static String getImageSlim(String imageUrl) {
    if (imageUrl == null || imageUrl.length < 1) {
      return imageUrl;
    }
    if (imageUrl.contains("?")) {
      return "$imageUrl|imageslim";
    } else {
      return "$imageUrl?imageslim";
    }
  }

  //获取限制尺寸的图片
  static String _getMaxSizeImage(String imageUrl, int maxHeight, int maxWidth) {
    if (imageUrl == null || imageUrl.length < 1) {
      return imageUrl;
    }
    if (imageUrl.contains("?")) {
      return "$imageUrl|imageView2/0/w/$maxWidth/h/$maxHeight|imageslim";
    } else {
      return "$imageUrl?imageView2/0/w/$maxWidth/h/$maxHeight|imageslim";
    }
  }

  static String getSmallImage(String imageUrl) {
    return _getMaxSizeImage(imageUrl, maxImageSizeSmall, maxImageSizeSmall);
  }

  static String getThumbnail(String imageUrl) {
    return _getMaxSizeImage(imageUrl, maxImageThumbnail, maxImageThumbnail);
  }

  static String getMediumImage(String imageUrl) {
    return _getMaxSizeImage(imageUrl, maxImageSizeMedium, maxImageSizeMedium);
  }

  static String getLargeImage(String imageUrl) {
    return _getMaxSizeImage(imageUrl, maxImageSizeLarge, maxImageSizeLarge);
  }

  static String getLargeVideoFirstImage(String videoUrl) {
    return _getMaxSizeImage(getVideoFirstPhoto(videoUrl), maxImageSizeLarge, maxImageSizeLarge);
  }

  static String getSlimVideoFirstImage(String videoUrl) {
    return getImageSlim(getVideoFirstPhoto(videoUrl));
  }

  //===========================下载部分start===========================
  //获取指定url文件下载后的文件路径 可用来判断是否已下载
  Future<String> getDownloadedPath(String url) async {
    //取最近一条已完成的数据
    List<DownloadDto> downloadList = await DownloadDBHelper().queryDownload(url, limit: 1);

    if (downloadList.isEmpty) {
      //记录本身都不存在 则返回null 哪怕文件存在 但已无法访问到该文件 所以需要重新下载
      return null;
    } else {
      //记录存在 再检查文件在不在
      if (File(downloadList.first.filePath).existsSync()) {
        return downloadList.first.filePath;
      } else {
        return null;
      }
    }
  }

  //任务和文件一起删了
  removeDownloadTask(String url) async {
    List<DownloadDto> downloadList = await DownloadDBHelper().queryDownload(url);

    downloadList.forEach((element) {
      File file = File(element.filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    await DownloadDBHelper().clearDownloadByUrl(url);
  }

  //需要对下载文件类型做路径区分处理
  Future<DownloadDto> download(String url, Function(String taskId, int received, int total) onProgressListener,
      {int type = downloadTypeCommon}) async {
    String taskId = Uuid().v4();
    String fileName = url.split("/").last;
    List<String> strs = fileName.split(".");
    if (strs.length > 1) {
      fileName = StringUtil.generateMd5(fileName) + "." + strs.last;
    } else {
      fileName = StringUtil.generateMd5(fileName);
    }
    String filePath;
    switch (type) {
      case downloadTypeCommon:
        filePath = "${AppConfig.getAppDownloadDir()}/$fileName";
        break;
      case downloadTypeCourse:
        filePath = "${AppConfig.getAppCourseDir()}/$fileName";
        break;
      default:
        filePath = "${AppConfig.getAppDownloadDir()}/$fileName";
        break;
    }

    DownloadDto dto = DownloadDto();
    dto.taskId = taskId;
    dto.url = url;
    dto.filePath = filePath;

    return await Dio().download(url, filePath, deleteOnError: true, onReceiveProgress: (received, total) {
      onProgressListener(taskId, received, total);
    }).then((response) {
      //当下载完成时去更新数据库
      if (response.statusCode == HttpStatus.ok) {
        DownloadDBHelper().insertDownload(taskId, url, filePath);
        return dto;
      } else {
        return null;
      }
    }).catchError((e) {
      return null;
    });
  }

  ///断点续传
  Future<DownloadDto> chunkDownLoad(
      BuildContext context, String url, Function(String taskId, int received, int total) onProgressListener,
      {CancelToken cancelToken, Dio dio, int type = downloadTypeCommon}) async {
    String taskId = Uuid().v4();
    String fileName = url.split("/").last;
    List<String> strs = fileName.split(".");
    if (strs.length > 1) {
      fileName = StringUtil.generateMd5(fileName) + "." + strs.last;
    } else {
      fileName = StringUtil.generateMd5(fileName);
    }
    String filePath;
    switch (type) {
      case downloadTypeCommon:
        filePath = "${AppConfig.getAppDownloadDir()}/$fileName";
        break;
      case downloadTypeCourse:
        filePath = "${AppConfig.getAppCourseDir()}/$fileName";
        break;
      default:
        filePath = "${AppConfig.getAppDownloadDir()}/$fileName";
        break;
    }
    DownloadDto dto = DownloadDto();
    dto.taskId = taskId;
    dto.url = url;
    dto.filePath = filePath;
    print("start");
    return await ChunkDownLaod.downloadWithChunks(url, filePath, cancelToken: cancelToken,
            onReceiveProgress: (received, total) {
      onProgressListener(taskId, received, total);
    }, dio: dio)
        .then((response) {
      print('-------------------------下载完成2${response.statusCode}');
      if (response.statusCode == HttpStatus.ok) {
        DownloadDBHelper().insertDownload(taskId, url, filePath);
        return dto;
      } else {
        return null;
      }
    });
  }

  // base64转file
  static Future<File> createFileFromString(String base64Str, String path) async {
    Uint8List bytes = base64Decode(base64Str);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File("$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + path);
    await file.writeAsBytes(bytes);
    return file;
  }

  // 获取文件后缀名
  static String getFileSuffix(String imageFilePath) {
    List<String> pathList = [];
    String path = "";
    for (int i = imageFilePath.length - 1; i >= 0; i--) {
      pathList.add(imageFilePath[i]);
      if (imageFilePath[i] == '.') {
        break;
      }
    }
    pathList = pathList.reversed.toList();
    pathList.forEach((v) {
      path += v;
    });
    return path;
  }

  static saveNetworkImageCache(String imageUrl) async {
    try {
      if (imageUrl == null) throw '保存失败，图片不存在！';

      if (!StringUtil.isURL(imageUrl)) throw '不是网址';

      /// 权限检测
      bool isGranted = (await Permission.storage.status)?.isGranted;
      if (!isGranted) {
        throw '无法存储图片，请先授权！';
      }

      /// 保存的图片数据
      Uint8List imageBytes;

      /// 保存网络图片
      CachedNetworkImage image = CachedNetworkImage(imageUrl: imageUrl);
      DefaultCacheManager manager = image.cacheManager ?? DefaultCacheManager();
      Map<String, String> headers = image.httpHeaders;
      File file = await manager.getSingleFile(
        image.imageUrl,
        headers: headers,
      );
      imageBytes = await file.readAsBytes();
      writeImageDataToFileChatPage(imageBytes, StringUtil.generateMd5(imageUrl));
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<File> writeImageDataToFileChatPage(Uint8List imageData, String fileName) async {
    if (imageData != null) {
      // 由入参来控制文件名 避免同一时间生成的文件名相同
      String filePath = AppConfig.getAppChatImageDir() + "/" + fileName + ".png";
      File file = File(filePath);
      file.writeAsBytesSync(imageData);
      return file;
    }
    return null;
  }

  static bool isHaveChatImageFile(String imageUrl) {
    String path = getChatImagePath(imageUrl);
    if (path == null || path.length < 1) {
      return false;
    }
    File file = File(path);
    return file.existsSync();
  }

  static getChatImagePath(String imageUrl) {
    return AppConfig.getAppChatImageDir() + "/" + StringUtil.generateMd5(imageUrl) + ".png";
  }
//===========================下载部分end===========================
}
