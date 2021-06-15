import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/string_util.dart';

/// data : {"list":[{"id":1,"title":"浩哥教你做69的爱","picUrl":"http://devpic.aimymusic.com/ifcms/u%3D1145037121%2C2527894120%26fm%3D15%26gp%3D0.jpg","description":"浩哥教你做","coachId":1000000,"coachDto":{"uid":1000000,"phone":"13111858708","type":1,"subType":1,"nickName":"我太阳郑家斌s-a-o-比","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","status":2,"age":null,"isPerfect":1,"isPhone":1,"isLiving":0},"levelId":null,"levelDto":null,"targetId":null,"targetDto":null,"partDtos":null,"equipmentDtos":null,"times":null,"calories":null,"creatorId":1008611,"creatorNickname":"爸爸","coursewareId":1,"coursewareDto":{"id":1,"name":"开合跳减脂挑战","picUrl":"http://devpic.aimymusic.com/ifcms/12萌妹子.jpg","previewVideoUrl":"http://devmedia.aimymusic.com/ifcms/开合跳减脂挑战.mp4","description":"开合跳减脂挑战来袭","type":1,"times":303800,"calories":200,"levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"targetId":1,"targetDto":{"id":1,"type":2,"name":"减脂","updateTime":1607673809453,"ename":null},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null},{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}],"componentDtos":[{"id":1,"name":"热身","type":1,"times":96220,"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"calories":null,"isIdentify":0,"identifyType":null,"scripts":[{"id":55,"name":"右侧踝关节环绕","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/01右侧踝关节环绕.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":"[1]","equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813283952,"updateTime":1608813283952,"practiceAmount":13,"aicheckSteps":""},{"id":56,"name":"左侧踝关节环绕","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/02左侧踝关节环绕.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813411840,"updateTime":1608813411840,"practiceAmount":0,"aicheckSteps":""},{"id":57,"name":"膝关节热身","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/03膝关节热身.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813541654,"updateTime":1608813541654,"practiceAmount":0,"aicheckSteps":""}],"scriptToVideo":[{"scriptIds":[{"startTime":12000,"id":55,"endTime":29580}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01右侧踝关节环绕.mp4","videoTime":29580},{"scriptIds":[{"startTime":9000,"id":56,"endTime":26400}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02左侧踝关节环绕.mp4","videoTime":26400},{"scriptIds":[{"startTime":9000,"id":57,"endTime":40240}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/03膝关节热身.mp4","videoTime":40240}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609124689426,"updateTime":1609124689426},{"id":2,"name":"开合跳","type":2,"times":134070,"partDtos":[{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[],"calories":null,"isIdentify":1,"identifyType":0,"scripts":[{"id":59,"name":"开合跳","isIdentify":1,"picUrl":"http://devpic.aimymusic.com/ifcms/01开合跳.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":0,"point":10,"rate":null,"calories":2000,"expectHeartRate":null,"steps":null,"breathingRhythm":null,"movementFeeling":null,"positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608814829399,"updateTime":1608814829399,"practiceAmount":0,"aicheckSteps":"http://devfile.aimymusic.com/ifcms/jumping_jacks.lua"}],"scriptToVideo":[{"scriptIds":[{"startTime":8000,"id":59,"endTime":39710}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01开合跳.mp4","videoTime":40240},{"scriptIds":[{"startTime":8000,"id":59,"endTime":44670}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02开合跳.mp4","videoTime":44670},{"scriptIds":[{"startTime":8000,"id":59,"endTime":49690}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/03开合跳.mp4","videoTime":49690}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609124927726,"updateTime":1609124927726},{"id":3,"name":"拉伸","type":3,"times":73510,"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[],"calories":null,"isIdentify":0,"identifyType":null,"scripts":[{"id":61,"name":"靠墙右小腿后侧拉伸","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/01靠墙右小腿后侧拉伸.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608861376108,"updateTime":1608861376108,"practiceAmount":0,"aicheckSteps":""},{"id":105,"name":"靠墙左小腿后侧拉伸","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/02靠墙左小腿后侧拉伸.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608861376108,"updateTime":1608861376108,"practiceAmount":11,"aicheckSteps":""}],"scriptToVideo":[{"scriptIds":[{"startTime":10000,"id":61,"endTime":36270}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01靠墙右小腿后侧拉伸.mp4","videoTime":36270},{"scriptIds":[{"startTime":11000,"id":105,"endTime":37240}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02靠墙左小腿后侧拉伸.mp4","videoTime":37240}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609125056612,"updateTime":1609125056612}],"equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"creatorId":1008611,"creatorNickname":"爸爸","state":1,"useAmount":0,"dataState":2,"createTime":1609384660362,"updateTime":1609384660362},"bgmType":null,"priceType":0,"price":0,"state":1,"auditState":1,"practiceAmount":0,"playBackUrl":null,"startDate":null,"startTime":"2020-12-31 09:00:00","endTime":"2020-12-31 09:00:00","isBooked":0,"totalTrainingTime":0,"totalTrainingAmount":0,"totalCalories":0,"joinAmount":0,"commentCount":null,"laudCount":null,"finishAmount":null,"dataState":2,"createTime":1609387264786,"updateTime":1609387264786,"vipprice":0},{"id":1,"title":"浩哥教你做69的爱","picUrl":"http://devpic.aimymusic.com/ifcms/u%3D1145037121%2C2527894120%26fm%3D15%26gp%3D0.jpg","description":"浩哥教你做","coachId":1000000,"coachDto":{"uid":1000000,"phone":"13111858708","type":1,"subType":1,"nickName":"我太阳郑家斌s-a-o-比","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","status":2,"age":null,"isPerfect":1,"isPhone":1,"isLiving":0},"levelId":null,"levelDto":null,"targetId":null,"targetDto":null,"partDtos":null,"equipmentDtos":null,"times":null,"calories":null,"creatorId":1008611,"creatorNickname":"爸爸","coursewareId":1,"coursewareDto":{"id":1,"name":"开合跳减脂挑战","picUrl":"http://devpic.aimymusic.com/ifcms/12萌妹子.jpg","previewVideoUrl":"http://devmedia.aimymusic.com/ifcms/开合跳减脂挑战.mp4","description":"开合跳减脂挑战来袭","type":1,"times":303800,"calories":200,"levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"targetId":1,"targetDto":{"id":1,"type":2,"name":"减脂","updateTime":1607673809453,"ename":null},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null},{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}],"componentDtos":[{"id":1,"name":"热身","type":1,"times":96220,"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"calories":null,"isIdentify":0,"identifyType":null,"scripts":[{"id":55,"name":"右侧踝关节环绕","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/01右侧踝关节环绕.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":"[1]","equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813283952,"updateTime":1608813283952,"practiceAmount":13,"aicheckSteps":""},{"id":56,"name":"左侧踝关节环绕","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/02左侧踝关节环绕.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813411840,"updateTime":1608813411840,"practiceAmount":0,"aicheckSteps":""},{"id":57,"name":"膝关节热身","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/03膝关节热身.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813541654,"updateTime":1608813541654,"practiceAmount":0,"aicheckSteps":""}],"scriptToVideo":[{"scriptIds":[{"startTime":12000,"id":55,"endTime":29580}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01右侧踝关节环绕.mp4","videoTime":29580},{"scriptIds":[{"startTime":9000,"id":56,"endTime":26400}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02左侧踝关节环绕.mp4","videoTime":26400},{"scriptIds":[{"startTime":9000,"id":57,"endTime":40240}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/03膝关节热身.mp4","videoTime":40240}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609124689426,"updateTime":1609124689426},{"id":2,"name":"开合跳","type":2,"times":134070,"partDtos":[{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[],"calories":null,"isIdentify":1,"identifyType":0,"scripts":[{"id":59,"name":"开合跳","isIdentify":1,"picUrl":"http://devpic.aimymusic.com/ifcms/01开合跳.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":0,"point":10,"rate":null,"calories":2000,"expectHeartRate":null,"steps":null,"breathingRhythm":null,"movementFeeling":null,"positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608814829399,"updateTime":1608814829399,"practiceAmount":0,"aicheckSteps":"http://devfile.aimymusic.com/ifcms/jumping_jacks.lua"}],"scriptToVideo":[{"scriptIds":[{"startTime":8000,"id":59,"endTime":39710}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01开合跳.mp4","videoTime":40240},{"scriptIds":[{"startTime":8000,"id":59,"endTime":44670}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02开合跳.mp4","videoTime":44670},{"scriptIds":[{"startTime":8000,"id":59,"endTime":49690}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/03开合跳.mp4","videoTime":49690}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609124927726,"updateTime":1609124927726},{"id":3,"name":"拉伸","type":3,"times":73510,"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[],"calories":null,"isIdentify":0,"identifyType":null,"scripts":[{"id":61,"name":"靠墙右小腿后侧拉伸","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/01靠墙右小腿后侧拉伸.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608861376108,"updateTime":1608861376108,"practiceAmount":0,"aicheckSteps":""},{"id":105,"name":"靠墙左小腿后侧拉伸","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/02靠墙左小腿后侧拉伸.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608861376108,"updateTime":1608861376108,"practiceAmount":11,"aicheckSteps":""}],"scriptToVideo":[{"scriptIds":[{"startTime":10000,"id":61,"endTime":36270}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01靠墙右小腿后侧拉伸.mp4","videoTime":36270},{"scriptIds":[{"startTime":11000,"id":105,"endTime":37240}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02靠墙左小腿后侧拉伸.mp4","videoTime":37240}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609125056612,"updateTime":1609125056612}],"equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"creatorId":1008611,"creatorNickname":"爸爸","state":1,"useAmount":0,"dataState":2,"createTime":1609384660362,"updateTime":1609384660362},"bgmType":null,"priceType":1,"price":1,"state":1,"auditState":1,"practiceAmount":0,"playBackUrl":null,"startDate":null,"startTime":"2020-12-31 19:00:00","endTime":"2020-12-31 21:00:00","isBooked":0,"totalTrainingTime":0,"totalTrainingAmount":0,"totalCalories":0,"joinAmount":0,"commentCount":null,"laudCount":null,"finishAmount":null,"dataState":2,"createTime":1609387264786,"updateTime":1609387264786,"vipprice":0}]}
/// code : 200

