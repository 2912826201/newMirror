/**
 * description
 *
 * @date 2020/11/30
 * @author:TaoSi
 */
import 'package:toast/toast.dart';

class ToastShow {
  static show(String msg, context){
    Toast.show(
        msg, //必填
        context, //必填
        duration: Toast.LENGTH_SHORT,
        gravity:  Toast.CENTER,
        backgroundRadius:4
    );
  }
}
