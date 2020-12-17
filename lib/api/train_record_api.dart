import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/upload/weight_model.dart';

const String WEIGHT_RECORD = "/appuser/web/user/getWeightRecords";

Future<WeightModel> requestRongCloudToken(int page,int size) async {
  BaseResponseModel responseModel = await requestApi(WEIGHT_RECORD, {"page":page,"size":size});
  if(responseModel.isSuccess){
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return WeightModel.fromJson(responseModel.data);
  }else {
    //TODO 这里实际需要处理失败
    return null;
  }
}