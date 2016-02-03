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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
    
//    weak var delegate: SIMChatInputPanelAudioDelegate?
    
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
        view.registerClass(Talkback.self, forCellWithReuseIdentifier: "Item")
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
}

extension SIMChatInputPanelAudioView {
    private func build() {
        
        addSubview(_contentView)
        
        SIMChatLayout.make(_contentView)
            .top.equ(self).top
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(self).bottom
            .submit()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension SIMChatInputPanelAudioView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
//    public func scrollViewDidScroll(scrollView: UIScrollView) {
//        _pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
//    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return bounds.size
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("Item", forIndexPath: indexPath)
    }
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        if let cell = cell as? Talkback {
//            //cell._delegate = self.delegate
//        }
//        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.purpleColor() : UIColor.orangeColor()
//        if let cell = cell as? ContentCell {
//            cell.accessory = delegate?.inputPanel?(self, itemAtIndex: indexPath.row)
//            cell.delegate = self
//        }
    }
}

// MARK: - Util

extension SIMChatInputPanelAudioView {
    /// 录音状态
    enum RecordState {
    case None       // 空
    case Waiting    // 准备中(切换音频的时候会处于这个状态)
    case Recording  // 录音中
    case Error(NSError) // 错误
    }
}

// MARK: - Talkback

extension SIMChatInputPanelAudioView {
    /// 对讲
    internal class Talkback: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            build()
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            build()
        }
        
        private func build() {
            
            contentView.addSubview(_operatorView)
            contentView.addSubview(_recordButton)
            contentView.addSubview(_tipsLabel)
            contentView.addSubview(_activityView)
            
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
            SIMChatLayout.make(_activityView)
                .right.equ(_tipsLabel).left(-4)
                .centerY.equ(_tipsLabel).centerY
                .submit()
        }
        
        private dynamic func onTouchStart(sender: AnyObject) {
            guard let request = _delegate?.inputPanelShouldStartRecord(self) else {
                return
            }
            SIMLog.trace()
            
            // 进入等待状态
            self._state = .Waiting
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
                    self._isRecording = true
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
                }
            }
        }
        private dynamic func onTouchStop(sender: AnyObject) {
            guard _isRecording else {
                return
            }
            SIMLog.trace()
//            // 正在录音?
//            if !self.recording {
//                self.recordStop()
//                self.delegate?.chatKeyboardAudioViewDidStop?()
//                return
//            }
//            SIMLog.trace()
//            // 完工.
//            self.recordStop()
//            // stop
//            self.delegate?.chatKeyboardAudioViewDidStop?()
//            // 检查状态
//            if preplayView.highlighted {
//                // 需要试听
//                self.onListen(sender)
//            } else if precancelView.highlighted {
//                // 取消
//                self.onCancel(sender)
//            } else {
//                // 完成
//                self.onFinish(sender)
//            }
            
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
                })
            
            _isRecording = false
        }
        private dynamic func onTouchInterrupt(sender: AnyObject) {
            guard _isRecording else {
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
            guard let touch = event?.allTouches()?.first where _isRecording else {
                return
            }
            //SIMLog.trace(touch.locationInView(self))
            var hl = false
            var hr = false
            var sl = CGFloat(1.0)
            var sr = CGFloat(1.0)
            let pt = touch.locationInView(_recordButton)
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
            }
            // 必须要一直维持高亮
            sender.highlighted = true
        }
        
//        ///
//        /// 更新状态
//        /// - 0 空
//        /// - 1 准备中(切换音频的时候会处于这个状态)
//        /// - 2 录音
//        /// - 3 错误
//        ///
//        private func update(flag: Int) {
//            switch flag {
//            case 0: // 无
//                self.tipsLabel.text = "按住说话"
//                self.spectrumView.hidden = true
//                self.activityView.hidden = true
//                self.activityView.stopAnimating()
//            case 1: // 准备中
//                self.tipsLabel.text = "准备中"
//                self.spectrumView.hidden = true
//                self.activityView.hidden = false
//                self.activityView.startAnimating()
//            case 2: // 录音进行中
//                if self.preplayView.highlighted {
//                    self.tipsLabel.text = "松开试听"
//                    self.spectrumView.hidden = true
//                } else if self.precancelView.highlighted {
//                    self.tipsLabel.text = "松开取消"
//                    self.spectrumView.hidden = true
//                } else {
//                    let t = self.delegate?.chatKeyboardAudioViewCurrentTime?() ?? 0
//                    self.tipsLabel.text = String(format: "%0d:%02d", Int(t / 60), Int(t % 60))
//                    self.spectrumView.hidden = false
//                }
//                // 不允许显示的..
//                self.activityView.hidden = true
//                self.activityView.stopAnimating()
//            case 3: // 错误
//                self.tipsLabel.text = "录音错误"
//                self.spectrumView.hidden = true
//                self.activityView.hidden = true
//                self.activityView.stopAnimating()
//            default:
//                break
//            }
//            
//            self.tipsLabel.hidden = false
//        }
        
        weak var _delegate: SIMChatInputPanelAudioDelegate?
        
        var _isRecording = false
        var _state: SIMChatInputPanelAudioView.RecordState = .None {
            didSet {
                switch _state {
                case .None:
                    _tipsLabel.text = "按住说话"
                    _activityView.stopAnimating()
                case .Waiting:
                    _tipsLabel.text = "准备中..."
                    _activityView.startAnimating()
                case .Recording:
                    if _activityView.isAnimating() {
                        _activityView.stopAnimating()
                    }
                    if _leftView.highlighted {
                        _tipsLabel.text = "松开试听"
                    } else if _rightView.highlighted {
                        _tipsLabel.text = "松开取消"
                    } else {
                        _tipsLabel.text = "-:--"
                    }
                case .Error(let error):
                    _tipsLabel.text = error.domain
                    _activityView.stopAnimating()
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
        
//        private(set) lazy var spectrumView = SIMChatSpectrumView(frame: CGRectZero)
        
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
    }
}

// MARK: - Simulate

extension SIMChatInputPanelAudioView {
    /// 变声
    internal class Simulate {
    }
}

// MARK: - Record

extension SIMChatInputPanelAudioView {
    /// 录音
    internal class Record {
    }
}

public protocol SIMChatInputPanelAudioDelegate: SIMChatInputPanelDelegate {
    func inputPanelShouldStartRecord(inputPanel: UIView) -> SIMChatRequest<Void>?
    func inputPanelDidStartRecord(inputPanel: UIView)
    
    func inputPanelDidStopRecord(inputPanel: UIView)
}