/// id : 1
/// title : "浩哥教你做69的爱"
/// picUrl : "http://devpic.aimymusic.com/ifcms/u%3D1145037121%2C2527894120%26fm%3D15%26gp%3D0.jpg"
/// description : "浩哥教你做"
/// coachId : 1000000
/// coachDto : {"uid":1000000,"phone":"13111858708","type":1,"subType":1,"nickName":"我太阳郑家斌s-a-o-比","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","status":2,"age":null,"isPerfect":1,"isPhone":1,"isLiving":0}
/// levelId : null
/// levelDto : null
/// targetId : null
/// targetDto : null
/// partDtos : null
/// equipmentDtos : null
/// times : null
/// calories : null
/// creatorId : 1008611
/// creatorNickname : "爸爸"
/// coursewareId : 1
/// coursewareDto : {"id":1,"name":"开合跳减脂挑战","picUrl":"http://devpic.aimymusic.com/ifcms/12萌妹子.jpg","previewVideoUrl":"http://devmedia.aimymusic.com/ifcms/开合跳减脂挑战.mp4","description":"开合跳减脂挑战来袭","type":1,"times":303800,"calories":200,"levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"targetId":1,"targetDto":{"id":1,"type":2,"name":"减脂","updateTime":1607673809453,"ename":null},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null},{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}],"componentDtos":[{"id":1,"name":"热身","type":1,"times":96220,"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"calories":null,"isIdentify":0,"identifyType":null,"scripts":[{"id":55,"name":"右侧踝关节环绕","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/01右侧踝关节环绕.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":"[1]","equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813283952,"updateTime":1608813283952,"practiceAmount":13,"aicheckSteps":""},{"id":56,"name":"左侧踝关节环绕","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/02左侧踝关节环绕.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813411840,"updateTime":1608813411840,"practiceAmount":0,"aicheckSteps":""},{"id":57,"name":"膝关节热身","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/03膝关节热身.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813541654,"updateTime":1608813541654,"practiceAmount":0,"aicheckSteps":""}],"scriptToVideo":[{"scriptIds":[{"startTime":12000,"id":55,"endTime":29580}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01右侧踝关节环绕.mp4","videoTime":29580},{"scriptIds":[{"startTime":9000,"id":56,"endTime":26400}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02左侧踝关节环绕.mp4","videoTime":26400},{"scriptIds":[{"startTime":9000,"id":57,"endTime":40240}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/03膝关节热身.mp4","videoTime":40240}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609124689426,"updateTime":1609124689426},{"id":2,"name":"开合跳","type":2,"times":134070,"partDtos":[{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[],"calories":null,"isIdentify":1,"identifyType":0,"scripts":[{"id":59,"name":"开合跳","isIdentify":1,"picUrl":"http://devpic.aimymusic.com/ifcms/01开合跳.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":0,"point":10,"rate":null,"calories":2000,"expectHeartRate":null,"steps":null,"breathingRhythm":null,"movementFeeling":null,"positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608814829399,"updateTime":1608814829399,"practiceAmount":0,"aicheckSteps":"http://devfile.aimymusic.com/ifcms/jumping_jacks.lua"}],"scriptToVideo":[{"scriptIds":[{"startTime":8000,"id":59,"endTime":39710}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01开合跳.mp4","videoTime":40240},{"scriptIds":[{"startTime":8000,"id":59,"endTime":44670}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02开合跳.mp4","videoTime":44670},{"scriptIds":[{"startTime":8000,"id":59,"endTime":49690}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/03开合跳.mp4","videoTime":49690}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609124927726,"updateTime":1609124927726},{"id":3,"name":"拉伸","type":3,"times":73510,"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[],"calories":null,"isIdentify":0,"identifyType":null,"scripts":[{"id":61,"name":"靠墙右小腿后侧拉伸","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/01靠墙右小腿后侧拉伸.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608861376108,"updateTime":1608861376108,"practiceAmount":0,"aicheckSteps":""},{"id":105,"name":"靠墙左小腿后侧拉伸","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/02靠墙左小腿后侧拉伸.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608861376108,"updateTime":1608861376108,"practiceAmount":11,"aicheckSteps":""}],"scriptToVideo":[{"scriptIds":[{"startTime":10000,"id":61,"endTime":36270}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01靠墙右小腿后侧拉伸.mp4","videoTime":36270},{"scriptIds":[{"startTime":11000,"id":105,"endTime":37240}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02靠墙左小腿后侧拉伸.mp4","videoTime":37240}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609125056612,"updateTime":1609125056612}],"equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"creatorId":1008611,"creatorNickname":"爸爸","state":1,"useAmount":0,"dataState":2,"createTime":1609384660362,"updateTime":1609384660362}
/// bgmType : null
/// priceType : 0
/// price : 0
/// state : 1
/// auditState : 1
/// practiceAmount : 0
/// playBackUrl : null
/// startDate : null
/// startTime : "2020-12-31 09:00:00"
/// endTime : "2020-12-31 09:00:00"
/// isBooked : 0
/// totalTrainingTime : 0
/// totalTrainingAmount : 0
/// totalCalories : 0
/// joinAmount : 0
/// commentCount : null
/// laudCount : null
/// finishAmount : null
/// dataState : 2
/// createTime : 1609387264786
/// updateTime : 1609387264786
/// vipprice : 0

