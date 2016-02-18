# swift-chat

[![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
		)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
		)](http://mit-license.org)

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
* [X] **支持自定义, 在`SIMChatInputPanelEmoticonViewDelegate``inputPanel:emoticonGroupAtIndex:`返回表情组即可. 注意:这里还要改**
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
* [ ] **完善消息气泡**
* [ ] **添加消息更新(重新发送, 发送完成)**
* [X] **支持发送文本消息**
* [ ] **支持发送图片消息**
* [ ] **支持发送地址消息**
* [ ] **支持发送文件消息**
* [ ] **支持发送视频消息**
* [ ] **支持发送音乐消息**

* [ ] **支持图文并排(CoreText)**
* [ ] **支持GIF图片**
* [ ] **支持音频压缩(转换)**
* [ ] **优化UITableView(20%)**

* [X] **多图选择**
* [ ] **多图片预览**
* [ ] **消息重新排序**

* [ ] **BUG: 图片预览, 键盘隐藏bug, 未验证**
* [ ] **BUG: 选择相机后消息下移**

* [ ] **重构(折腾中...) - 50%**
* [ ] **横屏支持 - 0%**
* [ ] **示例 - 0%**
