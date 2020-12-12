import 'dart:io';
import 'dart:typed_data';

import 'package:mirror/api/qiniu_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/data/model/upload/qiniu_token_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:sy_flutter_qiniu_storage/sy_flutter_qiniu_storage.dart';

/// file_util
/// Created by yangjiayi on 2020/12/9.

class FileUtil {
  Future<QiniuTokenModel> _getQiniuToken(int type) async {
    return requestQiniuToken(type);
  }

  // 当上传失败时返回的是null
  Future<UploadResults> _upload(
      List<File> fileList, int type, Function(String path, double percent) progressCallback) async {
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
    for (File file in fileList) {
      // 设置监听
      syStorage.onChanged().listen((dynamic percent) {
        double p = percent;
        progressCallback(file.path, p);
      });
      // 生成文件名
      String key = _genKey(file);
      // 上传文件
      UploadResult result = await syStorage.upload(file.path, token.upToken, key);
      print("&@@@@@@@@@@@@@@${file.path}");
      print(result);
      UploadResultModel resultModel = UploadResultModel();
      resultModel.isSuccess = result.success;
      resultModel.error = result.error;
      resultModel.filePath = file.path;
      resultModel.url = token.domain + "/" + key;
      uploadResults.resultMap[file.path] = resultModel;
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

  Future<UploadResults> uploadFiles(List<File> fileList, Function(String path, double percent) progressCallback) {
    return _upload(fileList, 0, progressCallback);
  }

  Future<UploadResults> uploadMedias(List<File> fileList, Function(String path, double percent) progressCallback) {
    return _upload(fileList, 1, progressCallback);
  }

  Future<UploadResults> uploadPics(List<File> fileList, Function(String path, double percent) progressCallback) {
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
}
