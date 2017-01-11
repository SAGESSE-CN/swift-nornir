


# 关于为什么采用inputAccessoryView

 1. 如果使用view，present转场的时候图片会直接覆盖键盘(自定义键盘和选项), 而accessoryView不会
 2. 如果使用accessoryView可以避免侧滑手势的冲突问题
 3. 如果使用view并且self.view是scrollview， 为了保持键盘在低部 需要不停的调整他的位置， 这必然会造成性能损耗


# 需要测试的动画: present, dismiss, pop(返回上一级), pop(从下一级回来), push

accessoryview + subview 可行, 但切换自定义键盘的时候动画可能发生抖动(第三方输入法非常明显), 暂采用该方案. 
发生抖动的原因是因为, 多次调整约束, 导致动画不同步.
或许可以在动画期间添加一个参考视图在window上 - 失败
或许可以在第二次调整约束的时候同时调整动画 - 有效(暂采用, 可是过滤还是不完美, 很生硬)

accessoryview + contentView(subview + 全屏模式), iOS8的dimmsMode不支持(不同步的约束, contentView位置改变了)
accessoryview + superview 好像可行, 但是未测试动画
accessoryview + subview + superview.superview.bottom 失败(动画并没有任何改变)

# 快照的方式有两种:
    -[UIScreen snapshotViewAfterScreenUpdates:]
    -[UIView snapshotViewAfterScreenUpdates:] UIView => UIInputSetContainerView

# TODO
[ ] * - iOS10侧滑空白
[ ] * - iOS10背景不同步
[ ] * - 转屏时强制动画
[ ] * - 系统的上拉出控制中心时事件响应顺序错误(系统问题)
[ ] SAIInputView - iOS8键盘重叠
[ ] SAIInputBarDisplayable - 兼容UICollectionViewController/UITableViewController - 中止(系统行为太多)
[ ] SAIBackgroundViwe - 透明背景显示异常
[ ] SAIInputBar - 切换自定键盘和第三方输入法时的键盘抖动问题 - 还是有问题, 背景导致的(暂时禁用动画)
[x] SAIInputTextField - 动态高度支持
[x] SAIInputAccessoryView - barItem支持, 更随意的组合, 上下左右+中心
[x] SAIInputAccessoryView - barItem对齐支持
[x] SAIInputAccessoryView - barItem自定义支持
[x] SAIInputAccessoryView - barItem选中支持
[x] SAIInputBar - dismmsMode支持
[x] SAIInputTextField - 输入框自定表情支持(TextKit)
[x] SAIInputTextField - 输入框高度限制
[ ] SAIInputTextField - 输入光标
[x] SAIInputTextField - 添加Text和删除Text没有响应事件
[x] SAIInputAccessoryView - 更新barItem - 自动计算
[x] SAIInputAccessoryView - 更新barItem - 动画(包含: 插入, 删除, 更新)
[x] SAIInputView - 自定义键盘的切换动画
[x] SAIInputView - 高度显示错误
[x] SAIInputView - AutoLayout支持
[x] SAIInputView - 多次切换后键盘消失
[ ] SAIInputView - 下拉时隐藏键盘
[x] SAIInputView - 横屏支持
[x] SAIInputAccessoryView - iOS8的图片拉伸问题 
[x] SAIInputAccessoryView - iOS8自定义键盘切换至系统键盘(物理键盘输入)位置异常
[x] * - 分离源文件
[ ] * - code review - p2
[x] * - 内嵌资源(矢量图)
[ ] * - 移除跟踪日志 - p0
[ ] SAIInputAccessoryView - barItem重用支持(现是不允许存在两个相同的barItem)
[ ] SAIInputBar - 横/竖屏双布局(InputAccessView和InputView)
[x] SAIInputAccessoryView - 多次转屏后barItem会报错
[ ] SAIInputAccessoryView - 批量更新barItem(多组更新)
[x] SAIInputBarDisplayable - 弹出事件(两个模式: 跟随模式)
[x] SAIInputBarDisplayable - 大小改变事件, 跟随模式
[ ] SAIInputBarDisplayable - 转屏后contentOffset可能超出contentSize
[x] SAIInputBarDisplayable - dismmsMode支持, scrollIndicatorInsets跟随
[x] SAIInputBarDisplayable - 切换页面时显示异常
[x] SAIInputBarDisplayable - 初始化动画异常
[x] SAIBackgroundViwe - 自定义背景
[ ] SAIInputBar - 添加sizeForKeyboard
