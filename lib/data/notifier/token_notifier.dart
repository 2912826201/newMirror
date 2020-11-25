import 'package:flutter/foundation.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/token_dto.dart';

/// token_notifier
/// Created by yangjiayi on 2020/11/23.

class TokenNotifier with ChangeNotifier {
  TokenNotifier(this._token);

  TokenDto _token;

  TokenDto get token => _token;

  bool get isLoggedIn => _token != null && _token.anonymous == 0 && _token.isPhone == 1 && _token.isPerfect == 1;

  void setToken(TokenDto token) {
    _token = token;
    //要将全局的token赋值
    Application.token = token;
    notifyListeners();
  }
}
