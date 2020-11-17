//消息页的网络处理
abstract class MPNetworkEvents{
    //断网时
    void loseConnection();
    //回复网络时
    void reconnected();
    //进行连接
    void connecting();
    //通知开启消息
    void activateNotification();
}