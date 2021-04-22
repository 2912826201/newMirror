import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/data/model/upload/chunk_download_model.dart';
import 'package:mirror/util/toast_util.dart';

///分段下载,断点续传，使用缓存管理下载不同下载任务
class ChunkDownLaod {
  static Future<Response> downloadWithChunks(url, savePath,
      //-----------------------------------需要取消下载可传cancelToken
      // -----------需要其他自定义配置dio-------是否需要分段下载needChunkDownLoad
      {ProgressCallback onReceiveProgress,
      CancelToken cancelToken,
      Dio dio,
      bool needChunkDownLoad = true}) async {
    const firstChunkSize = 102;
    const int maxChunk = 6;
    int start = 0;
    int reserved = 0;
    ChunkDownLaodModel chunkDownLaodModel;
    if (dio == null) {
      dio = Dio();
    }
    if (cancelToken == null) {
      cancelToken = CancelToken();
    }

    ///回调的进度条会根据固定索引的值回调进度
    createCallback(no) {
      return (int received, _) {
        chunkDownLaodModel.downLoadProgress[no] = received;
        if (onReceiveProgress != null && chunkDownLaodModel.downLoadTotal != 0) {
          onReceiveProgress(
              chunkDownLaodModel.downLoadProgress.reduce((a, b) => a + b), chunkDownLaodModel.downLoadTotal);
        }
      };
    }
    ///合并文件
    Future mergeTempFiles(chunk) async {
      print('-------------合并文件----------mergeTempFiles');
      File f = File(savePath + "chunk0");
      IOSink ioSink = f.openWrite(mode: FileMode.writeOnlyAppend);
      for (int i = 1; i < chunk + 1; ++i) {
        File _f = File(savePath + "chunk$i");
        await ioSink.addStream(_f.openRead());
        await _f.delete();
      }
      await ioSink.close();
      await f.rename(savePath).then((value) {
        value.stat().then((value) => print('========文件信息---------------$value'));
      });
    }

    ///这里用递归的方式让下载任务按顺序执行，便于记录管理
    Future<Response> downloadChunk(url, reStart, end, no, maxNo) async {
      print('-------------------start$reStart --    end$end     --no$no');
      chunkDownLaodModel.downLoadProgress.add(0);
      return dio
          .download(url, savePath + "chunk$no",
              onReceiveProgress: createCallback(no),
              deleteOnError: false,
              options: Options(
                //分段下载
                headers: {"range": "bytes=$reStart-$end"},
              ),
              cancelToken: cancelToken)
          .then((value) {
        if (no == 0) {
          return value;
        }
        maxNo--;
        print('--------------------------no$no');
        //下载完成记录下载成功过的byte值以及第几段
        chunkDownLaodModel.downLoadChunkEnd = end;
        chunkDownLaodModel.downLoadChunk = no;
        AppPrefs.setDownLoadChunkData(url, jsonEncode(chunkDownLaodModel));
        if (maxNo > 0) {
          print(
              '---这是第${no + 1}次请求-----从$end开始-----到${end + chunkDownLaodModel.downLoadChunkSize}结束--------还剩$maxNo次请求-----文件总长${chunkDownLaodModel.downLoadTotal}');
          return downloadChunk(url, end + 1, end + chunkDownLaodModel.downLoadChunkSize, no + 1, maxNo);
        } else {
          return Response(
            statusCode: 200,
            statusMessage: "下载完成",
            data: "下载完成",
          );
        }
      }).catchError((e){
        if(CancelToken.isCancel(e)){
          print('-----------------------下载取消');
        }
      });
    }

    ///是否需要分段下载
    if (needChunkDownLoad) {
      chunkDownLaodModel = ChunkDownLaodModel();
      String oldData = AppPrefs.getDwonLaodChunkData(url);
      print('----------------------oldData$oldData');
      if (oldData != null) {
        chunkDownLaodModel = ChunkDownLaodModel.fromJson(jsonDecode(oldData));
        start = chunkDownLaodModel.downLoadChunkEnd;
        print(
            '------------- chunkDownLaodModel.downLoadChunkEnd-----$start  ---downLoadProgress${chunkDownLaodModel.downLoadProgress}');
        await downloadChunk(url, start + 1, start + chunkDownLaodModel.downLoadChunkSize,
            chunkDownLaodModel.downLoadChunk + 1, maxChunk - chunkDownLaodModel.downLoadChunk);
      } else {
        chunkDownLaodModel.downLoadProgress = [];
        Response response = await downloadChunk(url, 0, firstChunkSize, 0, 1);
        if (response.statusCode == 206) {
          chunkDownLaodModel.downLoadTotal =
              int.parse(response.headers.value(HttpHeaders.contentRangeHeader).split("/").last);
          reserved =
              chunkDownLaodModel.downLoadTotal - int.parse(response.headers.value(HttpHeaders.contentLengthHeader));
          chunkDownLaodModel.downLoadChunkSize = (reserved / maxChunk).ceil();
          start = firstChunkSize;
          await downloadChunk(url, start + 1, start + chunkDownLaodModel.downLoadChunkSize + 1, 1, maxChunk);
        }
      }

      ///这是合并文件，通过有序的命名拿到切割下载的文件，合并成最终想要的
      mergeTempFiles(maxChunk);
      await AppPrefs.removeDownLadTask(url);
      return Response(
        statusCode: 200,
        statusMessage: "下载完成",
        data: "下载完成",
      );
    }
    return await Dio().download(url, savePath, deleteOnError: true, onReceiveProgress: (received, total) {
      onReceiveProgress(received, total);
    }, cancelToken: cancelToken);
  }
}
