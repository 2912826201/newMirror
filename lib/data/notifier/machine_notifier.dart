import 'package:flutter/foundation.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/util/event_bus.dart';

/// machine_notifier
/// Created by yangjiayi on 2021/1/29.

class MachineNotifier with ChangeNotifier {
  MachineNotifier(this._machine);

  MachineModel _machine;

  MachineModel get machine => _machine;

  void setMachine(MachineModel machineModel) {
    _machine = machineModel;
    //要将全局的token赋值
    Application.machine = machineModel;
    if(machineModel!=null) {
      EventBus.init().post(msg: machineModel, registerName: GET_MACHINE_STATUS_INFO);
    }
    notifyListeners();
  }
}
