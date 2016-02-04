//
//  SIMChatInputPanelAudioView.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 音频输入面板, 内部包含对讲, 录音, 变声
///
internal class SIMChatInputPanelAudioView: UIView, SIMChatInputPanelProtocol {
    /// 录音状态
    internal enum PlayState {
        case None       // 空
        case Waiting    // 准备中(切换音频的时候会处于这个状态)
        case Playing    // 录音中
        case Error(NSError) // 错
        
        // 普通
        func isNone() -> Bool {
            switch self {
            case .None: return true
            default:         return false
            }
        }
        // 正在等待
        func isWaiting() -> Bool {
            switch self {
            case .Waiting: return true
            default:         return false
            }
        }
        // 正在录音中
        func isPlaying() -> Bool {
            switch self {
            case .Playing:   return true
            default:         return false
            }
        }
        //
        func isError() -> Bool {
            switch self {
            case .Error(_): return true
            default:        return false
            }
        }
    }
    /// 录音状态
    internal enum RecordState {
        case None       // 空
        case Waiting    // 准备中(切换音频的时候会处于这个状态)
        case Recording  // 录音中
        case Error(NSError) // 错
        
        // 普通
        func isNone() -> Bool {
            switch self {
            case .None: return true
            default:         return false
            }
        }
        // 正在等待
        func isWaiting() -> Bool {
            switch self {
            case .Waiting: return true
            default:         return false
            }
        }
        // 正在录音中
        func isRecording() -> Bool {
            switch self {
            case .Recording: return true
            default:         return false
            }
        }
        //
        func isError() -> Bool {
            switch self {
            case .Error(_): return true
            default:        return false
            }
        }
    }
    
    /// 代理
    weak var delegate: SIMChatInputPanelDelegate?
    /// 创建面板
    static func inputPanel() -> UIView {
        return self.init()
    }
    /// 获取对应的Item
    static func inputPanelItem() -> SIMChatInputItem {
        let R = { (name: String) -> UIImage? in
            return UIImage(named: name)
        }
        let item = SIMChatInputBaseItem("kb:audio", R("chat_bottom_voice_nor"), R("chat_bottom_voice_press"))
        SIMChatInputPanelContainer.registerClass(self.self, byItem: item)
        return item
    }
    
    @inline(__always) private func build() {
        
        addSubview(_contentView)
        addSubview(_operatorView)
        
        SIMChatLayout.make(_contentView)
            .top.equ(self).top
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(self).bottom
            .submit()
        
        _operatorViewLayout = SIMChatLayout.make(_operatorView)
            .top.equ(self).bottom
            .left.equ(self).left
            .right.equ(self).right
            .height.equ(44)
            .submit()
    }
    
    private var _preview: UIView?
    
    private var _operatorViewLayout: SIMChatLayout?
    private lazy var _operatorView: UIView = {
        let view = UIView()
        let btn1 = UIButton()
        let btn2 = UIButton()
        let line1 = UIView()
        let line2 = UIView()
        
        line1.backgroundColor = UIColor.lightGrayColor()
        line2.backgroundColor = UIColor.lightGrayColor()
        btn1.setTitle("发送", forState: .Normal)
        btn1.setTitleColor(UIColor(argb: 0xFF18B4ED), forState: .Normal)
        btn1.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_nor"), forState: .Normal)
        btn1.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_press"), forState: .Highlighted)
        btn1.addTarget(self, action: "onAudioComfirm", forControlEvents: .TouchUpInside)
        btn2.setTitle("取消", forState: .Normal)
        btn2.setTitleColor(UIColor(argb: 0xFF18B4ED), forState: .Normal)
        btn2.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_nor"), forState: .Normal)
        btn2.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_press"), forState: .Highlighted)
        btn2.addTarget(self, action: "onAudioCancel", forControlEvents: .TouchUpInside)
        
        view.addSubview(btn1)
        view.addSubview(btn2)
        view.addSubview(line1)
        view.addSubview(line2)
        
        SIMChatLayout.make(btn1)
            .top.equ(view).top
            .left.equ(view).left
            .width.equ(btn2).width
            .bottom.equ(view).bottom
            .submit()
        SIMChatLayout.make(btn2)
            .top.equ(view).top
            .left.equ(btn1).right
            .right.equ(view).right
            .bottom.equ(view).bottom
            .submit()
        SIMChatLayout.make(line1)
            .top.equ(view).top
            .left.equ(view).left
            .right.equ(view).right
            .height.equ(1 / UIScreen.mainScreen().scale)
            .submit()
        SIMChatLayout.make(line2)
            .top.equ(view).top
            .width.equ(1 / UIScreen.mainScreen().scale)
            .bottom.equ(view).bottom
            .centerX.equ(view).centerX
            .submit()
        
        return view
    }()
    private lazy var _contentView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.pagingEnabled = true
        view.allowsSelection = false
        view.delaysContentTouches = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.registerClass(SIMChatInputPanelAudioViewOfTalkback.self, forCellWithReuseIdentifier: "Item")
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
}

