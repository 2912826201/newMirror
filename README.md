# mirror

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 工程结构说明
待完善。。。说明各包路径内容用途
api/        各接口网络请求方法。
config/     在APP运行时根据环境获取或生成的全局使用的变量及单例组件实例。
constant/   统一标准和开发规范的常量。
data/       数据模型及数据相关操作的工具类。
im/         即时通讯消息通知相关功能组件。
page/       各页面UI及业务逻辑实现。一些页面私有不复用的数据模型或界面组件也可以写在此路径下各页面文件中。
route/      页面路由。
util/       工具类。
widget/     可复用的界面组件。

## 开发规范
一、命名
1.路径名、文件名：全小写字母，单词与单词之间用_隔开。例如login_page。
2.类名：大驼峰命名。例如CustomInputWidget。
3.属性名、方法名：小驼峰命名。例如currentIndex、handleApiResponse。
4.含义：尽量使用简短易懂常用的单词，意义连贯的单词、产品名、商标等不要将其拆开。例如download不要拆成down_load或因此写成驼峰downLoad。

二、封装属性、方法调用
1.页面跳转：统一调用AppRouter.navigateToXXX方法，XXX为页面名。禁止直接使用Navigator.push或fluro的navigateTo等方法。
2.颜色：统一使用AppColor中的颜色。禁止直接使用Colors中的常量或通过Color.fromRGBO等方法构建颜色。如需要AppColor中的颜色的指定透明度的
颜色时。使用withOpacity方法设置透明度。
3.文字：之后会统一管理APP中用到的文字。暂时先写到各个页面代码中。

## 业务逻辑开发指南
一、页面路由中新建一个页面的跳转方法
1./route/router.dart中新建路径。
2./route/route_handler.dart中编写处理页面入参及创建页面的handler。
3./route/router.dart的configureRouter方法中加入新建的路径和handler的对应配置。
4./route/router.dart中编写navigateToXXX，实际规范入参并开放调用的跳转页面方法。

二、接口网络请求方法
1.在/api路径下新建对应业务的dart文件。
2.新增接口路径的常量。
3.新增请求接口的异步方法，根据需求对入参做一定的约束要求。
4.入参的Map中，如无必要不要将值为null的键值对写入。
5.调用api.dart中的requestApi方法执行请求，路径和参数是必需的入参，认证方法一般不需要传入仅在几个特殊接口中设置。
6.处理requestApi方法返回的BaseResponseModel。该model中isSuccess表示请求是否顺利完成，而非接口对应的业务成功执行。所以还应根据需求对
不同的code做具体处理。

三、token的管理与用户登录状态监听
1.取值
  Application.token存放当前token。
  Application.profile存放当前用户信息。
  需要取值时，直接调用获取即可。
2.订阅监听
  TokenNotifier为token的状态通知者，ProfileNotifier为用户信息的状态通知者。已配置为全APP通知。
  需要订阅监听token、是否登录或用户信息时可使用（可根据场景自行选用watch或select方法）：
  context.watch<TokenNotifier>().token
  context.watch<TokenNotifier>().isLoggedIn
  context.watch<ProfileNotifier>().profile
3.更新数据
  需要先将token或用户信息写入数据库：
  TokenDBHelper().insertToken(token);
  ProfileDBHelper().insertProfile(profile);
  然后再更新相应的notifier：
  context.read<TokenNotifier>().setToken(token);
  context.read<ProfileNotifier>().setProfile(profile);
  在notifier的方法中已经将值赋值到Application了，所以无需再次为Application中的token或profile赋值。
  
## UI界面开发指南
一、状态栏字符颜色
  1.没有用AppBar：用以下代码包裹Scaffold来实现控制状态栏字符颜色
  AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark, //黑色是dark 白色是light
    child: Scaffold()
  )
  2.用了AppBar：在AppBar中设置brightness: Brightness.light //light是黑字，dark是白字
  
## 备忘
flutter build apk --release --target-platform android-arm64
flutter build apk --release --target-platform android-arm