import 'package:fluro/fluro.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/token_model.dart';

/// application
/// Created by yangjiayi on 2020/11/14.

class Application {
  static FluroRouter router;

  static TokenDto token;

  static String hintText = "";

  static TokenModel tempToken;

  static ProfileDto profile;
}