///
/// 音频输入面板代理
///
internal protocol SIMChatInputPanelAudioViewDelegate: SIMChatInputPanelDelegate {
    ///
    /// 将要启动录音, 返回的是SIMChatRequest, 这是一个异步操作, 如果拒绝这个请求, 可以直接返回nil
    ///
    func inputPanelShouldStartRecord(inputPanel: UIView) -> SIMChatRequest<Void>?
    ///
    /// 开始启动录音
    ///
    func inputPanelDidStartRecord(inputPanel: UIView)
    
    ///
    /// 将要启动播放, 返回的是SIMChatRequest, 这是一个异步操作, 如果拒绝这个请求, 可以直接返回nil
    ///
    func inputPanelShouldStartPlay(inputPanel: UIView) -> SIMChatRequest<Void>?
    ///
    /// 开始启动录音
    ///
    func inputPanelDidStartPlay(inputPanel: UIView)
    
    ///
    /// 停止录音和播放
    ///
    func inputPanelDidStopRecordAndPlay(inputPanel: UIView)
    ///
    /// 完成确认
    ///
    func inputPanelDidAudioComfirm(inputPanel: UIView)
    ///
    /// 完成取消
    ///
    func inputPanelDidAudioCancel(inputPanel: UIView)
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension SIMChatInputPanelAudioView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SIMChatInputPanelAudioViewCellDelegate {
    
//    public func scrollViewDidScroll(scrollView: UIScrollView) {
//        _pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
//    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return bounds.size
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("Item", forIndexPath: indexPath)
    }
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? SIMChatInputPanelAudioViewOfTalkback {
            cell.panel = self
            cell.delegate = self.delegate as? SIMChatInputPanelAudioViewDelegate
            cell.cellDelegate = self
        }
//        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.purpleColor() : UIColor.orangeColor()
//        if let cell = cell as? ContentCell {
//            cell.accessory = delegate?.inputPanel?(self, itemAtIndex: indexPath.row)
//            cell.delegate = self
//        }
    }
    
    /// 预览语音
    func inputPanelShowAudioPreview(inputPanel: UIView) {
        SIMLog.trace()
        
        let view = SIMChatInputPanelAudioViewPreview()
        view.panel = self
        view.frame = bounds
        view.delegate = delegate as? SIMChatInputPanelAudioViewDelegate
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.backgroundColor = _contentView.backgroundColor
        
        insertSubview(view, belowSubview: _operatorView)
        
        view.alpha = 0
        view.reloadData()
        
        UIView.animateWithDuration(0.25) {
            view.alpha = 1
            self._operatorViewLayout?.top = -44
            self._operatorView.layoutIfNeeded()
        }
        
        _preview = view
    }
    /// 关闭预览
    func inputPanelHideAudioPreview(inputPanel: UIView) {
        guard let view = _preview else {
            return
        }
        SIMLog.trace()
        
        UIView.animateWithDuration(0.25,
            animations: {
                view.alpha = 0
                self._operatorViewLayout?.top = 0
                self._operatorView.layoutIfNeeded()
            },
            completion: { _ in
                view.removeFromSuperview()
            })
    }
    
    /// 确认
    dynamic func onAudioComfirm() {
        SIMLog.trace()
        inputPanelHideAudioPreview(self)
        (delegate as? SIMChatInputPanelAudioViewDelegate)?.inputPanelDidAudioComfirm(self)
    }
    /// 取消
    dynamic func onAudioCancel() {
        SIMLog.trace()
        inputPanelHideAudioPreview(self)
        (delegate as? SIMChatInputPanelAudioViewDelegate)?.inputPanelDidAudioCancel(self)
    }
}

