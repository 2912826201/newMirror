import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mirror/api/qiniu_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/data/database/download_db_helper.dart';
import 'package:mirror/data/dto/download_dto.dart';
import 'package:mirror/data/model/upload/qiniu_token_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:sy_flutter_qiniu_storage/sy_flutter_qiniu_storage.dart';
import 'package:uuid/uuid.dart';

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

  //===========================上传部分end===========================

  //获取视频第一帧的图片
  static String getVideoFirstPhoto(String videoUrl) {
    return videoUrl + "?vframe/jpg/offset/1";
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

  Future<String> download(String url, Function(String taskId, int received, int total) onProgressListener) async {
    String taskId = Uuid().v4();
    String fileName = url.split("/").last;
    String filePath = "${AppConfig.getAppDownloadDir()}/$fileName";
    return await Dio().download(url, filePath, deleteOnError: true, onReceiveProgress: (received, total) {
      onProgressListener(taskId, received, total);
    }).then((response) {
      //当下载完成时去更新数据库
      if (response.statusCode == HttpStatus.ok) {
        DownloadDBHelper().insertDownload(taskId, url, filePath);
        return taskId;
      } else {
        return null;
      }
    }).catchError((e) {
      return null;
    });
  }
//===========================下载部分end===========================
}
