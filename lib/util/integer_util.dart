class IntegerUtil {
  static String formatIntegerCn(int data) {
    if (data > 100000000) {
      int title = data ~/ 100000000;
      int subtitle = data ~/ 10000000 % 10;
      return (title).toString() + (subtitle > 0 ? ".${subtitle}" : "") + "亿";
    } else if (data > 10000) {
      int title = data ~/ 10000;
      int subtitle = data ~/ 1000 % 10;
      return (title).toString() + (subtitle > 0 ? ".${subtitle}" : "") + "万";
    } else {
      return data.toString();
    }
  }

  //点赞的数量
  static String formatIntegerEn(int data) {
    if (data > 10000) {
      int title = data ~/ 10000;
      int subtitle = data ~/ 1000 % 10;
      return (title).toString() + (subtitle > 0 ? ".${subtitle}" : "") + "w";
    } else {
      return data.toString();
    }
  }
}
