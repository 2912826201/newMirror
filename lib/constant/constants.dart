/// constants
/// Created by yangjiayi on 2021/1/11.

//视频和图片的最大最小宽高比 1.9:1 和 4:5
const double maxMediaRatio = 1.9;
const double minMediaRatio = 0.8;

//录制视频最短及最长时长 单位秒
const int minRecordVideoDuration = 1;
const int maxRecordVideoDuration = 60;

//聊天界面每次获取的记录是多少条,最好每次最多20条，因为融云获取网络历史记录最多20条每次
const int chatAddHistoryMessageCount=20;

//录音最长时长 单位秒
const int maxRecordVoiceDuration=60;
const int minRecordVoiceDuration=1;

//缩略图尺寸
const int maxImageThumbnail = 10;
const int maxImageSizeSmall = 150;
const int maxImageSizeMedium = 250;
const int maxImageSizeLarge = 500;

//截图保存尺寸
const double cropImageSize = 1080.0;

//教练的账号
const int coachIsAccountId=1002885;

//系统账号范围
const int minSystemId=1;
const int maxSystemId=99;

//官方账号范围
const int minOfficialNumberId=100;
const int maxOfficialNumberId=999;
