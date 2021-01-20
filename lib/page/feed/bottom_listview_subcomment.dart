import 'package:flutter/cupertino.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/feed/bottom_listview_subcomment_item.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_bottom_sheet.dart';
import 'package:mirror/util/string_util.dart';
import 'package:provider/provider.dart';
class BottomListViewSubComment extends StatefulWidget {
  int listIndex;
  int feedId;
  int type;
  List<CommentDtoModel> replys;
  CommentDtoModel commentDtoModel;
  CommentDtoModel comment;
  BottomListViewSubComment({Key key,this.comment,this.type,this.replys, this.commentDtoModel, this.listIndex, this.feedId}) : super(key: key);

  BottomListViewSubCommentState createState() => BottomListViewSubCommentState();
}

class BottomListViewSubCommentState extends State<BottomListViewSubComment> {
  // 请求页数
  int pageCount = 0;

  // 记录initCount的初始值；
  int initNum;

  @override
  // 初始化赋值
  void initState() {
    print(
      "初始化数据了+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    if (widget.commentDtoModel.initCount == null) {
      widget.commentDtoModel.initCount = widget.commentDtoModel.replyCount;
      widget.commentDtoModel.isShowHiddenButtons = false;
      widget.commentDtoModel.isClickHideButton = false;
    }
    if(widget.type==1){
      if(widget.commentDtoModel.id==widget.comment.targetId){
        loadData();
      }
    }
  }

  // 隐藏数据
  hideData() {
    widget.commentDtoModel.replys.clear();
    // 切换按钮
    widget.commentDtoModel.isShowHiddenButtons = false;

    widget.commentDtoModel.isClickHideButton = true;
    // 恢复总条数
    widget.commentDtoModel.initCount = widget.commentDtoModel.replyCount;
    // 请求页数还原
    pageCount = 0;
    setState(() {});
  }

  // 加载数据
  loadData() async {
    pageCount += 1;
    if(widget.type==1){
    if(widget.comment!=null){
      if(widget.commentDtoModel.isClickHideButton&&pageCount==1){
        if(widget.commentDtoModel.id==widget.comment.targetId){
          widget.replys.insert(0, context.read<FeedMapNotifier>().childModel);
        }
      }
    }
    }
    // 总条数大于三每次点击取三条
    if (widget.commentDtoModel.initCount > 4) {
      Map<String, dynamic> model =
      await queryListByHot2(targetId: widget.commentDtoModel.id, targetType: 2, page: this.pageCount, size: 4);
      if (model["list"] != null) {
        model["list"].forEach((v) {
          if(widget.comment!=null){
            if(CommentDtoModel.fromJson(v).id!=widget.comment.id){
              widget.replys.add(CommentDtoModel.fromJson(v));
              widget.commentDtoModel.initCount -= 1;
            }
          }else{
            widget.replys.add(CommentDtoModel.fromJson(v));
            widget.commentDtoModel.initCount -= 1;
          }
        });

      }
    } else {
      // 总条数不足三条把剩下条数取完，切换按钮
      if (widget.commentDtoModel.initCount > 0) {
        Map<String, dynamic> model = await queryListByHot2(
          targetId: widget.commentDtoModel.id,
          targetType: 2,
          page: this.pageCount,
          size: widget.commentDtoModel.initCount);
        if (model["list"] != null) {
          model["list"].forEach((v) {
            if(widget.comment!=null){
              if(CommentDtoModel.fromJson(v).id!=widget.comment.id){
                widget.replys.add(CommentDtoModel.fromJson(v));
              }
            }else{
              widget.replys.add(CommentDtoModel.fromJson(v));
            }
          });
        }
        widget.commentDtoModel.isShowHiddenButtons = true;
      }
    }
    setState(() {});
  }

  // 切换按钮
  toggleButton() {
    // 是否显示隐藏按钮
    if (widget.commentDtoModel.isShowHiddenButtons) {
      return GestureDetector(
        child: Text("─── 隐藏回复", style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
        onTap: () {
          hideData();
        },
      );
    } else {
      print("按钮initCount    ------${widget.commentDtoModel.initCount}");
      return GestureDetector(
        child: Text("─── 查看${StringUtil.getNumber(widget.commentDtoModel.initCount)}条回复",
          style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
        onTap: () {
          loadData();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12, left: 57),
      padding: EdgeInsets.only(left: 16,right: 16),
      // color: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 子评论
          // Offstage(
          //   offstage:widget.commentDtoModel.replys.isEmpty,
          // !widget.commentDtoModel.isShowAllComment,
          // child: AnimationLimiter(
          // ListView头部有一段空白区域，是因为当ListView没有和AppBar一起使用时，头部会有一个padding，为了去掉padding，可以使用MediaQuery.removePadding
          MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child:
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.replys.length,
              itemBuilder: (context, index) {
                return BottomListViewSubCommentListItem(
                  comment:widget.comment,
                  model: widget.replys[index],
                  subIndex: index,
                  mainIndex: widget.listIndex,
                  feedId: widget.feedId,
                  commentDtoModel: widget.commentDtoModel,
                );
              }
            )
          ),

          // 查看按钮和隐藏按钮的切换
          Offstage(
            offstage: widget.commentDtoModel.isShowInteractiveButton == false,
            child: toggleButton(),
          ),
          // 间距
          SizedBox(
            height: 12,
          )
        ],
      ));
  }
}
