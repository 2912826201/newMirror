import 'package:flutter/foundation.dart';
import 'package:mirror/data/dto/token_dto.dart';

/// token_notifier
/// Created by yangjiayi on 2020/11/23.

class TokenNotifier with ChangeNotifier {
  TokenNotifier(this._token);

  TokenDto _token;

  TokenDto get token => _token;

  void setToken(TokenDto token) {
    _token = token;
    notifyListeners();
  }
}
