# swift-chat

[![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
		)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
		)](http://mit-license.org)

![Screen](https://github.com/sagesse-cn/swift-chat/blob/master/Design/Screen%20Snapshoot.gif)

该库目前只是纯UI库, 后面将会添加第三方的聊天服务(例如:融云,百川,腾讯云)使用示例, 再后面将会实现网络部分(swift/XMPP)

因为我没有iOS7的设备, 加上Framework不支持iOS7, 所以该库**不直接支持iOS7**.
如果需要**在iOS7**上使用, 请直接**使用源代码**, 目前iOS7没有经过任何测试.

# TODO
#### 聊天主界面
* [X] **支持消息气泡, NOTE: 这里还要改变**
* [X] **支持下拉加载, NOTE: 这里还需要优化**
* [ ] **支持图文混排(CoreText) - 0%**
* [ ] **支持动态图片/表情 - 0%**
* [X] **支持发送文本消息**
* [X] **支持发送音频消息**
* [X] **支持播放音频消息**
* [X] **支持发送图片消息**
* [X] **支持查看图片消息, NOTE: 图片旋转未实现**
* [X] **支持删除消息功能(一个或多个)**
* [X] **支持撤回消息功能(一个或多个)**
* [X] **支持更新消息功能(一个或多个), 涉及到: 内容改变, 状态改变, 重新发送**
* [ ] **支持发送视频消息**
* [ ] **支持查看视频消息**
* [ ] **支持发送地址消息**
* [ ] **支持查看地址消息**
* [ ] **支持发送文件消息**
* [ ] **支持发送音乐消息**
* [X] **支持拖动(交互式)隐藏键盘**

#### 聊天主界面-输入栏
* [X] **支持自定义表情**
* [ ] **支持禁言**
* [ ] **支持话题**
* [X] **支持左侧菜单项, 设置`SIMChatInputBar.leftBarButtonItems`**
* [X] **支持右侧菜单项, 设置`SIMChatInputBar.rightBarButtonItems`**
* [X] **支持底部菜单项, 设置`SIMChatInputBar.bottomBarButtonItems`**
* [X] **自动高度适应, 如果需要获得改变事件监听`SIMChatInputBarFrameDidChangeNotification`**

#### 聊天主界面-输入面板
* [X] **内置表情, 提供QQ表情和Emoji表情, 如需添加其他, 在配置文件`emoticons.plist`中按格式添加即可**
* [X] **支持扩展内置表情, 在`SIMChatInputPanelEmoticonViewDelegate``inputPanel:emoticonGroupAtIndex:`返回表情组即可. NOTE:这里还要改**
* [X] **支持自定义, 使用`SIMChatInputPanel.registerClass:byIdentifier:`进行注册**
* [X] **支持对讲**
* [ ] **支持变声**
* [ ] **支持录音**
* [ ] **支持(内嵌)选择图片**
* [ ] **支持(内嵌)录制视频**
* [X] **支持自定义工具项, 在`SIMChatInputPanelToolBoxDelegate``inputPanel:itemAtIndex:`返回对应的工具信息**

#### 其他功能
* [X] **支持多图片选择**
* [ ] **支持多图片预览**
* [ ] **优化页面进入速度 - 0%**
* [ ] **优化内存**
* [ ] **优化UITableView - 25%**
* [ ] **把autolayout自动算高换成手动, 效率问题**
* [ ] **支持音频压缩(转换)**

#### 项目
* [ ] **重构(折腾中...) - 50%**
* [ ] **横屏支持 - 0%**
* [ ] **示例 - 0%**