///
/// 子面板: 对讲
///
internal class SIMChatInputPanelAudioViewOfTalkback: UICollectionViewCell, SIMChatSpectrumViewDelegate {
    
    func chatSpectrumViewWaveOfLeft(chatSpectrumView: SIMChatSpectrumView) -> Float {
        if _state.isRecording() && !_leftView.highlighted && !_rightView.highlighted {
            let t = SIMChatAudioManager.sharedManager.currentTime
            _tipsLabel.text = String(format: "%0d:%02d", Int(t / 60), Int(t % 60))
        }
        return SIMChatAudioManager.sharedManager.meter(0)
    }
    func chatSpectrumViewWaveOfRight(chatSpectrumView: SIMChatSpectrumView) -> Float {
        return SIMChatAudioManager.sharedManager.meter(0)
    }
    
    @inline(__always) private func build() {
        
        contentView.addSubview(_operatorView)
        contentView.addSubview(_recordButton)
        contentView.addSubview(_tipsLabel)
        contentView.addSubview(_activityView)
        contentView.addSubview(_spectrumView)
        
        SIMChatLayout.make(_recordButton)
            .centerX.equ(contentView).centerX
            .centerY.equ(contentView).centerY(-12)
            .submit()
        
        SIMChatLayout.make(_operatorView)
            .top.equ(_recordButton).top(9)
            .left.equ(contentView).left(20)
            .right.equ(contentView).right(20)
            .submit()
        
        SIMChatLayout.make(_tipsLabel)
            .bottom.equ(_recordButton).top(-20)
            .centerX.equ(contentView).centerX
            .submit()
        SIMChatLayout.make(_spectrumView)
            .centerX.equ(_tipsLabel).centerX
            .centerY.equ(_tipsLabel).centerY
            .submit()
        SIMChatLayout.make(_activityView)
            .right.equ(_tipsLabel).left(-4)
            .centerY.equ(_tipsLabel).centerY
            .submit()
    }
    
