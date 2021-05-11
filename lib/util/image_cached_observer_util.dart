import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class ImageCachedObserverUtil {
  //实现Flutter框架的图像缓存的单例。
  //    ///
  //    ///缓存由[ImageProvider]内部使用，通常不应
  //    ///直接访问。
  //    ///
  //    ///图像缓存是在启动期间由[createImageCache]创建的
  //    清除缓存。

  static clearPendingCacheImage() {
    PaintingBinding.instance.imageCache?.clear();
  }

  ///从两个基于磁盘文件的缓存系统中逐出映像
  /// [BaseCacheManager]作为[ImageProvider]的内存[ImageCache]。
  /// [url]由磁盘和内存缓存使用。 比例尺仅用于
  ///清除[ImageCache]中的图像。
  static clearCacheNetworkImageMemory(String url) {
    CachedNetworkImage.evictFromCache(url);
  }
}