class CourseModel {
  int playType; //播放类型-0没有设置 1去上课  2预约  3回放 4已预约 5已结束 6未开播-没有做

  String getGetPlayType() {
    if (this.playType == 2) {
      if (this.isBooked == 1) {
        this.playType = 4;
        return "已预约";
      }
      return "预约";
    } else if (this.playType == 3) {
      return "回放";
    } else if (this.playType == 4) {
      return "已预约";
    } else if (this.playType == 5) {
      return "已结束";
    } else if (this.playType == 1) {
      return "去上课";
    } else {
      //0-未开播 1-正在直播 2-直播结束 3-可回放
      if (_liveCourseState != null && _liveCourseState == 1) {
        this.playType = 1;
        return "去上课";
      } else if (_liveCourseState != null && _liveCourseState == 2) {
        this.playType = 5;
        return "已结束";
      } else if (_liveCourseState != null && _liveCourseState == 3) {
        this.playType = 3;
        return "回放";
      } else {
        DateTime startTime = DateUtil.stringToDateTime(this.startTime);
        DateTime endTime = DateUtil.stringToDateTime(this.endTime);
        if (startTime != null) {
          if (DateUtil.compareNowDate(startTime)) {
            if (this.isBooked == 0) {
              this.playType = 2;
              return "预约";
            } else {
              this.playType = 4;
              return "已预约";
            }
          } else if (DateUtil.compareNowDate(endTime)) {
            print("-----------------------------------");
            this.playType = 1;
            return "去上课";
          } else {
            this.playType = 3;
            return "回放";
          }
        } else {
          if (this.isBooked == 0) {
            this.playType = 2;
            return "预约";
          } else {
            this.playType = 4;
            return "已预约";
          }
        }
      }
    }
  }

  int _id;
  int _type;
  String _title;
  String _picUrl;
  String _description;
  int _coachId;
  UserModel _coachDto;
  int _levelId;
  SubTagModel _levelDto;
  int _targetId;
  SubTagModel _targetDto;
  List<SubTagModel> _partDtos;
  List<EquipmentDtos> _equipmentDtos;
  int _times;
  int _calories;
  int _creatorId;
  String _creatorNickname;
  int _coursewareId;
  CoursewareDto _coursewareDto;
  int _bgmType;
  int _priceType; //0免费-1会员免费-2会员付费
  double _price;
  int _state;
  int _auditState;
  int _practiceAmount;
  String _playBackUrl;
  String _startDate;
  String _startTime;
  String _endTime;
  int isBooked;
  int _totalTrainingTime;
  int _totalTrainingAmount;
  int _totalCalories;
  int _joinAmount;
  int _commentCount;
  int _laudCount;
  int _finishAmount;
  int _dataState;
  int _createTime;
  int _updateTime;
  int _endState;
  int _isInMyCourseList;
  int _liveCourseState;
  int _bookCount;
  int _liveRoomCount;
  int _watchCount;
  int _lastPracticeTime;
  double _vipprice;

  int get id => _id;

  int get type => _type;

  String get title => _title;

  String get picUrl => _picUrl;

  String get description => _description;

  int get coachId => _coachId;

  UserModel get coachDto => _coachDto;

  int get levelId => _levelId;

  SubTagModel get levelDto => _levelDto;

  int get targetId => _targetId;

  SubTagModel get targetDto => _targetDto;

  List<SubTagModel> get partDtos => _partDtos;

  List<EquipmentDtos> get equipmentDtos => _equipmentDtos;

  int get times => _times;

  int get calories => _calories;

  int get creatorId => _creatorId;

  String get creatorNickname => _creatorNickname;

  int get coursewareId => _coursewareId;

  CoursewareDto get coursewareDto => _coursewareDto;

  int get bgmType => _bgmType;

  int get priceType => _priceType;

  double get price => _price;

  int get state => _state;

  int get auditState => _auditState;

  int get practiceAmount => _practiceAmount;

  String get playBackUrl => _playBackUrl;

  String get startDate => _startDate;

  String get startTime => _startTime;

  String get endTime => _endTime;

  int get totalTrainingTime => _totalTrainingTime;

  int get totalTrainingAmount => _totalTrainingAmount;

  int get totalCalories => _totalCalories;

  int get joinAmount => _joinAmount;

  int get commentCount => _commentCount;

  int get laudCount => _laudCount;

  int get finishAmount => _finishAmount;

  int get dataState => _dataState;

  int get createTime => _createTime;

  int get updateTime => _updateTime;

  int get endState => _endState;

  int get isInMyCourseList => _isInMyCourseList;

  int get liveCourseState => _liveCourseState;

  int get bookCount => _bookCount;

  int get liveRoomCount => _liveRoomCount;

  int get watchCount => _watchCount;

  int get lastPracticeTime => _lastPracticeTime;

  double get vipprice => _vipprice;

  CourseModel(
      {int id,
      int type,
      String title,
      String picUrl,
      String description,
      int coachId,
      UserModel coachDto,
      int levelId,
      SubTagModel levelDto,
      int targetId,
      SubTagModel targetDto,
      List<SubTagModel> partDtos,
      List<EquipmentDtos> equipmentDtos,
      int times = 0,
      int calories,
      int creatorId,
      String creatorNickname,
      int coursewareId,
      CoursewareDto coursewareDto,
      int bgmType,
      int priceType,
      double price,
      int state,
      int auditState,
      int practiceAmount,
      String playBackUrl,
      String startDate,
      String startTime,
      String endTime,
      int isBooked,
      int totalTrainingTime,
      int totalTrainingAmount,
      int totalCalories,
      int joinAmount,
      int commentCount,
      int laudCount,
      int finishAmount,
      int dataState,
      int createTime,
      int updateTime,
      int endState,
      int isInMyCourseList,
      int liveCourseState,
      int bookCount,
      int liveRoomCount,
      int watchCount,
      int lastPracticeTime,
      double vipprice}) {
    _id = id;
    _type = type;
    _title = title;
    _picUrl = picUrl;
    _description = description;
    _coachId = coachId;
    _coachDto = coachDto;
    _levelId = levelId;
    _levelDto = levelDto;
    _targetId = targetId;
    _targetDto = targetDto;
    _partDtos = partDtos;
    _equipmentDtos = equipmentDtos;
    _times = times;
    _calories = calories;
    _creatorId = creatorId;
    _creatorNickname = creatorNickname;
    _coursewareId = coursewareId;
    _coursewareDto = coursewareDto;
    _bgmType = bgmType;
    _priceType = priceType;
    _price = price;
    _state = state;
    _auditState = auditState;
    _practiceAmount = practiceAmount;
    _playBackUrl = playBackUrl;
    _startDate = startDate;
    _startTime = startTime;
    _endTime = endTime;
    this.isBooked = isBooked;
    _totalTrainingTime = totalTrainingTime;
    _totalTrainingAmount = totalTrainingAmount;
    _totalCalories = totalCalories;
    _joinAmount = joinAmount;
    _commentCount = commentCount;
    _laudCount = laudCount;
    _finishAmount = finishAmount;
    _dataState = dataState;
    _createTime = createTime;
    _updateTime = updateTime;
    _vipprice = vipprice;
    _endState = endState;
    _isInMyCourseList = isInMyCourseList;
    _liveCourseState = liveCourseState;
    _bookCount = bookCount;
    _liveRoomCount = liveRoomCount;
    _watchCount = watchCount;
    _lastPracticeTime = lastPracticeTime;
    playType = 0;
  }