    private dynamic func onTouchStart(sender: AnyObject) {
        guard let panel = self.panel where _state.isNone() || _state.isError() else {
            return
        }
        SIMLog.trace()
        guard let request = delegate?.inputPanelShouldStartRecord(panel) else {
            return
        }
        // 进入等待状态
        self._state = .Waiting
        self._lastPoint = nil
        
        request.response {
            guard self._recordButton.highlighted else {
                // 恢复为普通状态
                self._state = .None
                return
            }
            if let error = $0.error {
                // 出错了.
                self._state = .Error(error)
            } else {
                // 进入录音状态
                self._state = .Recording
                self._operatorView.hidden = false
                self._operatorView.alpha = 0
                // 先重置状态
                UIView.animateWithDuration(0.25,
                    animations: {
                        self._leftView.highlighted = false
                        self._leftBackgroundView.highlighted = false
                        self._leftBackgroundView.layer.transform = CATransform3DIdentity
                        self._rightView.highlighted = false
                        self._rightBackgroundView.highlighted = false
                        self._rightBackgroundView.layer.transform = CATransform3DIdentity
                        self._operatorView.alpha = 1
                    },
                    completion: { _ in
                        //self._operatorView.alpha = 1
                        //self._operatorView.hidden = false
                })
                // 启动成功.
                self.delegate?.inputPanelDidStartRecord(panel)
            }
        }
    }
    private dynamic func onTouchStop(sender: AnyObject) {
        guard let panel = self.panel where _state.isRecording() else {
            return
        }
        SIMLog.trace()
        
        delegate?.inputPanelDidStopRecordAndPlay(panel)
        
        if _leftView.highlighted {
            cellDelegate?.inputPanelShowAudioPreview(panel)
        } else if _rightView.highlighted {
            delegate?.inputPanelDidAudioCancel(panel)
        } else {
            delegate?.inputPanelDidAudioComfirm(panel)
        }
        
        if _recordButton.highlighted {
            let ani = CATransition()
            
            ani.duration = 0.25
            ani.fillMode = kCAFillModeBackwards
            ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            ani.type = kCATransitionFade
            ani.subtype = kCATransitionFromTop
            
            _recordButton.layer.addAnimation(ani, forKey: "deselect")
        }
        
        UIView.animateWithDuration(0.25,
            animations: {
                self._leftBackgroundView.layer.transform = CATransform3DIdentity
                self._rightBackgroundView.layer.transform = CATransform3DIdentity
                self._operatorView.alpha = 0
            },
            completion: { _ in
                self._leftView.highlighted = false
                self._leftBackgroundView.highlighted = false
                self._rightView.highlighted = false
                self._rightBackgroundView.highlighted = false
                self._operatorView.hidden = true
                self._state = .None
            })
        _lastPoint = nil
    }
    private dynamic func onTouchInterrupt(sender: AnyObject) {
        guard _state.isRecording() else {
            return
        }
        SIMLog.trace()
        // 如果中断了, 认为他是选择了试听
        _leftView.highlighted = true
        _leftBackgroundView.highlighted = true
        _leftBackgroundView.layer.transform = CATransform3DIdentity
        _rightView.highlighted = false
        _rightBackgroundView.highlighted = false
        _rightBackgroundView.layer.transform = CATransform3DIdentity
        // 走正常结束流程
        onTouchStop(sender)
    }
    private dynamic func onTouchDrag(sender: UIButton, withEvent event: UIEvent?) {
        // 必须要一直维持高亮
        sender.highlighted = true
        
        guard let touch = event?.allTouches()?.first where _state.isRecording() else {
            return
        }
        //SIMLog.trace(touch.locationInView(self))
        var hl = false
        var hr = false
        var sl = CGFloat(1.0)
        var sr = CGFloat(1.0)
        let pt = touch.locationInView(_recordButton)
        
        // 检查阀值避免提交大量动画
        if let lpt = _lastPoint where fabs(sqrt(lpt.x * lpt.x + lpt.y * lpt.y) - sqrt(pt.x * pt.x + pt.y * pt.y)) < 1 {
            return
        }
        _lastPoint = pt
        if pt.x < 0 {
            // 左边
            var pt2 = touch.locationInView(_leftBackgroundView)
            pt2.x -= _leftBackgroundView.bounds.width / 2
            pt2.y -= _leftBackgroundView.bounds.height / 2
            let r = max(sqrt(pt2.x * pt2.x + pt2.y * pt2.y), 0)
            // 是否高亮
            hl = r < _leftBackgroundView.bounds.width / 2
            // 计算出左边的缩放
            sl = 1.0 + max((80 - r) / 80, 0) * 0.75
        } else if pt.x > _recordButton.bounds.width {
            // 右边
            var pt2 = touch.locationInView(_rightBackgroundView)
            pt2.x -= _rightBackgroundView.bounds.width / 2
            pt2.y -= _rightBackgroundView.bounds.height / 2
            let r = max(sqrt(pt2.x * pt2.x + pt2.y * pt2.y), 0)
            // 是否高亮
            hr = r < _rightBackgroundView.bounds.width / 2
            // 计算出右边的缩放
            sr = 1.0 + max((80 - r) / 80, 0) * 0.75
        }
        UIView.animateWithDuration(0.25) {
            self._leftView.highlighted = hl
            self._leftBackgroundView.highlighted = hl
            self._leftBackgroundView.layer.transform = CATransform3DMakeScale(sl, sl, 1)
            self._rightView.highlighted = hr
            self._rightBackgroundView.highlighted = hr
            self._rightBackgroundView.layer.transform = CATransform3DMakeScale(sr, sr, 1)
            self._state = .Recording
        }
    }
    
    weak var panel: UIView?
    weak var delegate: SIMChatInputPanelAudioViewDelegate?
    weak var cellDelegate: SIMChatInputPanelAudioViewCellDelegate?
    
    var _lastPoint: CGPoint?
    
    var _state: SIMChatInputPanelAudioView.RecordState = .None {
        didSet {
            switch _state {
            case .None:
                _tipsLabel.text = "按住说话"
                _spectrumView.hidden = true
                _activityView.stopAnimating()
            case .Waiting:
                _tipsLabel.text = "准备中..."
                _spectrumView.hidden = true
                _activityView.startAnimating()
            case .Recording:
                if _activityView.isAnimating() {
                    _activityView.stopAnimating()
                }
                if _leftView.highlighted {
                    _tipsLabel.text = "松开试听"
                    _spectrumView.hidden = true
                } else if _rightView.highlighted {
                    _tipsLabel.text = "松开取消"
                    _spectrumView.hidden = true
                } else {
                    let t = SIMChatAudioManager.sharedManager.currentTime
                    _tipsLabel.text = String(format: "%0d:%02d", Int(t / 60), Int(t % 60))
                    _spectrumView.hidden = false
                }
            case .Error(let error):
                _spectrumView.hidden = true
                _tipsLabel.text = error.domain
                _activityView.stopAnimating()
            }
            if _state.isRecording() {
                if !_spectrumView.isAnimating() {
                    _spectrumView.startAnimating()
                }
            } else {
                if _spectrumView.isAnimating() {
                    _spectrumView.stopAnimating()
                }
            }
        }
    }
    
