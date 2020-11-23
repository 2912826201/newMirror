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
待完成。。。说明各包路径内容用途

## 开发规范
一、命名
1.路径名、文件名：全小写字母，单词与单词之间用_隔开。例如login_page。
2.类名：大驼峰命名。例如CustomInputWidget。
3.属性名、方法名：小驼峰命名。例如currentIndex、handleApiResponse。
4.含义：尽量使用简短易懂常用的单词，意义连贯的单词、产品名、商标等不要将其拆开。例如download不要拆成down_load或因此写成驼峰downLoad。

二、封装属性、方法调用
1.页面跳转：统一调用AppRouter.navigateToXXX方法，XXX为页面名。禁止直接使用Navigator.push或fluro的navigateTo等方法。
2.颜色：统一使用AppColor中的颜色。禁止直接使用Colors中的常量或通过Color.fromRGBO等方法构建颜色。
3.文字：之后会统一管理APP中用到的文字。暂时先写到各个页面代码中。

## 开发流程
一、页面路由中新建一个页面的跳转方法
1./route/router.dart中新建路径。
2./route/route_handler.dart中编写处理页面入参及创建页面的handler。
3./route/router.dart的configureRouter方法中加入新建的路径和handler的对应配置。
4./route/router.dart中编写navigateToXXX，实际规范入参并开放调用的跳转页面方法。
