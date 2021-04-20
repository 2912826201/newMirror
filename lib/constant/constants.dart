/// constants
/// Created by yangjiayi on 2021/1/11.

//视频和图片的最大最小宽高比 1.9:1 和 4:5
const double maxMediaRatio = 1.9;
const double minMediaRatio = 0.8;

//录制视频最短及最长时长 单位秒
const int minRecordVideoDuration = 1;
const int maxRecordVideoDuration = 60;

//聊天界面每次获取的记录是多少条
const int chatAddHistoryMessageCount=20;

//录音最长时长 单位秒
const int maxRecordVoiceDuration=60;
const int minRecordVoiceDuration=1;

//缩略图尺寸
const int maxImageSizeSmall = 150;
const int maxImageSizeMedium = 250;

//截图保存尺寸
const double cropImageSize = 1080.0;