# swift-chat

[![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
		)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
		)](http://mit-license.org)

因为我没有iOS7的设备, 加上Framework不支持iOS7, 所以该库不直接支持iOS7.
如果需要在iOS7上使用, 请直接使用源代码, 目前iOS7没有经过任何测试.

# TODO

* **输入栏**
* [X] **支持自定义表情**
* [ ] **支持禁言**
* [ ] **支持话题**
* [X] **支持左侧菜单项, 设置`SIMChatInputBar.leftBarButtonItems`**
* [X] **支持右侧菜单项, 设置`SIMChatInputBar.rightBarButtonItems`**
* [X] **支持底部菜单项, 设置`SIMChatInputBar.bottomBarButtonItems`**
* [X] **自动高度适应, 如果需要获得改变事件监听`SIMChatInputBarFrameDidChangeNotification`**
* **输入面板**
* [X] **内置表情, 提供QQ表情和Emoji表情, 如需添加其他, 在配置文件`emoticons.plist`中按格式添加即可**
* [X] **支持扩展内置表情, 使用`SIMChatInputPanel.registerClass:byIdentifier:`进行注册**
* [X] **支持自定义, 在`SIMChatInputPanelEmoticonViewDelegate``inputPanel:emoticonGroupAtIndex:`返回表情组即可. NOTE:这里还要改**
* [X] **支持对讲**
* [ ] **支持变声**
* [ ] **支持录音**
* [ ] **支持(内嵌)选择图片**
* [ ] **支持(内嵌)录制视频**
* [X] **支持自定义工具项, 在`SIMChatInputPanelToolBoxDelegate``inputPanel:itemAtIndex:`返回对应的工具信息**
* **消息**
* [X] **支持下拉加载更多**
* [X] **支持删除功能**
* [X] **支持撤回功能**
* [X] **支持消息气泡, 50%, NOTE: 这里还要改变**
* [ ] **支持消息更新(内容改变/状态改变/重新发送)**
* [X] **支持发送文本消息**
* [ ] **支持发送图片消息**
* [ ] **支持发送地址消息**
* [ ] **支持发送文件消息**
* [ ] **支持发送视频消息**
* [ ] **支持发送音乐消息**
* **其他**
* [ ] **支持图文并排(CoreText)**
* [ ] **支持GIF图片**
* [ ] **优化UITableView(20%)**
* [ ] **把autolayout自动算高换成手动*, 效率问题*
* [ ] **支持音频压缩(转换)**
* [X] **多图选择**
* [ ] **多图片预览**
* [ ] **消息重新排序**
* **BUG**
* [ ] **图片预览, 键盘隐藏bug, 未验证**
* [ ] **选择相机后消息下移**
* **项目**
* [ ] **重构(折腾中...) - 50%**
* [ ] **横屏支持 - 0%**
* [ ] **示例 - 0%**