    lazy var _tipsLabel: UILabel = {
        let view = UILabel()
        view.text = "按住说话"
        view.font = UIFont.systemFontOfSize(16)
        view.textColor = UIColor(argb: 0xFF7B7B7B)
        return view
    }()
    lazy var _activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        view.hidesWhenStopped = true
        view.hidden = true
        return view
    }()
    lazy var _spectrumView: SIMChatSpectrumView = {
        let view = SIMChatSpectrumView(frame: CGRectZero)
        view.color = UIColor(argb: 0xFFFB7A0D)
        view.hidden = true
        view.delegate = self
        return view
    }()
    
    lazy var _leftView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "simchat_keyboard_voice_operate_listen_nor")
        view.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_listen_press")
        return view
    }()
    lazy var _leftBackgroundView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "simchat_keyboard_voice_operate_nor")
        view.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_press")
        return view
    }()
    lazy var _rightView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "simchat_keyboard_voice_operate_delete_nor")
        view.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_delete_press")
        return view
    }()
    lazy var _rightBackgroundView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "simchat_keyboard_voice_operate_nor")
        view.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_press")
        return view
    }()
    lazy var _operatorView: UIView = {
        let view = UIView()
        let line = UIImageView()
        
        line.image = UIImage(named: "simchat_keyboard_voice_line")
        view.hidden = true
        
        // add view
        view.addSubview(line)
        view.addSubview(self._rightBackgroundView)
        view.addSubview(self._leftBackgroundView)
        view.addSubview(self._rightView)
        view.addSubview(self._leftView)
        
        SIMChatLayout.make(line)
            .top.equ(view).top(14)
            .left.equ(view).left(3.5)
            .right.equ(view).right(3.5)
            .bottom.equ(view).bottom
            .submit()
        SIMChatLayout.make(self._leftBackgroundView)
            .top.equ(view).top
            .left.equ(view).left
            .submit()
        SIMChatLayout.make(self._rightBackgroundView)
            .top.equ(view).top
            .right.equ(view).right
            .submit()
        SIMChatLayout.make(self._leftView)
            .centerX.equ(self._leftBackgroundView).centerX
            .centerY.equ(self._leftBackgroundView).centerY
            .submit()
        SIMChatLayout.make(self._rightView)
            .centerX.equ(self._rightBackgroundView).centerX
            .centerY.equ(self._rightBackgroundView).centerY
            .submit()
        
        return view
    }()
    lazy var _recordButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(named: "simchat_keyboard_voice_icon_record"), forState: .Normal)
        view.setImage(UIImage(named: "simchat_keyboard_voice_icon_record"), forState: .Highlighted)
        view.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_button_nor"), forState: .Normal)
        view.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_button_press"), forState: .Highlighted)
        
        // add events
        view.addTarget(self, action: "onTouchStart:", forControlEvents: .TouchDown)
        view.addTarget(self, action: "onTouchDrag:withEvent:", forControlEvents: .TouchDragInside)
        view.addTarget(self, action: "onTouchDrag:withEvent:", forControlEvents: .TouchDragOutside)
        view.addTarget(self, action: "onTouchStop:", forControlEvents: .TouchUpInside)
        view.addTarget(self, action: "onTouchStop:", forControlEvents: .TouchUpOutside)
        view.addTarget(self, action: "onTouchInterrupt:", forControlEvents: .TouchCancel)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
}

///
/// 子面板: 语音预览
///
internal class SIMChatInputPanelAudioViewPreview: UIView, SIMChatSpectrumViewDelegate {
    
