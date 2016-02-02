//
//  SIMChatInputPanel+Audio.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit


@objc public protocol SIMChatInputPanelDelegateAudio: SIMChatInputPanelDelegate {
    func inputPanel(inputPanel: UIView, shouldBeginRecord handler: AnyObject)
}

extension SIMChatInputPanel {
    public class Audio: UIView {
        public override init(frame: CGRect) {
            super.init(frame: frame)
            build()
        }
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            build()
        }
        
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
}

extension SIMChatInputPanel.Audio {
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

extension SIMChatInputPanel.Audio: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
//    public func scrollViewDidScroll(scrollView: UIScrollView) {
//        _pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
//    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return bounds.size
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("Item", forIndexPath: indexPath)
    }
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.purpleColor() : UIColor.orangeColor()
//        if let cell = cell as? ContentCell {
//            cell.accessory = delegate?.inputPanel?(self, itemAtIndex: indexPath.row)
//            cell.delegate = self
//        }
    }
}

// MARK: - Talkback

extension SIMChatInputPanel.Audio {
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
            SIMLog.trace()
//            // 正在录音呢
//            if self.recording {
//                return
//            }
            
            
//            _operatorView.hidden = false
//            _operatorView.alpha = 0
//            // 先重置状态
//            UIView.animateWithDuration(0.25,
//                animations: {
//                    self._leftView.highlighted = false
//                    self._leftBackgroundView.highlighted = false
//                    self._leftBackgroundView.layer.transform = CATransform3DIdentity
//                    self._rightView.highlighted = false
//                    self._rightBackgroundView.highlighted = false
//                    self._rightBackgroundView.layer.transform = CATransform3DIdentity
//                    self._operatorView.alpha = 1
//                },
//                completion: { _ in
//                    //self._operatorView.alpha = 1
//                    //self._operatorView.hidden = false
//                })
//           
//            _isRecording = true
            
            
//            // 进入准备状态
//            self.update(1)
//            // 启动.
//            // 完成了之后重新调用startRecord
//            dispatch_async(dispatch_get_main_queue()) {
//                self.delegate?.chatKeyboardAudioViewDidStartRecord?()
//            }
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
        
        var _isRecording = false
        
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

extension SIMChatInputPanel.Audio {
    /// 变声
    internal class Simulate {
    }
}

// MARK: - Record

extension SIMChatInputPanel.Audio {
    /// 录音
    internal class Record {
    }
}