import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mirror/api/qiniu_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/data/model/upload/qiniu_token_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:sy_flutter_qiniu_storage/sy_flutter_qiniu_storage.dart';

/// file_util
/// Created by yangjiayi on 2020/12/9.

//七牛的视频第一帧是视频地址后加上?vframe/jpg/offset/1

const String downloadPortName = "downloader_send_port";

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

    final syStorage = SyFlutterQiniuStorage();
    int _finishedCount = 0;
    // 设置监听
    syStorage.onChanged().listen((dynamic percent) {
      double p = percent;
      print("单文件进度））））））））））））））$percent");
      double totalPercent = (1.0 * _finishedCount + p) / (1.0 * fileList.length);
      print("总进度））））））））））））））$totalPercent");
      if (p == 1.0) {
        _finishedCount++;
      }
      progressCallback(totalPercent);
    });
    for (int i = 0; i < fileList.length; i++) {
      // 生成文件名
      String key = _genKey(fileList[i]);
      // 上传文件
      UploadResult result = await syStorage.upload(fileList[i].path, token.upToken, key);
      // print("&@@@@@@@@@@@@@@${file.path}");
      // print(result);
      UploadResultModel resultModel = UploadResultModel();
      resultModel.isSuccess = result.success;
      resultModel.error = result.error;
      resultModel.filePath = fileList[i].path;
      resultModel.url = token.domain + "/" + key;
      uploadResults.resultMap[fileList[i].path] = resultModel;
      if (result.success == false) {
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

  String _genKey(File file) {
    String ext = "";
    if (file.path.contains('.')) {
      ext = '.' + file.path.split('.').last;
    }
    return "ifapp/${Application.token.uid}/" + DateTime.now().millisecondsSinceEpoch.toString() + ext;
  }

  cancelUpload() {
    SyFlutterQiniuStorage.cancelUpload();
  }

  Future<File> writeImageDataToFile(Uint8List imageData, String fileName) async {
    // 由入参来控制文件名 避免同一时间生成的文件名相同
    String filePath = AppConfig.getAppPicDir() + "/" + fileName + ".jpg";
    return File(filePath).writeAsBytes(imageData);
  }

  Future<UploadResult> upload(SyFlutterQiniuStorage storage, String filepath, String token, String key) async {
    storage.upload(filepath, token, key).then((value) => value);
  }

  //===========================上传部分end===========================

  //获取视频第一帧的图片
  static String getVideoFirstPhoto(String videoUrl) {
    return videoUrl + "?vframe/jpg/offset/1";
  }

  //===========================下载部分start===========================
  //下载的全局回调方法 必须为static
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName(downloadPortName);
    send.send([id, status, progress]);
  }

  //获取指定url文件下载后的文件路径 可用来判断是否已下载
  Future<String> getDownloadedPath(String url) async {
    //取最近一条已完成的数据
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE status = 3 AND url = '$url' ORDER BY time_created DESC LIMIT 1");
    if (tasks.isEmpty) {
      //记录本身都不存在 则返回null 哪怕文件存在 但已无法访问到该文件 所以需要重新下载
      return null;
    } else {
      //记录存在 再检查文件在不在
      String path = tasks.first.savedDir + "/" + tasks.first.filename;
      if (File(path).existsSync()) {
        return path;
      } else {
        return null;
      }
    }
  }

  //任务和文件一起删了 下载器可能没有权限 所以自己删除
  removeDownloadTask(String url) async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(query: "SELECT * FROM task WHERE url = '$url'");
    tasks.forEach((element) {
      FlutterDownloader.remove(taskId: element.taskId);
      File file = File(element.savedDir + "/" + element.filename);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });
  }

  Future<String> download(String url, bool showNotification, bool openFileFromNotification) async {
    return await FlutterDownloader.enqueue(
        url: url,
        savedDir: AppConfig.getAppDownloadDir(),
        showNotification: showNotification,
        openFileFromNotification: openFileFromNotification);
  }
//===========================下载部分end===========================
}
