
//消息页的消息及网络系统服务事件

abstract class MPNetworkEvents{
    //断网时
    void loseConnection();
    //回复网络时
    void reconnected();
    //进行连接
    void connecting();
    //通知开启消息提示
    void activateNotificationBanner();
    //关闭系统提醒开启横幅
    void dismissNotificationBanner();
}