    func chatSpectrumViewWaveOfLeft(chatSpectrumView: SIMChatSpectrumView) -> Float {
        if _state.isPlaying() {
            let t = SIMChatAudioManager.sharedManager.currentTime
            _tipsLabel.text = String(format: "%0d:%02d", Int(t / 60), Int(t % 60))
        }
        return SIMChatAudioManager.sharedManager.meter(0)
    }
    func chatSpectrumViewWaveOfRight(chatSpectrumView: SIMChatSpectrumView) -> Float {
        return SIMChatAudioManager.sharedManager.meter(0)
    }
    
    @inline(__always) private func build() {
        
        _playButton.layer.addSublayer(_playProgress)
        
        addSubview(_playButton)
        addSubview(_tipsLabel)
        addSubview(_activityView)
        addSubview(_spectrumView)
        
        SIMChatLayout.make(_playButton)
            .centerX.equ(self).centerX
            .centerY.equ(self).centerY(-12)
            .submit()
        SIMChatLayout.make(_tipsLabel)
            .bottom.equ(_playButton).top(-20)
            .centerX.equ(self).centerX
            .submit()
        SIMChatLayout.make(_spectrumView)
            .centerX.equ(_tipsLabel).centerX
            .centerY.equ(_tipsLabel).centerY
            .submit()
        SIMChatLayout.make(_activityView)
            .right.equ(_tipsLabel).left(-4)
            .centerY.equ(_tipsLabel).centerY
            .submit()
    }
    
    weak var panel: UIView?
    weak var delegate: SIMChatInputPanelAudioViewDelegate?
    
    func reloadData() {
//        guard let panel = self.panel else {
//            return
//        }
//        guard let request = delegate?.inputPanelShouldStartPlay(panel) else {
//            return
//        }
//        
//        // 等待
//        self._state = .Waiting
//        
//        request.response {
//            if let error = $0.error {
//                // 出错了.
//                self._state = .Error(error)
//            } else {
//                // 播放中
//                self._state = .Playing
//            }
//        }
    }
    
    var _state: SIMChatInputPanelAudioView.PlayState = .None {
        didSet {
            switch _state {
            case .None:
                _tipsLabel.text = "点击播放"
                _spectrumView.hidden = true
                _activityView.stopAnimating()
            case .Waiting:
                _tipsLabel.text = "准备中..."
                _spectrumView.hidden = true
                _activityView.startAnimating()
            case .Playing:
                if _activityView.isAnimating() {
                    _activityView.stopAnimating()
                }
                let t = SIMChatAudioManager.sharedManager.currentTime
                _tipsLabel.text = String(format: "%0d:%02d", Int(t / 60), Int(t % 60))
                _spectrumView.hidden = false
            case .Error(let error):
                _spectrumView.hidden = true
                _tipsLabel.text = error.domain
                _activityView.stopAnimating()
            }
        }
    }
    /// 正在播放
    var _timer: NSTimer?
    var _startAt: CFTimeInterval = 0
    var _duration: NSTimeInterval = 0
    var _playing: Bool = false {
        willSet {
            // 如果没有任意改变, 那就不浪费资源了
            if newValue == _playing {
                return
            }
            if newValue {
                // 正在播放
                _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_nor"), forState: .Normal)
                _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_press"), forState: .Highlighted)
            } else {
                // 停止了
                _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_nor"), forState: .Normal)
                _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_press"), forState: .Highlighted)
            }
            // duang
            let ani = CATransition()
            
            ani.duration = 0.25
            ani.fillMode = kCAFillModeBackwards
            ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            ani.type = kCATransitionFade
            ani.subtype = kCATransitionFromTop
            
            _playButton.layer.addAnimation(ani, forKey: "s")
            
            // 更新频谱动画
            if newValue {
                _spectrumView.startAnimating()
            } else {
                _spectrumView.stopAnimating()
            }
        }
    }
    
    dynamic func onTimer(sender: AnyObject) {
        // 计算当前进度
        let cur = CACurrentMediaTime() - _startAt
        // 更新进度
        _playProgress.strokeEnd = CGFloat(cur / max(_duration, 0.1))
        // 完成了?
        if cur > _duration + 0.1 {
            // ok 完成
            self.onStop()
        }
    }
    
    dynamic func onPlayOrPause() {
        if _playing {
            // 正在播放, 那就停止
            self.onStop()
        } else {
            // 没有播放, 开始播放
            self.onPlay()
        }
    }
    