  CourseModel.fromJson(dynamic json) {
    _id = json["id"];
    _type = json["type"];
    _title = json["title"];
    _picUrl = json["picUrl"];
    _description = json["description"];
    _coachId = json["coachId"];


    if (json["coachDto"] != null) {
      if(json["coachDto"] is UserModel){
        _coachDto =json["coachDto"];
      }else{
        _coachDto =UserModel.fromJson(json["coachDto"]);
      }
    }else{
      _coachDto =null;
    }


    _levelId = json["levelId"];


    if (json["levelDto"] != null) {
      if(json["levelDto"] is SubTagModel){
        _levelDto =json["levelDto"];
      }else{
        _levelDto =SubTagModel.fromJson(json["levelDto"]);
      }
    }else{
      _levelDto =null;
    }


    _targetId = json["targetId"];

    if (json["targetDto"] != null) {
      if(json["targetDto"] is SubTagModel){
        _targetDto =json["targetDto"];
      }else{
        _targetDto =SubTagModel.fromJson(json["targetDto"]);
      }
    }else{
      _targetDto =null;
    }



    if (json["partDtos"] != null) {
      _partDtos = [];
      json["partDtos"].forEach((v) {
        if (v is SubTagModel) {
          _partDtos.add(v);
        } else {
          _partDtos.add(SubTagModel.fromJson(v));
        }
      });
    }
    if (json["equipmentDtos"] != null) {
      _equipmentDtos = [];
      json["equipmentDtos"].forEach((v) {
        if (v is EquipmentDtos) {
          _equipmentDtos.add(v);
        } else {
          _equipmentDtos.add(EquipmentDtos.fromJson(v));
        }
      });
    }
    _times = json["times"];
    _calories = json["calories"];
    _creatorId = json["creatorId"];
    _creatorNickname = json["creatorNickname"];
    _coursewareId = json["coursewareId"];


    if (json["coursewareDto"] != null) {
      if(json["coursewareDto"] is CoursewareDto){
        _coursewareDto =json["coursewareDto"];
      }else{
        _coursewareDto =CoursewareDto.fromJson(json["coursewareDto"]);
      }
    }else{
      _coursewareDto =null;
    }


    _bgmType = json["bgmType"];
    _priceType = json["priceType"];
    _price = json["price"];
    _state = json["state"];
    _auditState = json["auditState"];
    _practiceAmount = json["practiceAmount"];
    _playBackUrl = json["playBackUrl"];
    _startDate = json["startDate"];
    _startTime = json["startTime"];
    _endTime = json["endTime"];
    this.isBooked = json["isBooked"];
    _totalTrainingTime = json["totalTrainingTime"];
    _totalTrainingAmount = json["totalTrainingAmount"];
    _totalCalories = json["totalCalories"];
    _joinAmount = json["joinAmount"];
    _commentCount = json["commentCount"];
    _laudCount = json["laudCount"];
    _finishAmount = json["finishAmount"];
    _dataState = json["dataState"];
    _createTime = json["createTime"];
    _updateTime = json["updateTime"];
    _endState = json["endState"];
    _isInMyCourseList = json["isInMyCourseList"];
    _lastPracticeTime = json["lastPracticeTime"];
    _liveCourseState = json["liveCourseState"];
    _bookCount = json["bookCount"];
    _liveRoomCount = json["liveRoomCount"];
    _watchCount = json["watchCount"];
    _vipprice = json["vipprice"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["type"] = _type;
    map["title"] = _title;
    map["picUrl"] = _picUrl;
    map["description"] = _description;
    map["coachId"] = _coachId;
    if (_coachDto != null) {
      map["coachDto"] = _coachDto.toJson();
    }
    map["levelId"] = _levelId;
    map["levelDto"] = _levelDto;
    map["targetId"] = _targetId;
    map["targetDto"] = _targetDto;
    map["partDtos"] = _partDtos;
    map["equipmentDtos"] = _equipmentDtos;
    map["times"] = _times;
    map["calories"] = _calories;
    map["creatorId"] = _creatorId;
    map["creatorNickname"] = _creatorNickname;
    map["coursewareId"] = _coursewareId;
    if (_coursewareDto != null) {
      map["coursewareDto"] = _coursewareDto.toJson();
    }
    map["bgmType"] = _bgmType;
    map["priceType"] = _priceType;
    map["price"] = _price;
    map["state"] = _state;
    map["auditState"] = _auditState;
    map["practiceAmount"] = _practiceAmount;
    map["playBackUrl"] = _playBackUrl;
    map["startDate"] = _startDate;
    map["startTime"] = _startTime;
    map["endTime"] = _endTime;
    map["isBooked"] = this.isBooked;
    map["totalTrainingTime"] = _totalTrainingTime;
    map["totalTrainingAmount"] = _totalTrainingAmount;
    map["totalCalories"] = _totalCalories;
    map["joinAmount"] = _joinAmount;
    map["commentCount"] = _commentCount;
    map["laudCount"] = _laudCount;
    map["finishAmount"] = _finishAmount;
    map["dataState"] = _dataState;
    map["createTime"] = _createTime;
    map["updateTime"] = _updateTime;
    map["endState"] = _endState;
    map["isInMyCourseList"] = _isInMyCourseList;
    map["liveCourseState"] = _liveCourseState;
    map["bookCount"] = _bookCount;
    map["liveRoomCount"] = _liveRoomCount;
    map["watchCount"] = _watchCount;
    map["vipprice"] = _vipprice;
    map["lastPracticeTime"] = _lastPracticeTime;
    return map;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

/// id : 1
/// name : "开合跳减脂挑战"
/// picUrl : "http://devpic.aimymusic.com/ifcms/12萌妹子.jpg"
/// previewVideoUrl : "http://devmedia.aimymusic.com/ifcms/开合跳减脂挑战.mp4"
/// description : "开合跳减脂挑战来袭"
/// type : 1
/// times : 303800
/// calories : 200
/// levelId : 1
/// levelDto : {"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"}
/// targetId : 1
/// targetDto : {"id":1,"type":2,"name":"减脂","updateTime":1607673809453,"ename":null}
/// partDtos : [{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null},{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}]
/// componentDtos : [{"id":1,"name":"热身","type":1,"times":96220,"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"calories":null,"isIdentify":0,"identifyType":null,"scripts":[{"id":55,"name":"右侧踝关节环绕","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/01右侧踝关节环绕.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":"[1]","equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813283952,"updateTime":1608813283952,"practiceAmount":13,"aicheckSteps":""},{"id":56,"name":"左侧踝关节环绕","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/02左侧踝关节环绕.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813411840,"updateTime":1608813411840,"practiceAmount":0,"aicheckSteps":""},{"id":57,"name":"膝关节热身","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/03膝关节热身.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813541654,"updateTime":1608813541654,"practiceAmount":0,"aicheckSteps":""}],"scriptToVideo":[{"scriptIds":[{"startTime":12000,"id":55,"endTime":29580}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01右侧踝关节环绕.mp4","videoTime":29580},{"scriptIds":[{"startTime":9000,"id":56,"endTime":26400}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02左侧踝关节环绕.mp4","videoTime":26400},{"scriptIds":[{"startTime":9000,"id":57,"endTime":40240}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/03膝关节热身.mp4","videoTime":40240}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609124689426,"updateTime":1609124689426},{"id":2,"name":"开合跳","type":2,"times":134070,"partDtos":[{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[],"calories":null,"isIdentify":1,"identifyType":0,"scripts":[{"id":59,"name":"开合跳","isIdentify":1,"picUrl":"http://devpic.aimymusic.com/ifcms/01开合跳.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":1,"type":1,"name":"全身","updateTime":1607673781969,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":0,"point":10,"rate":null,"calories":2000,"expectHeartRate":null,"steps":null,"breathingRhythm":null,"movementFeeling":null,"positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608814829399,"updateTime":1608814829399,"practiceAmount":0,"aicheckSteps":"http://devfile.aimymusic.com/ifcms/jumping_jacks.lua"}],"scriptToVideo":[{"scriptIds":[{"startTime":8000,"id":59,"endTime":39710}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01开合跳.mp4","videoTime":40240},{"scriptIds":[{"startTime":8000,"id":59,"endTime":44670}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02开合跳.mp4","videoTime":44670},{"scriptIds":[{"startTime":8000,"id":59,"endTime":49690}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/03开合跳.mp4","videoTime":49690}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609124927726,"updateTime":1609124927726},{"id":3,"name":"拉伸","type":3,"times":73510,"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"equipmentDtos":[],"calories":null,"isIdentify":0,"identifyType":null,"scripts":[{"id":61,"name":"靠墙右小腿后侧拉伸","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/01靠墙右小腿后侧拉伸.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608861376108,"updateTime":1608861376108,"practiceAmount":0,"aicheckSteps":""},{"id":105,"name":"靠墙左小腿后侧拉伸","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/02靠墙左小腿后侧拉伸.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608861376108,"updateTime":1608861376108,"practiceAmount":11,"aicheckSteps":""}],"scriptToVideo":[{"scriptIds":[{"startTime":10000,"id":61,"endTime":36270}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01靠墙右小腿后侧拉伸.mp4","videoTime":36270},{"scriptIds":[{"startTime":11000,"id":105,"endTime":37240}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02靠墙左小腿后侧拉伸.mp4","videoTime":37240}],"creatorId":1008611,"creatorNickname":"爸爸","referenceAmount":0,"seeLimit":0,"state":0,"dataState":2,"createTime":1609125056612,"updateTime":1609125056612}]
/// equipmentDtos : [{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}]
/// creatorId : 1008611
/// creatorNickname : "爸爸"
/// state : 1
/// useAmount : 0
/// dataState : 2
/// createTime : 1609384660362
/// updateTime : 1609384660362

class CoursewareDto {
  int _id;
  String _name;
  String _picUrl;
  String _previewVideoUrl;
  String _description;
  int _type;
  int _times;
  int _calories;
  int _levelId;
  SubTagModel _levelDto;
  int _targetId;
  SubTagModel _targetDto;
  List<SubTagModel> _partDtos;
  List<ComponentDtos> _componentDtos;
  List<EquipmentDtos> _equipmentDtos;
  int _creatorId;
  String _creatorNickname;
  int _state;
  int _useAmount;
  int _dataState;
  int _createTime;
  int _updateTime;
  List<Map<String, dynamic>> actionMapList = new List<Map<String, dynamic>>();
  List<Map<String, dynamic>> videoMapList = new List<Map<String, dynamic>>();
  Map<String, dynamic> videoMapId = Map<String, dynamic>();

  int get id => _id;

  String get name => _name;

  String get picUrl => _picUrl;

  String get previewVideoUrl => _previewVideoUrl;

  String get description => _description;

  int get type => _type;

  int get times => _times;

  int get calories => _calories;

  int get levelId => _levelId;

  SubTagModel get levelDto => _levelDto;

  int get targetId => _targetId;

  SubTagModel get targetDto => _targetDto;

  List<SubTagModel> get partDtos => _partDtos;

  List<ComponentDtos> get componentDtos => _componentDtos;

  List<EquipmentDtos> get equipmentDtos => _equipmentDtos;

  int get creatorId => _creatorId;

  String get creatorNickname => _creatorNickname;

  int get state => _state;

  int get useAmount => _useAmount;

  int get dataState => _dataState;

  int get createTime => _createTime;

  int get updateTime => _updateTime;

  CoursewareDto(
      {int id,
      String name,
      String picUrl,
      String previewVideoUrl,
      String description,
      int type,
      int times,
      int calories,
      int levelId,
      SubTagModel levelDto,
      int targetId,
      SubTagModel targetDto,
      List<SubTagModel> partDtos,
      List<ComponentDtos> componentDtos,
      List<EquipmentDtos> equipmentDtos,
      int creatorId,
      String creatorNickname,
      int state,
      int useAmount,
      int dataState,
      int createTime,
      int updateTime}) {
    _id = id;
    _name = name;
    _picUrl = picUrl;
    _previewVideoUrl = previewVideoUrl;
    _description = description;
    _type = type;
    _times = times;
    _calories = calories;
    _levelId = levelId;
    _levelDto = levelDto;
    _targetId = targetId;
    _targetDto = targetDto;
    _partDtos = partDtos;
    _componentDtos = componentDtos;
    _equipmentDtos = equipmentDtos;
    _creatorId = creatorId;
    _creatorNickname = creatorNickname;
    _state = state;
    _useAmount = useAmount;
    _dataState = dataState;
    _createTime = createTime;
    _updateTime = updateTime;
  }

  CoursewareDto.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _picUrl = json["picUrl"];
    _previewVideoUrl = json["previewVideoUrl"];
    _description = json["description"];
    _type = json["type"];
    _times = json["times"];
    _calories = json["calories"];
    _levelId = json["levelId"];


    if (json["levelDto"] != null) {
      if(json["levelDto"] is SubTagModel){
        _levelDto =json["levelDto"];
      }else{
        _levelDto =SubTagModel.fromJson(json["levelDto"]);
      }
    }else{
      _levelDto =null;
    }


    _targetId = json["targetId"];


    if (json["targetDto"] != null) {
      if(json["targetDto"] is SubTagModel){
        _targetDto =json["targetDto"];
      }else{
        _targetDto =SubTagModel.fromJson(json["targetDto"]);
      }
    }else{
      _targetDto =null;
    }

    if (json["partDtos"] != null) {
      _partDtos = [];
      json["partDtos"].forEach((v) {
        if (v is SubTagModel) {
          _partDtos.add(v);
        } else {
          _partDtos.add(SubTagModel.fromJson(v));
        }
      });
    }
    if (json["componentDtos"] != null) {
      _componentDtos = [];
      json["componentDtos"].forEach((v) {
        if (v is ComponentDtos) {
          _componentDtos.add(v);
        } else {
          _componentDtos.add(ComponentDtos.fromJson(v));
        }
      });
    }
    if (json["equipmentDtos"] != null) {
      _equipmentDtos = [];
      json["equipmentDtos"].forEach((v) {
        if (v is EquipmentDtos) {
          _equipmentDtos.add(v);
        } else {
          _equipmentDtos.add(EquipmentDtos.fromJson(v));
        }
      });
    }
    _creatorId = json["creatorId"];
    _creatorNickname = json["creatorNickname"];
    _state = json["state"];
    _useAmount = json["useAmount"];
    _dataState = json["dataState"];
    _createTime = json["createTime"];
    _updateTime = json["updateTime"];

    if (_componentDtos != null) {
      for (int i = 0; i < _componentDtos.length ?? 0; i++) {
        if (_componentDtos[i]?.scriptToVideo != null) {
          for (int j = 0; j < _componentDtos[i]?.scriptToVideo?.length; j++) {
            if (_componentDtos[i]?.scriptToVideo[j].scriptIds != null) {
              for (int z = 0; z < _componentDtos[i]?.scriptToVideo[j].scriptIds?.length; z++) {
                Map<String, dynamic> map = Map();
                map["id"] = _componentDtos[i].scriptToVideo[j]?.scriptIds[z]?.id;
                map["videoTime"] = _componentDtos[i].scriptToVideo[j]?.videoTime;

                if (_componentDtos[i].scripts != null) {
                  for (int n = 0; n < _componentDtos[i].scripts?.length; n++) {
                    if (_componentDtos[i]?.scripts[n].id == map["id"]) {
                      map["name"] = _componentDtos[i].scripts[n].name;
                      map["picUrl"] = _componentDtos[i].scripts[n].picUrl;
                      break;
                    }
                  }
                }

                actionMapList.add(map);
              }
            }
            if (_componentDtos[i]?.scriptToVideo[j]._videoUrl != null &&
                _componentDtos[i]?.scriptToVideo[j]._videoUrl.length > 0) {
              if (videoMapId[StringUtil.generateMd5(_componentDtos[i]?.scriptToVideo[j]._videoUrl)] == null) {
                videoMapId[StringUtil.generateMd5(_componentDtos[i]?.scriptToVideo[j]._videoUrl)] = 1;
                Map<String, dynamic> videoMap = Map();
                videoMap["videoUrl"] = _componentDtos[i]?.scriptToVideo[j]._videoUrl;
                videoMap["videoTime"] = _componentDtos[i]?.scriptToVideo[j]._videoTime;
                videoMapList.add(videoMap);
              }
            }
          }
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["picUrl"] = _picUrl;
    map["previewVideoUrl"] = _previewVideoUrl;
    map["description"] = _description;
    map["type"] = _type;
    map["times"] = _times;
    map["calories"] = _calories;
    map["levelId"] = _levelId;
    if (_levelDto != null) {
      map["levelDto"] = _levelDto.toJson();
    }
    map["targetId"] = _targetId;
    if (_targetDto != null) {
      map["targetDto"] = _targetDto.toJson();
    }
    if (_partDtos != null) {
      map["partDtos"] = _partDtos.map((v) => v.toJson()).toList();
    }
    if (_componentDtos != null) {
      map["componentDtos"] = _componentDtos.map((v) => v.toJson()).toList();
    }
    if (_equipmentDtos != null) {
      map["equipmentDtos"] = _equipmentDtos.map((v) => v.toJson()).toList();
    }
    map["creatorId"] = _creatorId;
    map["creatorNickname"] = _creatorNickname;
    map["state"] = _state;
    map["useAmount"] = _useAmount;
    map["dataState"] = _dataState;
    map["createTime"] = _createTime;
    map["updateTime"] = _updateTime;
    return map;
  }
}

/// id : 1
/// name : "瑜伽垫"
/// appPicUrl : null
/// terminalPicUrl : "http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"

class EquipmentDtos {
  int _id;
  String _name;
  dynamic _appPicUrl;
  String _terminalPicUrl;

  int get id => _id;

  String get name => _name;

  dynamic get appPicUrl => _appPicUrl;

  String get terminalPicUrl => _terminalPicUrl;

  EquipmentDtos({int id, String name, dynamic appPicUrl, String terminalPicUrl}) {
    _id = id;
    _name = name;
    _appPicUrl = appPicUrl;
    _terminalPicUrl = terminalPicUrl;
  }

  EquipmentDtos.fromJson(dynamic json) {
    if (json is EquipmentDtos) {
      _id = json._id;
      _name = json._name;
      _appPicUrl = json._appPicUrl;
      _terminalPicUrl = json._terminalPicUrl;
    } else {
      _id = json["id"];
      _name = json["name"];
      _appPicUrl = json["appPicUrl"];
      _terminalPicUrl = json["terminalPicUrl"];
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["appPicUrl"] = _appPicUrl;
    map["terminalPicUrl"] = _terminalPicUrl;
    return map;
  }
}

/// id : 1
/// name : "热身"
/// type : 1
/// times : 96220
/// partDtos : [{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}]
/// levelDto : {"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"}
/// equipmentDtos : [{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}]
/// calories : null
/// isIdentify : 0
/// identifyType : null
/// scripts : [{"id":55,"name":"右侧踝关节环绕","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/01右侧踝关节环绕.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":"[1]","equipmentDtos":[{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}],"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813283952,"updateTime":1608813283952,"practiceAmount":13,"aicheckSteps":""},{"id":56,"name":"左侧踝关节环绕","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/02左侧踝关节环绕.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813411840,"updateTime":1608813411840,"practiceAmount":0,"aicheckSteps":""},{"id":57,"name":"膝关节热身","isIdentify":0,"picUrl":"http://devpic.aimymusic.com/ifcms/03膝关节热身.jpg","levelId":1,"levelDto":{"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"},"partDtos":[{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}],"equipmentIds":null,"equipmentDtos":null,"type":null,"point":null,"rate":null,"calories":null,"expectHeartRate":null,"steps":"","breathingRhythm":"","movementFeeling":"","positionId":null,"positionDto":null,"muscleId":null,"muscleDto":null,"detail":null,"state":2,"creatorId":1008611,"dataState":2,"createTime":1608813541654,"updateTime":1608813541654,"practiceAmount":0,"aicheckSteps":""}]
/// scriptToVideo : [{"scriptIds":[{"startTime":12000,"id":55,"endTime":29580}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/01右侧踝关节环绕.mp4","videoTime":29580},{"scriptIds":[{"startTime":9000,"id":56,"endTime":26400}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/02左侧踝关节环绕.mp4","videoTime":26400},{"scriptIds":[{"startTime":9000,"id":57,"endTime":40240}],"videoUrl":"http://devmedia.aimymusic.com/ifcms/03膝关节热身.mp4","videoTime":40240}]
/// creatorId : 1008611
/// creatorNickname : "爸爸"
/// referenceAmount : 0
/// seeLimit : 0
/// state : 0
/// dataState : 2
/// createTime : 1609124689426
/// updateTime : 1609124689426

class ComponentDtos {
  int _id;
  String _name;
  int _type;
  int _times;
  List<SubTagModel> _partDtos;
  SubTagModel _levelDto;
  List<EquipmentDtos> _equipmentDtos;
  int _calories;
  int _isIdentify;
  int _identifyType;
  List<Scripts> _scripts;
  List<ScriptToVideo> _scriptToVideo;
  int _creatorId;
  String _creatorNickname;
  int _referenceAmount;
  int _seeLimit;
  int _state;
  int _dataState;
  int _createTime;
  int _updateTime;

  int get id => _id;

  String get name => _name;

  int get type => _type;

  int get times => _times;

  List<SubTagModel> get partDtos => _partDtos;

  SubTagModel get levelDto => _levelDto;

  List<EquipmentDtos> get equipmentDtos => _equipmentDtos;

  int get calories => _calories;

  int get isIdentify => _isIdentify;

  int get identifyType => _identifyType;

  List<Scripts> get scripts => _scripts;

  List<ScriptToVideo> get scriptToVideo => _scriptToVideo;

  int get creatorId => _creatorId;

  String get creatorNickname => _creatorNickname;

  int get referenceAmount => _referenceAmount;

  int get seeLimit => _seeLimit;

  int get state => _state;

  int get dataState => _dataState;

  int get createTime => _createTime;

  int get updateTime => _updateTime;

  ComponentDtos(
      {int id,
      String name,
      int type,
      int times,
      List<SubTagModel> partDtos,
      SubTagModel levelDto,
      List<EquipmentDtos> equipmentDtos,
      int calories,
      int isIdentify,
      int identifyType,
      List<Scripts> scripts,
      List<ScriptToVideo> scriptToVideo,
      int creatorId,
      String creatorNickname,
      int referenceAmount,
      int seeLimit,
      int state,
      int dataState,
      int createTime,
      int updateTime}) {
    _id = id;
    _name = name;
    _type = type;
    _times = times;
    _partDtos = partDtos;
    _levelDto = levelDto;
    _equipmentDtos = equipmentDtos;
    _calories = calories;
    _isIdentify = isIdentify;
    _identifyType = identifyType;
    _scripts = scripts;
    _scriptToVideo = scriptToVideo;
    _creatorId = creatorId;
    _creatorNickname = creatorNickname;
    _referenceAmount = referenceAmount;
    _seeLimit = seeLimit;
    _state = state;
    _dataState = dataState;
    _createTime = createTime;
    _updateTime = updateTime;
  }

  ComponentDtos.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _type = json["type"];
    _times = json["times"];
    if (json["partDtos"] != null) {
      _partDtos = [];
      json["partDtos"].forEach((v) {
        if (v is SubTagModel) {
          _partDtos.add(v);
        } else {
          _partDtos.add(SubTagModel.fromJson(v));
        }
      });
    }

    if (json["levelDto"] != null) {
      if(json["levelDto"] is SubTagModel){
        _levelDto =json["levelDto"];
      }else{
        _levelDto =SubTagModel.fromJson(json["levelDto"]);
      }
    }else{
      _levelDto =null;
    }


    if (json["equipmentDtos"] != null) {
      _equipmentDtos = [];
      json["equipmentDtos"].forEach((v) {
        if (v is EquipmentDtos) {
          _equipmentDtos.add(v);
        } else {
          _equipmentDtos.add(EquipmentDtos.fromJson(v));
        }
      });
    }
    _calories = json["calories"];
    _isIdentify = json["isIdentify"];
    _identifyType = json["identifyType"];
    if (json["scripts"] != null) {
      _scripts = [];
      json["scripts"].forEach((v) {
        if (v is Scripts) {
          _scripts.add(v);
        } else {
          _scripts.add(Scripts.fromJson(v));
        }
      });
    }
    if (json["scriptToVideo"] != null) {
      _scriptToVideo = [];
      json["scriptToVideo"].forEach((v) {
        if (v is ScriptToVideo) {
          _scriptToVideo.add(v);
        } else {
          _scriptToVideo.add(ScriptToVideo.fromJson(v));
        }
      });
    }
    _creatorId = json["creatorId"];
    _creatorNickname = json["creatorNickname"];
    _referenceAmount = json["referenceAmount"];
    _seeLimit = json["seeLimit"];
    _state = json["state"];
    _dataState = json["dataState"];
    _createTime = json["createTime"];
    _updateTime = json["updateTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["type"] = _type;
    map["times"] = _times;
    if (_partDtos != null) {
      map["partDtos"] = _partDtos.map((v) => v.toJson()).toList();
    }
    if (_levelDto != null) {
      map["levelDto"] = _levelDto.toJson();
    }
    if (_equipmentDtos != null) {
      map["equipmentDtos"] = _equipmentDtos.map((v) => v.toJson()).toList();
    }
    map["calories"] = _calories;
    map["isIdentify"] = _isIdentify;
    map["identifyType"] = _identifyType;
    if (_scripts != null) {
      map["scripts"] = _scripts.map((v) => v.toJson()).toList();
    }
    if (_scriptToVideo != null) {
      map["scriptToVideo"] = _scriptToVideo.map((v) => v.toJson()).toList();
    }
    map["creatorId"] = _creatorId;
    map["creatorNickname"] = _creatorNickname;
    map["referenceAmount"] = _referenceAmount;
    map["seeLimit"] = _seeLimit;
    map["state"] = _state;
    map["dataState"] = _dataState;
    map["createTime"] = _createTime;
    map["updateTime"] = _updateTime;
    return map;
  }
}

/// scriptIds : [{"startTime":12000,"id":55,"endTime":29580}]
/// videoUrl : "http://devmedia.aimymusic.com/ifcms/01右侧踝关节环绕.mp4"
/// videoTime : 29580

class ScriptToVideo {
  List<ScriptIds> _scriptIds;
  String _videoUrl;
  int _videoTime;

  List<ScriptIds> get scriptIds => _scriptIds;

  String get videoUrl => _videoUrl;

  int get videoTime => _videoTime;

  ScriptToVideo({List<ScriptIds> scriptIds, String videoUrl, int videoTime}) {
    _scriptIds = scriptIds;
    _videoUrl = videoUrl;
    _videoTime = videoTime;
  }

  ScriptToVideo.fromJson(dynamic json) {
    if (json["scriptIds"] != null) {
      _scriptIds = [];
      json["scriptIds"].forEach((v) {
        if (v is ScriptIds) {
          _scriptIds.add(v);
        } else {
          _scriptIds.add(ScriptIds.fromJson(v));
        }
      });
    }
    _videoUrl = json["videoUrl"];
    _videoTime = json["videoTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_scriptIds != null) {
      map["scriptIds"] = _scriptIds.map((v) => v.toJson()).toList();
    }
    map["videoUrl"] = _videoUrl;
    map["videoTime"] = _videoTime;
    return map;
  }
}

/// startTime : 12000
/// id : 55
/// endTime : 29580

class ScriptIds {
  int _startTime;
  int _id;
  int _endTime;

  int get startTime => _startTime;

  int get id => _id;

  int get endTime => _endTime;

  ScriptIds({int startTime, int id, int endTime}) {
    _startTime = startTime;
    _id = id;
    _endTime = endTime;
  }

  ScriptIds.fromJson(dynamic json) {
    _startTime = json["startTime"];
    _id = json["id"];
    if (json["endTime"] is int) {
      _endTime = json["endTime"];
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["startTime"] = _startTime;
    map["id"] = _id;
    map["endTime"] = _endTime;
    return map;
  }
}

/// id : 55
/// name : "右侧踝关节环绕"
/// isIdentify : 0
/// picUrl : "http://devpic.aimymusic.com/ifcms/01右侧踝关节环绕.jpg"
/// levelId : 1
/// levelDto : {"id":1,"type":0,"name":"零基础","updateTime":1608014617889,"ename":"L0"}
/// partDtos : [{"id":6,"type":1,"name":"腿部","updateTime":1607673782068,"ename":null}]
/// equipmentIds : "[1]"
/// equipmentDtos : [{"id":1,"name":"瑜伽垫","appPicUrl":null,"terminalPicUrl":"http://devpic.aimymusic.com/ifcms/terminal-yujiadian.png"}]
/// type : null
/// point : null
/// rate : null
/// calories : null
/// expectHeartRate : null
/// steps : ""
/// breathingRhythm : ""
/// movementFeeling : ""
/// positionId : null
/// positionDto : null
/// muscleId : null
/// muscleDto : null
/// detail : null
/// state : 2
/// creatorId : 1008611
/// dataState : 2
/// createTime : 1608813283952
/// updateTime : 1608813283952
/// practiceAmount : 13
/// aicheckSteps : ""

class Scripts {
  int _id;
  String _name;
  int _isIdentify;
  String _picUrl;
  int _levelId;
  SubTagModel _levelDto;
  List<SubTagModel> _partDtos;
  String _equipmentIds;
  List<EquipmentDtos> _equipmentDtos;
  dynamic _type;
  dynamic _point;
  dynamic _rate;
  dynamic _calories;
  dynamic _expectHeartRate;
  String _steps;
  String _breathingRhythm;
  String _movementFeeling;
  dynamic _positionId;
  dynamic _positionDto;
  dynamic _muscleId;
  dynamic _muscleDto;
  dynamic _detail;
  int _state;
  int _creatorId;
  int _dataState;
  int _createTime;
  int _updateTime;
  int _practiceAmount;
  String _aicheckSteps;

  int get id => _id;

  String get name => _name;

  int get isIdentify => _isIdentify;

  String get picUrl => _picUrl;

  int get levelId => _levelId;

  SubTagModel get levelDto => _levelDto;

  List<SubTagModel> get partDtos => _partDtos;

  String get equipmentIds => _equipmentIds;

  List<EquipmentDtos> get equipmentDtos => _equipmentDtos;

  dynamic get type => _type;

  dynamic get point => _point;

  dynamic get rate => _rate;

  dynamic get calories => _calories;

  dynamic get expectHeartRate => _expectHeartRate;

  String get steps => _steps;

  String get breathingRhythm => _breathingRhythm;

  String get movementFeeling => _movementFeeling;

  dynamic get positionId => _positionId;

  dynamic get positionDto => _positionDto;

  dynamic get muscleId => _muscleId;

  dynamic get muscleDto => _muscleDto;

  dynamic get detail => _detail;

  int get state => _state;

  int get creatorId => _creatorId;

  int get dataState => _dataState;

  int get createTime => _createTime;

  int get updateTime => _updateTime;

  int get practiceAmount => _practiceAmount;

  String get aicheckSteps => _aicheckSteps;

  Scripts(
      {int id,
      String name,
      int isIdentify,
      String picUrl,
      int levelId,
      SubTagModel levelDto,
      List<SubTagModel> partDtos,
      String equipmentIds,
      List<EquipmentDtos> equipmentDtos,
      dynamic type,
      dynamic point,
      dynamic rate,
      dynamic calories,
      dynamic expectHeartRate,
      String steps,
      String breathingRhythm,
      String movementFeeling,
      dynamic positionId,
      dynamic positionDto,
      dynamic muscleId,
      dynamic muscleDto,
      dynamic detail,
      int state,
      int creatorId,
      int dataState,
      int createTime,
      int updateTime,
      int practiceAmount,
      String aicheckSteps}) {
    _id = id;
    _name = name;
    _isIdentify = isIdentify;
    _picUrl = picUrl;
    _levelId = levelId;
    _levelDto = levelDto;
    _partDtos = partDtos;
    _equipmentIds = equipmentIds;
    _equipmentDtos = equipmentDtos;
    _type = type;
    _point = point;
    _rate = rate;
    _calories = calories;
    _expectHeartRate = expectHeartRate;
    _steps = steps;
    _breathingRhythm = breathingRhythm;
    _movementFeeling = movementFeeling;
    _positionId = positionId;
    _positionDto = positionDto;
    _muscleId = muscleId;
    _muscleDto = muscleDto;
    _detail = detail;
    _state = state;
    _creatorId = creatorId;
    _dataState = dataState;
    _createTime = createTime;
    _updateTime = updateTime;
    _practiceAmount = practiceAmount;
    _aicheckSteps = aicheckSteps;
  }

  Scripts.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _isIdentify = json["isIdentify"];
    _picUrl = json["picUrl"];
    _levelId = json["levelId"];


    if (json["levelDto"] != null) {
      if(json["levelDto"] is SubTagModel){
        _levelDto =json["levelDto"];
      }else{
        _levelDto =SubTagModel.fromJson(json["levelDto"]);
      }
    }else{
      _levelDto =null;
    }


    if (json["partDtos"] != null) {
      _partDtos = [];
      json["partDtos"].forEach((v) {
        if (v is SubTagModel) {
          _partDtos.add(v);
        } else {
          _partDtos.add(SubTagModel.fromJson(v));
        }
      });
    }
    _equipmentIds = json["equipmentIds"];
    if (json["equipmentDtos"] != null) {
      _equipmentDtos = [];
      json["equipmentDtos"].forEach((v) {
        if (v is EquipmentDtos) {
          _equipmentDtos.add(v);
        } else {
          _equipmentDtos.add(EquipmentDtos.fromJson(v));
        }
      });
    }
    _type = json["type"];
    _point = json["point"];
    _rate = json["rate"];
    _calories = json["calories"];
    _expectHeartRate = json["expectHeartRate"];
    _steps = json["steps"];
    _breathingRhythm = json["breathingRhythm"];
    _movementFeeling = json["movementFeeling"];
    _positionId = json["positionId"];
    _positionDto = json["positionDto"];
    _muscleId = json["muscleId"];
    _muscleDto = json["muscleDto"];
    _detail = json["detail"];
    _state = json["state"];
    _creatorId = json["creatorId"];
    _dataState = json["dataState"];
    _createTime = json["createTime"];
    _updateTime = json["updateTime"];
    _practiceAmount = json["practiceAmount"];
    _aicheckSteps = json["aicheckSteps"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["isIdentify"] = _isIdentify;
    map["picUrl"] = _picUrl;
    map["levelId"] = _levelId;
    if (_levelDto != null) {
      map["levelDto"] = _levelDto.toJson();
    }
    if (_partDtos != null) {
      map["partDtos"] = _partDtos.map((v) => v.toJson()).toList();
    }
    map["equipmentIds"] = _equipmentIds;
    if (_equipmentDtos != null) {
      map["equipmentDtos"] = _equipmentDtos.map((v) => v.toJson()).toList();
    }
    map["type"] = _type;
    map["point"] = _point;
    map["rate"] = _rate;
    map["calories"] = _calories;
    map["expectHeartRate"] = _expectHeartRate;
    map["steps"] = _steps;
    map["breathingRhythm"] = _breathingRhythm;
    map["movementFeeling"] = _movementFeeling;
    map["positionId"] = _positionId;
    map["positionDto"] = _positionDto;
    map["muscleId"] = _muscleId;
    map["muscleDto"] = _muscleDto;
    map["detail"] = _detail;
    map["state"] = _state;
    map["creatorId"] = _creatorId;
    map["dataState"] = _dataState;
    map["createTime"] = _createTime;
    map["updateTime"] = _updateTime;
    map["practiceAmount"] = _practiceAmount;
    map["aicheckSteps"] = _aicheckSteps;
    return map;
  }
}
