# memorytrainer

A new Flutter project.

## Getting Started

用flutter编写一个Android app程序，此程序是用来帮助练习大脑的记忆力，

第一个界面是选择关卡，要求有3个关卡，开始就关卡一的按钮是enable的，其他都是disable的按钮，只有赢了前一个关卡，后面的关卡才能enable，

第二个界面是关卡界面，首先随机产生40个两位数字，每个数值之间用空格分割，同时最上面是秒表，最下面是OK按钮，一旦用户按了OK，
就进入回忆界面，用户在这个界面里输入前一个界面里产生的40个数字，然后按OK，然后进入结果界面，程序会比较用户是否成功的记忆了
这些数字，记对的数字用蓝色，记错的用红色，然后计算成功率，最下面显示成功率和在关卡界面里秒表所记下的最终时间。如果成功率为
100%则成功解锁下一关，第二关的随机数字是60个，第三关卡的随机数字是80个。

程序允许用户在任意一个界面选择退出程序。界面做的漂亮一些，用户的成绩必须保存，下一次用户可以在上一次打赢的关卡之上继续攻关。 


A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