    /// 播放
    @inline(__always) func onPlay() {
        guard let panel = self.panel else {
            return
        }
        SIMLog.trace()
        guard let request = delegate?.inputPanelShouldStartPlay(panel) else {
            return
        }
        
        // 重置
        _playProgress.strokeEnd = 0
        _playProgress.removeAllAnimations()
        // 进行等待
        _state = .Waiting
        
        request.response {
            if let error = $0.error {
                // 出错了.
                self._state = .Error(error)
            } else {
                // 进入播放状态
                self._state = .Playing
                self._playing = true
                self.delegate?.inputPanelDidStartPlay(panel)
                
                // 进入计时
                dispatch_async(dispatch_get_main_queue()) {
                    self._duration = SIMChatAudioManager.sharedManager.duration
                    self._startAt = CACurrentMediaTime()
                    self._timer = NSTimer.scheduledTimerWithTimeInterval2(0.1, self, "onTimer:")
                }
            }
        }
    }
    /// 停止
    @inline(__always) func onStop() {
        guard let panel = self.panel else {
            return
        }
        SIMLog.trace()
        
        delegate?.inputPanelDidStopRecordAndPlay(panel)
        
        _timer?.invalidate()
        _timer = nil
        
        _state = .None
        _playing = false
        _playProgress.strokeEnd = 0
        _playProgress.removeAllAnimations()
    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        if newWindow == nil && _timer != nil {
            onStop()
        }
    }
    
    lazy var _tipsLabel: UILabel = {
        let view = UILabel()
        view.text = "点击播放"
        view.font = UIFont.systemFontOfSize(16)
        view.textColor = UIColor(argb: 0xFF7B7B7B)
        return view
    }()
    lazy var _activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        view.hidesWhenStopped = true
        view.hidden = true
        return view
    }()
    
    lazy var _spectrumView: SIMChatSpectrumView = {
        let view = SIMChatSpectrumView(frame: CGRectZero)
        view.color = UIColor(argb: 0xFFFB7A0D)
        view.hidden = true
        view.delegate = self
        return view
    }()
    lazy var _playButton: UIButton = {
        let view = UIButton()
        
        view.addTarget(self, action: "onPlayOrPause", forControlEvents: .TouchUpInside)
        view.setImage(UIImage(named: "simchat_keyboard_voice_button_play_nor"), forState: .Normal)
        view.setImage(UIImage(named: "simchat_keyboard_voice_button_play_press"), forState: .Highlighted)
        view.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_background"), forState: .Normal)
        view.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_background"), forState: .Highlighted)
//
//                if newValue {
//                    // 正在播放
//                    playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_nor"), forState: .Normal)
//                    playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_press"), forState: .Highlighted)
//                } else {
//                    // 停止了
//                    playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_nor"), forState: .Normal)
//                    playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_press"), forState: .Highlighted)
//        // add events
//        view.addTarget(self, action: "onTouchStart:", forControlEvents: .TouchDown)
//        view.addTarget(self, action: "onTouchDrag:withEvent:", forControlEvents: .TouchDragInside)
//        view.addTarget(self, action: "onTouchDrag:withEvent:", forControlEvents: .TouchDragOutside)
//        view.addTarget(self, action: "onTouchStop:", forControlEvents: .TouchUpInside)
//        view.addTarget(self, action: "onTouchStop:", forControlEvents: .TouchUpOutside)
//        view.addTarget(self, action: "onTouchInterrupt:", forControlEvents: .TouchCancel)
        
        view.sizeToFit()
        
        return view
    }()
    lazy var _playProgress: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 3.5
        layer.fillColor = nil
        layer.strokeColor = UIColor(argb: 0xFF18B4ED).CGColor
        layer.strokeStart = 0
        layer.strokeEnd = 0
        layer.frame = self._playButton.bounds
        layer.path = UIBezierPath(ovalInRect: self._playButton.bounds).CGPath
        layer.transform = CATransform3DMakeRotation((-90 / 180) * CGFloat(M_PI), 0, 0, 1)
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
}

///
/// 子面板: 语音预览代理
///
internal protocol SIMChatInputPanelAudioViewCellDelegate: class {
    func inputPanelShowAudioPreview(inputPanel: UIView)
}

internal class SIMChatInputPanelAudioViewOfSimulate: UICollectionViewCell {
}

internal class SIMChatInputPanelAudioViewOfRecord: UICollectionViewCell {
}