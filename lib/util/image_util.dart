class ImageUtil {
  //第一个数是X 第二个数是Y
  static const proportion_one_one = "1:1";
  static const proportion_four_three = "4:3";
  static const proportion_three_four = "3:4";
  static const proportion_sixteen_nine = "16:9";
  static const proportion_nine_sixteen = "9:16";

  void getImageProportion(int width, int height) {}

  //根据比例获取宽高
  static List<double> getImageWidthAndHeight(double w, double h) {
    double ratio = w / h;
    double width;
    double height;
    if (ratio < 0.4) {
      width = 168;
      height = 420;
    } else if (ratio >= 0.4 && ratio <= 0.424) {
      width = 168;
      height = 168 / ratio;
    } else if (ratio > 0.424 && ratio < 1) {
      width = 396 * ratio;
      height = 396;
    } else if (ratio >= 1 && ratio < 1 / 0.424) {
      height = 396 * (1 / ratio);
      width = 396;
    } else if (ratio >= 1 / 0.424 && ratio < 1 / 0.4) {
      height = 168;
      width = 168 / (1 / ratio);
    } else if (ratio >= 1 / 0.4) {
      height = 168;
      width = 420;
    }
    width /= 3;
    height /= 3;
    List<double> widthOrHeight = <double>[];
    widthOrHeight.add(width);
    widthOrHeight.add(height);
    return widthOrHeight;
  }
}
