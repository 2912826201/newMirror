/// feed_tag
/// Created by yangjiayi on 2021/3/12.

const int feed_tag_type_location = 0;
const int feed_tag_type_course = 1;
const int feed_tag_type_activity = 2;

class FeedTagModel {
  int type;
  String text;
  int courseId;
  double longitude;
  double latitude;
  int activityId;
  String pic;
}
