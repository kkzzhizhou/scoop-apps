# HotkeyP

## 软件介绍

软件名称：HotkeyP

软件官网：
http://petr.lastovicka.sweb.cz/others.html#hotkey

使用手册：
http://petr.lastovicka.sweb.cz/HotkeyP-help.html

使用参考：
https://mp.weixin.qq.com/s/AlqczP-3DHiG7VKHIXyWPg

PS：软件占用极小，建议加入开机启动。

注意：
你可以的软件里导入奶酪的配置，即 “hotkeyp\_奶酪配置.htk”

## 使用方法

支持的修饰键包括：Ctrl, Shift, Alt, Win

支持应用程序，文件夹，网页地址，或者内部命令

支持环境变量，比如 %SystemRoot%、%HotkeyP%

勾选“允许运行多实例”的话，软件就会开启多个窗口，如果不勾选的话，则会变成切换模式

## 鼠标快捷键

L、R、M、4、5、Up、Down、Left、 Right

分别对应：

鼠标左键、鼠标右键、鼠标中键、鼠标第四键、鼠标第五键、滚轮向上、滚轮向下、滚轮向左、滚轮向右

## 宏命令

宏命令这样写，比如 Win+S 键写成：\win\s

列表：

\esc, \tab, \backspace, \enter, \space, \left, \right, \up, \down, \ins, \del, \home, \end, \pageup, \pagedown, \f1, \f2, ..., \shift, \rshift, \ctrl, \rctrl, \alt, \ralt, \win, \rwin, \apps, \capslock, \scrolllock, \numlock, \pause, \printscreen, \divide, \multiply, \add, \subtract, \decimal, \0, \1, ..., \num0, \num1, ..., \A, \B, ..., \back, \forward, \refresh, \search, \favorites, \browser, \mail, \power, \volume_down, \volume_up, \mute, \play_pause, \stop, \prev_track, \next_track, \media_select, \launch_app1, \launch_app2, \lbutton, \rbutton, \mbutton, \xbutton1, \xbutton2, \wheelup, \wheeldown, \wheelleft, \wheelright, \doubleclick, \sleep, \rep, \xAB.

## 活动窗口执行按键

如果不想用全局快捷键，而只对某些软件才有效的话，可以用 “活动窗口执行按键” 命令。

参数这样写：

\Alt\Shift\6 firefox.exe|chrome.exe|msedge.exe

前面是按键，后面是生效的软件，| 的意思就“或者”。
