//
//  SIMChatInputPanelAudioView.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

//
//// TODO: 混乱. 需要重构
//
/////
///// 音频输入面板代理
/////
//internal protocol SIMChatInputPanelAudioViewDelegate: SIMChatInputPanelDelegate {
//    
//    ///
//    /// 请求一个音频录音器, 如果拒绝该请求返回nil
//    ///
//    func inputPanelAudioRecorder(_ inputPanel: UIView, resource: SIMChatResourceProtocol) -> SIMChatMediaRecorderProtocol?
//    ///
//    /// 请求一个音频播放器, 如果拒绝该请求返回nil
//    ///
//    func inputPanelAudioPlayer(_ inputPanel: UIView, resource: SIMChatResourceProtocol) -> SIMChatMediaPlayerProtocol?
//    
//    ///
//    /// 将要发送音频
//    ///
//    func inputPanelShouldSendAudio(_ inputPanel: UIView, resource: SIMChatResourceProtocol, duration: TimeInterval) -> Bool
//    ///
//    /// 发送音频
//    ///
//    func inputPanelDidSendAudio(_ inputPanel: UIView, resource: SIMChatResourceProtocol, duration: TimeInterval)
//}
//
//
/////
///// 音频输入面板, 内部包含对讲, 录音, 变声
/////
//internal class SIMChatInputPanelAudioView: UIView, SIMChatInputPanelProtocol {
//    /// 录音状态
//    internal enum PlayState {
//        case none       // 空
//        case waiting    // 准备中(切换音频的时候会处于这个状态)
//        case playing    // 录音中
//        case error(NSError) // 错
//        
//        // 普通
//        func isNone() -> Bool {
//            switch self {
//            case .none: return true
//            default:         return false
//            }
//        }
//        // 正在等待
//        func isWaiting() -> Bool {
//            switch self {
//            case .waiting: return true
//            default:         return false
//            }
//        }
//        // 正在录音中
//        func isPlaying() -> Bool {
//            switch self {
//            case .playing:   return true
//            default:         return false
//            }
//        }
//        //
//        func isError() -> Bool {
//            switch self {
//            case .error(_): return true
//            default:        return false
//            }
//        }
//    }
//    /// 录音状态
//    internal enum RecordState {
//        case none       // 空
//        case waiting    // 准备中(切换音频的时候会处于这个状态)
//        case recording  // 录音中
//        case progressing // 处理中
//        case error(NSError) // 错
//        
//        // 普通
//        func isNone() -> Bool {
//            switch self {
//            case .none: return true
//            default:         return false
//            }
//        }
//        // 正在等待
//        func isWaiting() -> Bool {
//            switch self {
//            case .waiting: return true
//            default:         return false
//            }
//        }
//        // 正在录音中
//        func isRecording() -> Bool {
//            switch self {
//            case .recording: return true
//            default:         return false
//            }
//        }
//        func isProgressing() -> Bool {
//            switch self {
//            case .progressing: return true
//            default:         return false
//            }
//        }
//        //
//        func isError() -> Bool {
//            switch self {
//            case .error(_): return true
//            default:        return false
//            }
//        }
//    }
//    
//    /// 代理
//    weak var delegate: SIMChatInputPanelDelegate?
//    /// 创建面板
//    static func inputPanel() -> UIView {
//        return self.init()
//    }
//    /// 获取对应的Item
//    static func inputPanelItem() -> SIMChatInputItemProtocol {
//        let R = { (name: String) -> UIImage? in
//            return SIMChatBundle.imageWithResource("InputBar/\(name).png")
//        }
//        let item = SIMChatBaseInputItem("kb:audio", R("chat_bottom_PTT_nor"), R("chat_bottom_PTT_press"))
//        SIMChatInputPanelContainer.registerClass(self.self, byItem: item)
//        return item
//    }
//    
//    @inline(__always) private func build() {
//        
//        addSubview(_contentView)
//        addSubview(_operatorView)
//        
//        SIMChatLayout.make(_contentView)
//            .top.equ(self).top
//            .left.equ(self).left
//            .right.equ(self).right
//            .bottom.equ(self).bottom
//            .submit()
//        
//        _operatorViewLayout = SIMChatLayout.make(_operatorView)
//            .top.equ(self).bottom
//            .left.equ(self).left
//            .right.equ(self).right
//            .height.equ(44)
//            .submit2()
//    }
//    
//    private var _preview: UIView?
//    
//    private var _operatorViewLayout: SIMChatLayout?
//    private lazy var _operatorView: UIView = {
//        let view = UIView()
//        let btn1 = UIButton()
//        let btn2 = UIButton()
//        let line1 = UIView()
//        let line2 = UIView()
//        
//        line1.backgroundColor = UIColor.lightGray
//        line2.backgroundColor = UIColor.lightGray
//        btn1.setTitle("发送", for: UIControlState())
//        btn1.setTitleColor(UIColor(argb: 0xFF18B4ED), for: UIControlState())
//        btn1.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_nor"), for: UIControlState())
//        btn1.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_press"), for: .highlighted)
//        btn1.addTarget(self, action: #selector(type(of: self).onAudioComfirm), for: .touchUpInside)
//        btn2.setTitle("取消", for: UIControlState())
//        btn2.setTitleColor(UIColor(argb: 0xFF18B4ED), for: UIControlState())
//        btn2.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_nor"), for: UIControlState())
//        btn2.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_press"), for: .highlighted)
//        btn2.addTarget(self, action: #selector(type(of: self).onAudioCancel), for: .touchUpInside)
//        
//        view.addSubview(btn1)
//        view.addSubview(btn2)
//        view.addSubview(line1)
//        view.addSubview(line2)
//        
//        SIMChatLayout.make(btn1)
//            .top.equ(view).top
//            .left.equ(view).left
//            .width.equ(btn2).width
//            .bottom.equ(view).bottom
//            .submit()
//        SIMChatLayout.make(btn2)
//            .top.equ(view).top
//            .left.equ(btn1).right
//            .right.equ(view).right
//            .bottom.equ(view).bottom
//            .submit()
//        SIMChatLayout.make(line1)
//            .top.equ(view).top
//            .left.equ(view).left
//            .right.equ(view).right
//            .height.equ(1 / UIScreen.main.scale)
//            .submit()
//        SIMChatLayout.make(line2)
//            .top.equ(view).top
//            .width.equ(1 / UIScreen.main.scale)
//            .bottom.equ(view).bottom
//            .centerX.equ(view).centerX
//            .submit()
//        
//        return view
//    }()
//    private lazy var _contentView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.sectionInset = UIEdgeInsetsZero
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
//        let view = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
//        view.delegate = self
//        view.dataSource = self
//        view.isPagingEnabled = true
//        view.scrollsToTop = false
//        view.allowsSelection = false
//        view.delaysContentTouches = false
//        view.showsVerticalScrollIndicator = false
//        view.showsHorizontalScrollIndicator = false
//        view.register(SIMChatInputPanelAudioViewOfTalkback.self, forCellWithReuseIdentifier: "Item")
//        view.backgroundColor = UIColor.white
//        return view
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        build()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        build()
//    }
//}
//
//// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
//
//extension SIMChatInputPanelAudioView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SIMChatInputPanelAudioViewCellDelegate {
//    
////    public func scrollViewDidScroll(scrollView: UIScrollView) {
////        _pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
////    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return bounds.size
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
//    }
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let cell = cell as? SIMChatInputPanelAudioViewOfTalkback {
//            cell.panel = self
//            cell.delegate = self.delegate as? SIMChatInputPanelAudioViewDelegate
//            cell.cellDelegate = self
//        }
////        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.purpleColor() : UIColor.orangeColor()
////        if let cell = cell as? ContentCell {
////            cell.accessory = delegate?.inputPanel?(self, itemAtIndex: indexPath.row)
////            cell.delegate = self
////        }
//    }
//    
//    func inputPanelShowAudioPreview(_ inputPanel: UIView, resource: SIMChatResourceProtocol, duration: TimeInterval) {
//        SIMLog.trace()
//        
//        let view = SIMChatInputPanelAudioViewPreview()
//        view.panel = self
//        view.frame = bounds
//        view.resource = resource
//        view.duration = duration
//        view.delegate = delegate as? SIMChatInputPanelAudioViewDelegate
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.backgroundColor = _contentView.backgroundColor
//        
//        insertSubview(view, belowSubview: _operatorView)
//        
//        view.alpha = 0
//        
//        UIView.animate(withDuration: 0.25) {
//            view.alpha = 1
//            self._operatorViewLayout?.top = -44
//            self._operatorView.layoutIfNeeded()
//        }
//        
//        _preview = view
//    }
//    /// 关闭预览
//    func inputPanelHideAudioPreview(_ inputPanel: UIView) {
//        guard let view = _preview else {
//            return
//        }
//        SIMLog.trace()
//        
//        UIView.animate(withDuration: 0.25,
//            animations: {
//                view.alpha = 0
//                self._operatorViewLayout?.top = 0
//                self._operatorView.layoutIfNeeded()
//            },
//            completion: { _ in
//                view.removeFromSuperview()
//            })
//    }
//    
//    /// 确认
//    dynamic func onAudioComfirm() {
//        SIMLog.trace()
//        let tv = _preview
//        inputPanelHideAudioPreview(self)
//        if let view = tv as? SIMChatInputPanelAudioViewPreview, let resource = view.resource {
//            (delegate as? SIMChatInputPanelAudioViewDelegate)?.inputPanelDidSendAudio(self,
//                resource: resource,
//                duration: view.duration)
//        }
//    }
//    /// 取消
//    dynamic func onAudioCancel() {
//        SIMLog.trace()
//        inputPanelHideAudioPreview(self)
//        //并不需要操作
//        //(delegate as? SIMChatInputPanelAudioViewDelegate)?.inputPanelDidAudioCancel(self)
//    }
//}
//
/////
///// 子面板: 对讲
/////
//internal class SIMChatInputPanelAudioViewOfTalkback: UICollectionViewCell, SIMChatSpectrumViewDelegate, SIMChatMediaRecorderDelegate {
//    
//    func chatSpectrumViewWaveOfLeft(_ chatSpectrumView: SIMChatSpectrumView) -> Float {
//        if _state.isRecording() && !_leftView.isHighlighted && !_rightView.isHighlighted {
//            let t = _recorder?.currentTime ?? 0
//            _tipsLabel.text = String(format: "%0d:%02d", Int(t / 60), Int(t.truncatingRemainder(dividingBy: 60)))
//        }
//        return _recorder?.meter(0) ?? -60
//    }
//    func chatSpectrumViewWaveOfRight(_ chatSpectrumView: SIMChatSpectrumView) -> Float {
//        return _recorder?.meter(0) ?? -60
//    }
//    
//    @inline(__always) private func build() {
//        
//        contentView.addSubview(_operatorView)
//        contentView.addSubview(_recordButton)
//        contentView.addSubview(_tipsLabel)
//        contentView.addSubview(_activityView)
//        contentView.addSubview(_spectrumView)
//        
//        SIMChatLayout.make(_recordButton)
//            .centerX.equ(contentView).centerX
//            .centerY.equ(contentView).centerY(-12)
//            .submit()
//        
//        SIMChatLayout.make(_operatorView)
//            .top.equ(_recordButton).top(9)
//            .left.equ(contentView).left(20)
//            .right.equ(contentView).right(20)
//            .submit()
//        
//        SIMChatLayout.make(_tipsLabel)
//            .bottom.equ(_recordButton).top(-20)
//            .centerX.equ(contentView).centerX
//            .submit()
//        SIMChatLayout.make(_spectrumView)
//            .centerX.equ(_tipsLabel).centerX
//            .centerY.equ(_tipsLabel).centerY
//            .submit()
//        SIMChatLayout.make(_activityView)
//            .right.equ(_tipsLabel).left(-4)
//            .centerY.equ(_tipsLabel).centerY
//            .submit()
//    }
//    
//    private var _confirm: Bool = true
//    private weak var _recorder: SIMChatMediaRecorderProtocol?
//    
//    func recorderShouldPrepare(_ recorder: SIMChatMediaRecorderProtocol) -> Bool {
//        guard self._recordButton.isHighlighted else {
//            // 恢复为普通状态
//            _state = .none
//            return false
//        }
//        return true
//    }
//    func recorderDidPrepare(_ recorder: SIMChatMediaRecorderProtocol) {
//        SIMLog.trace()
//    }
//    
//    func recorderShouldRecord(_ recorder: SIMChatMediaRecorderProtocol) -> Bool {
//        guard self._recordButton.isHighlighted else {
//            // 恢复为普通状态
//            _state = .none
//            return false
//        }
//        return true
//    }
//    func recorderDidRecord(_ recorder: SIMChatMediaRecorderProtocol) {
//        SIMLog.trace()
//        // 进入录音状态
//        _state = .recording
//        _operatorView.isHidden = false
//        _operatorView.alpha = 0
//        // 先重置状态
//        UIView.animate(withDuration: 0.25,
//            animations: {
//                self._leftView.isHighlighted = false
//                self._leftBackgroundView.isHighlighted = false
//                self._leftBackgroundView.layer.transform = CATransform3DIdentity
//                self._rightView.isHighlighted = false
//                self._rightBackgroundView.isHighlighted = false
//                self._rightBackgroundView.layer.transform = CATransform3DIdentity
//                self._operatorView.alpha = 1
//            },
//            completion: { _ in
//                //self._operatorView.alpha = 1
//                //self._operatorView.hidden = false
//        })
//    }
//    func recorderDidStop(_ recorder: SIMChatMediaRecorderProtocol) {
//        SIMLog.trace()
//        
//        // 进入处理模式
//        _state = .progressing
//        
//        // 放手就停下了
//        if _recordButton.isHighlighted {
//            let ani = CATransition()
//            
//            ani.duration = 0.25
//            ani.fillMode = kCAFillModeBackwards
//            ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//            ani.type = kCATransitionFade
//            ani.subtype = kCATransitionFromTop
//            
//            _recordButton.layer.add(ani, forKey: "deselect")
//        }
//        
//        UIView.animate(withDuration: 0.25,
//            animations: {
//                self._leftBackgroundView.layer.transform = CATransform3DIdentity
//                self._rightBackgroundView.layer.transform = CATransform3DIdentity
//                self._operatorView.alpha = 0
//            },
//            completion: { _ in
//                self._leftView.isHighlighted = false
//                self._leftBackgroundView.isHighlighted = false
//                self._rightView.isHighlighted = false
//                self._rightBackgroundView.isHighlighted = false
//                self._operatorView.isHidden = true
//            })
//        
//        _lastPoint = nil
//    }
//    func recorderDidCancel(_ recorder: SIMChatMediaRecorderProtocol) {
//        SIMLog.trace()
//        
//        // 取消了
//        _state = .none
//        _recordButton.isUserInteractionEnabled = true
//    }
//    func recorderDidFinish(_ recorder: SIMChatMediaRecorderProtocol) {
//        SIMLog.trace()
//        
//        // 检查用户选择的是什么.
//        if let panel = panel {
//            if _confirm {
//                delegate?.inputPanelDidSendAudio(panel,
//                    resource: recorder.resource,
//                    duration: recorder.currentTime)
//            } else {
//                cellDelegate?.inputPanelShowAudioPreview(panel,
//                    resource: recorder.resource,
//                    duration: recorder.currentTime)
//            }
//        }
//        
//        // 完成
//        _state = .none
//        _recordButton.isUserInteractionEnabled = true
//    }
//    func recorderDidErrorOccur(_ recorder: SIMChatMediaRecorderProtocol, error: NSError) {
//        SIMLog.trace()
//        // 出错了.
//        _state = .error(error)
//        _recordButton.isUserInteractionEnabled = true
//    }
//    
//    /// 临时录音路径
//    @inline(__always) private func _temporaryAudioRecordResource() -> SIMChatResourceProtocol {
//        return SIMChatBaseAudioResource(NSTemporaryDirectory() + "record.acc")
//    }
//    
//    
//    private dynamic func onTouchStart(_ sender: AnyObject) {
//        guard let panel = panel , _state.isNone() || _state.isError() else {
//            return
//        }
//        // 请求一个录音器
//        guard let recorder = delegate?.inputPanelAudioRecorder(panel, resource: _temporaryAudioRecordResource()) else {
//            return
//        }
//        SIMLog.trace()
//        
//        // 进入等待状态
//        _recorder = recorder
//        _recorder?.delegate = self
//        _state = .waiting
//        _lastPoint = nil
//        
//        // 直接开始. 如果失败了, 通过回调知之
//        recorder.record()
//    }
//    private dynamic func onTouchStop(_ sender: AnyObject) {
//        guard let panel = panel, let recorder = _recorder , _state.isRecording() else {
//            return
//        }
//        SIMLog.trace()
//        
//        let isCancel = _rightView.isHighlighted
//        // 关掉操作响应
//        _recordButton.isUserInteractionEnabled = false
//        // 检查用户选择
//        if !isCancel && delegate?.inputPanelShouldSendAudio(panel, resource: recorder.resource, duration: recorder.currentTime) ?? true {
//            _confirm = !_leftView.isHighlighted
//            _recorder?.stop()
//        } else {
//            _recorder?.cancel()
//        }
//    }
//    private dynamic func onTouchInterrupt(_ sender: AnyObject) {
//        guard _state.isRecording() else {
//            return
//        }
//        SIMLog.trace()
//        // 如果中断了, 认为他是选择了试听
//        _leftView.isHighlighted = true
//        _leftBackgroundView.isHighlighted = true
//        _leftBackgroundView.layer.transform = CATransform3DIdentity
//        _rightView.isHighlighted = false
//        _rightBackgroundView.isHighlighted = false
//        _rightBackgroundView.layer.transform = CATransform3DIdentity
//        // 走正常结束流程
//        onTouchStop(sender)
//    }
//    private dynamic func onTouchDrag(_ sender: UIButton, withEvent event: UIEvent?) {
//        // 必须要一直维持高亮
//        sender.isHighlighted = true
//        
//        guard let touch = event?.allTouches?.first , _state.isRecording() else {
//            return
//        }
//        //SIMLog.trace(touch.locationInView(self))
//        var hl = false
//        var hr = false
//        var sl = CGFloat(1.0)
//        var sr = CGFloat(1.0)
//        let pt = touch.location(in: _recordButton)
//        
//        // 检查阀值避免提交大量动画
//        if let lpt = _lastPoint , fabs(sqrt(lpt.x * lpt.x + lpt.y * lpt.y) - sqrt(pt.x * pt.x + pt.y * pt.y)) < 1 {
//            return
//        }
//        _lastPoint = pt
//        if pt.x < 0 {
//            // 左边
//            var pt2 = touch.location(in: _leftBackgroundView)
//            pt2.x -= _leftBackgroundView.bounds.width / 2
//            pt2.y -= _leftBackgroundView.bounds.height / 2
//            let r = max(sqrt(pt2.x * pt2.x + pt2.y * pt2.y), 0)
//            // 是否高亮
//            hl = r < _leftBackgroundView.bounds.width / 2
//            // 计算出左边的缩放
//            sl = 1.0 + max((80 - r) / 80, 0) * 0.75
//        } else if pt.x > _recordButton.bounds.width {
//            // 右边
//            var pt2 = touch.location(in: _rightBackgroundView)
//            pt2.x -= _rightBackgroundView.bounds.width / 2
//            pt2.y -= _rightBackgroundView.bounds.height / 2
//            let r = max(sqrt(pt2.x * pt2.x + pt2.y * pt2.y), 0)
//            // 是否高亮
//            hr = r < _rightBackgroundView.bounds.width / 2
//            // 计算出右边的缩放
//            sr = 1.0 + max((80 - r) / 80, 0) * 0.75
//        }
//        UIView.animate(withDuration: 0.25) {
//            self._leftView.isHighlighted = hl
//            self._leftBackgroundView.isHighlighted = hl
//            self._leftBackgroundView.layer.transform = CATransform3DMakeScale(sl, sl, 1)
//            self._rightView.isHighlighted = hr
//            self._rightBackgroundView.isHighlighted = hr
//            self._rightBackgroundView.layer.transform = CATransform3DMakeScale(sr, sr, 1)
//            self._state = .recording
//        }
//    }
//    
//    weak var panel: UIView?
//    weak var delegate: SIMChatInputPanelAudioViewDelegate?
//    weak var cellDelegate: SIMChatInputPanelAudioViewCellDelegate?
//    
//    var _lastPoint: CGPoint?
//    
//    var _state: SIMChatInputPanelAudioView.RecordState = .none {
//        didSet {
//            switch _state {
//            case .none:
//                _tipsLabel.text = "按住说话"
//                _spectrumView.isHidden = true
//                _activityView.stopAnimating()
//            case .waiting:
//                _tipsLabel.text = "准备中..."
//                _spectrumView.isHidden = true
//                _activityView.startAnimating()
//            case .progressing:
//                _tipsLabel.text = "处理中..."
//                _spectrumView.isHidden = true
//                _activityView.startAnimating()
//            case .recording:
//                if _activityView.isAnimating {
//                    _activityView.stopAnimating()
//                }
//                if _leftView.isHighlighted {
//                    _tipsLabel.text = "松开试听"
//                    _spectrumView.isHidden = true
//                } else if _rightView.isHighlighted {
//                    _tipsLabel.text = "松开取消"
//                    _spectrumView.isHidden = true
//                } else {
//                    let t = _recorder?.currentTime ?? 0
//                    _tipsLabel.text = String(format: "%0d:%02d", Int(t / 60), Int(t.truncatingRemainder(dividingBy: 60)))
//                    _spectrumView.isHidden = false
//                }
//            case .error(let error):
//                _spectrumView.isHidden = true
//                _tipsLabel.text = error.domain
//                _activityView.stopAnimating()
//            }
//            if _state.isRecording() {
//                if !_spectrumView.isAnimating() {
//                    _spectrumView.startAnimating()
//                }
//            } else {
//                if _spectrumView.isAnimating() {
//                    _spectrumView.stopAnimating()
//                }
//            }
//        }
//    }
//    
//    lazy var _tipsLabel: UILabel = {
//        let view = UILabel()
//        view.text = "按住说话"
//        view.font = UIFont.systemFont(ofSize: 16)
//        view.textColor = UIColor(argb: 0xFF7B7B7B)
//        return view
//    }()
//    lazy var _activityView: UIActivityIndicatorView = {
//        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        view.hidesWhenStopped = true
//        view.isHidden = true
//        return view
//    }()
//    lazy var _spectrumView: SIMChatSpectrumView = {
//        let view = SIMChatSpectrumView(frame: CGRect.zero)
//        view.color = UIColor(argb: 0xFFFB7A0D)
//        view.isHidden = true
//        view.delegate = self
//        return view
//    }()
//    
//    lazy var _leftView: UIImageView = {
//        let view = UIImageView()
//        view.image = UIImage(named: "simchat_keyboard_voice_operate_listen_nor")
//        view.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_listen_press")
//        return view
//    }()
//    lazy var _leftBackgroundView: UIImageView = {
//        let view = UIImageView()
//        view.image = UIImage(named: "simchat_keyboard_voice_operate_nor")
//        view.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_press")
//        return view
//    }()
//    lazy var _rightView: UIImageView = {
//        let view = UIImageView()
//        view.image = UIImage(named: "simchat_keyboard_voice_operate_delete_nor")
//        view.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_delete_press")
//        return view
//    }()
//    lazy var _rightBackgroundView: UIImageView = {
//        let view = UIImageView()
//        view.image = UIImage(named: "simchat_keyboard_voice_operate_nor")
//        view.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_press")
//        return view
//    }()
//    lazy var _operatorView: UIView = {
//        let view = UIView()
//        let line = UIImageView()
//        
//        line.image = UIImage(named: "simchat_keyboard_voice_line")
//        view.isHidden = true
//        
//        // add view
//        view.addSubview(line)
//        view.addSubview(self._rightBackgroundView)
//        view.addSubview(self._leftBackgroundView)
//        view.addSubview(self._rightView)
//        view.addSubview(self._leftView)
//        
//        SIMChatLayout.make(line)
//            .top.equ(view).top(14)
//            .left.equ(view).left(3.5)
//            .right.equ(view).right(3.5)
//            .bottom.equ(view).bottom
//            .submit()
//        SIMChatLayout.make(self._leftBackgroundView)
//            .top.equ(view).top
//            .left.equ(view).left
//            .submit()
//        SIMChatLayout.make(self._rightBackgroundView)
//            .top.equ(view).top
//            .right.equ(view).right
//            .submit()
//        SIMChatLayout.make(self._leftView)
//            .centerX.equ(self._leftBackgroundView).centerX
//            .centerY.equ(self._leftBackgroundView).centerY
//            .submit()
//        SIMChatLayout.make(self._rightView)
//            .centerX.equ(self._rightBackgroundView).centerX
//            .centerY.equ(self._rightBackgroundView).centerY
//            .submit()
//        
//        return view
//    }()
//    lazy var _recordButton: UIButton = {
//        let view = UIButton()
//        
//        view.setImage(UIImage(named: "simchat_keyboard_voice_icon_record"), for: UIControlState())
//        view.setImage(UIImage(named: "simchat_keyboard_voice_icon_record"), for: .highlighted)
//        view.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_button_nor"), for: UIControlState())
//        view.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_button_press"), for: .highlighted)
//        
//        // add events
//        view.addTarget(self, action: #selector(type(of: self).onTouchStart(_:)), for: .touchDown)
//        view.addTarget(self, action: #selector(type(of: self).onTouchDrag(_:withEvent:)), for: .touchDragInside)
//        view.addTarget(self, action: #selector(type(of: self).onTouchDrag(_:withEvent:)), for: .touchDragOutside)
//        view.addTarget(self, action: #selector(type(of: self).onTouchStop(_:)), for: .touchUpInside)
//        view.addTarget(self, action: #selector(type(of: self).onTouchStop(_:)), for: .touchUpOutside)
//        view.addTarget(self, action: #selector(type(of: self).onTouchInterrupt(_:)), for: .touchCancel)
//        
//        return view
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        build()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        build()
//    }
//}
//
/////
///// 子面板: 语音预览
/////
//internal class SIMChatInputPanelAudioViewPreview: UIView, SIMChatSpectrumViewDelegate, SIMChatMediaPlayerDelegate {
//    
//    
//    func chatSpectrumViewWaveOfLeft(_ chatSpectrumView: SIMChatSpectrumView) -> Float {
//        if _state.isPlaying() {
//            let t = _player?.currentTime ?? 0
//            _tipsLabel.text = String(format: "%0d:%02d", Int(t / 60), Int(t.truncatingRemainder(dividingBy: 60)))
//        }
//        return _player?.meter(0) ?? -60
//    }
//    func chatSpectrumViewWaveOfRight(_ chatSpectrumView: SIMChatSpectrumView) -> Float {
//        return _player?.meter(0) ?? -60
//    }
//    
//    @inline(__always) private func build() {
//        
//        _playButton.layer.addSublayer(_playProgress)
//        
//        addSubview(_playButton)
//        addSubview(_tipsLabel)
//        addSubview(_activityView)
//        addSubview(_spectrumView)
//        
//        SIMChatLayout.make(_playButton)
//            .centerX.equ(self).centerX
//            .centerY.equ(self).centerY(-12)
//            .submit()
//        SIMChatLayout.make(_tipsLabel)
//            .bottom.equ(_playButton).top(-20)
//            .centerX.equ(self).centerX
//            .submit()
//        SIMChatLayout.make(_spectrumView)
//            .centerX.equ(_tipsLabel).centerX
//            .centerY.equ(_tipsLabel).centerY
//            .submit()
//        SIMChatLayout.make(_activityView)
//            .right.equ(_tipsLabel).left(-4)
//            .centerY.equ(_tipsLabel).centerY
//            .submit()
//    }
//    
//    weak var panel: UIView?
//    weak var delegate: SIMChatInputPanelAudioViewDelegate?
//    
//    var resource: SIMChatResourceProtocol?
//    var duration: TimeInterval = 0
//    
//    var _state: SIMChatInputPanelAudioView.PlayState = .none {
//        didSet {
//            switch _state {
//            case .none:
//                _tipsLabel.text = "点击播放"
//                _spectrumView.isHidden = true
//                _activityView.stopAnimating()
//            case .waiting:
//                _tipsLabel.text = "准备中..."
//                _spectrumView.isHidden = true
//                _activityView.startAnimating()
//            case .playing:
//                if _activityView.isAnimating {
//                    _activityView.stopAnimating()
//                }
//                let t = _player?.currentTime ?? 0
//                _tipsLabel.text = String(format: "%0d:%02d", Int(t / 60), Int(t.truncatingRemainder(dividingBy: 60)))
//                _spectrumView.isHidden = false
//            case .error(let error):
//                _spectrumView.isHidden = true
//                _tipsLabel.text = error.domain
//                _activityView.stopAnimating()
//            }
//        }
//    }
//    /// 正在播放
//    var _timer: Timer?
//    var _startAt: CFTimeInterval = 0
//    var _duration: TimeInterval = 0
//    var _playing: Bool = false {
//        willSet {
//            // 如果没有任意改变, 那就不浪费资源了
//            if newValue == _playing {
//                return
//            }
//            if newValue {
//                // 正在播放
//                _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_nor"), for: UIControlState())
//                _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_press"), for: .highlighted)
//            } else {
//                // 停止了
//                _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_nor"), for: UIControlState())
//                _playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_press"), for: .highlighted)
//            }
//            // duang
//            let ani = CATransition()
//            
//            ani.duration = 0.25
//            ani.fillMode = kCAFillModeBackwards
//            ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//            ani.type = kCATransitionFade
//            ani.subtype = kCATransitionFromTop
//            
//            _playButton.layer.add(ani, forKey: "s")
//            
//            // 更新频谱动画
//            if newValue {
//                _spectrumView.startAnimating()
//            } else {
//                _spectrumView.stopAnimating()
//            }
//        }
//    }
//    
//    var _player: SIMChatMediaPlayerProtocol?
//    
//    dynamic func onTimer(_ sender: AnyObject) {
//        // 计算当前进度
//        let cur = CACurrentMediaTime() - _startAt
//        // 更新进度
//        _playProgress.strokeEnd = CGFloat(cur / max(_duration, 0.1))
//        // 完成了?
//        if cur > _duration + 0.1 {
//            // ok 完成
//            self.onStop()
//        }
//    }
//    
//    func playerShouldPrepare(_ player: SIMChatMediaPlayerProtocol) -> Bool {
//        return true
//    }
//    func playerDidPrepare(_ player: SIMChatMediaPlayerProtocol) {
//        SIMLog.trace()
//    }
//    
//    func playerShouldPlay(_ player: SIMChatMediaPlayerProtocol) -> Bool {
//        return true
//    }
//    func playerDidPlay(_ player: SIMChatMediaPlayerProtocol) {
//        SIMLog.trace()
//        
//        // 进入播放状态
//        self._state = .playing
//        self._playing = true
//        
//        // 进入计时
//        DispatchQueue.main.async {
//            self._duration = player.duration
//            self._startAt = CACurrentMediaTime()
//            self._timer = Timer.scheduledTimerWithTimeInterval2(0.1, self, #selector(type(of: self).onTimer(_:)))
//        }
//    }
//    func playerDidStop(_ player: SIMChatMediaPlayerProtocol) {
//        SIMLog.trace()
//        
//        // 停止
//        _timer?.invalidate()
//        _timer = nil
//        
//        _state = .none
//        _playing = false
//        _playProgress.strokeEnd = 0
//        _playProgress.removeAllAnimations()
//    }
//    func playerDidFinish(_ player: SIMChatMediaPlayerProtocol) {
//        SIMLog.trace()
//    }
//    func playerDidErrorOccur(_ player: SIMChatMediaPlayerProtocol, error: NSError) {
//        SIMLog.trace()
//        // 出错了.
//        _state = .error(error)
//    }
//    
//    dynamic func onPlayOrPause() {
//        if _playing {
//            // 正在播放, 那就停止
//            self.onStop()
//        } else {
//            // 没有播放, 开始播放
//            self.onPlay()
//        }
//    }
//    
//    /// 播放
//    @inline(__always) func onPlay() {
//        guard let panel = panel, let resource = resource else {
//            return
//        }
//        guard let player = delegate?.inputPanelAudioPlayer(panel, resource: resource) else {
//            return // 申请被拒绝
//        }
//        
//        SIMLog.trace()
//        
//        // 重置
//        _player = player
//        _player?.delegate = self
//        _playProgress.strokeEnd = 0
//        _playProgress.removeAllAnimations()
//        // 进行等待
//        _state = .waiting
//        
//        // 直接播放, 处理在代理处理
//        _player?.play()
//    }
//    /// 停止
//    @inline(__always) func onStop() {
//        SIMLog.trace()
//        _player?.stop()
//    }
//    
//    override func willMove(toWindow newWindow: UIWindow?) {
//        super.willMove(toWindow: newWindow)
//        if newWindow == nil && _timer != nil {
//            onStop()
//        }
//    }
//    
//    lazy var _tipsLabel: UILabel = {
//        let view = UILabel()
//        view.text = "点击播放"
//        view.font = UIFont.systemFont(ofSize: 16)
//        view.textColor = UIColor(argb: 0xFF7B7B7B)
//        return view
//    }()
//    lazy var _activityView: UIActivityIndicatorView = {
//        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        view.hidesWhenStopped = true
//        view.isHidden = true
//        return view
//    }()
//    
//    lazy var _spectrumView: SIMChatSpectrumView = {
//        let view = SIMChatSpectrumView(frame: CGRect.zero)
//        view.color = UIColor(argb: 0xFFFB7A0D)
//        view.isHidden = true
//        view.delegate = self
//        return view
//    }()
//    lazy var _playButton: UIButton = {
//        let view = UIButton()
//        
//        view.addTarget(self, action: #selector(type(of: self).onPlayOrPause), for: .touchUpInside)
//        view.setImage(UIImage(named: "simchat_keyboard_voice_button_play_nor"), for: UIControlState())
//        view.setImage(UIImage(named: "simchat_keyboard_voice_button_play_press"), for: .highlighted)
//        view.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_background"), for: UIControlState())
//        view.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_background"), for: .highlighted)
//        
//        view.sizeToFit()
//        
//        return view
//    }()
//    lazy var _playProgress: CAShapeLayer = {
//        let layer = CAShapeLayer()
//        layer.lineWidth = 3.5
//        layer.fillColor = nil
//        layer.strokeColor = UIColor(argb: 0xFF18B4ED).cgColor
//        layer.strokeStart = 0
//        layer.strokeEnd = 0
//        layer.frame = self._playButton.bounds
//        layer.path = UIBezierPath(ovalIn: self._playButton.bounds).cgPath
//        layer.transform = CATransform3DMakeRotation((-90 / 180) * CGFloat(M_PI), 0, 0, 1)
//        return layer
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        build()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        build()
//    }
//}
//
/////
///// 子面板: 语音预览代理
/////
//internal protocol SIMChatInputPanelAudioViewCellDelegate: class {
//    func inputPanelShowAudioPreview(_ inputPanel: UIView, resource: SIMChatResourceProtocol, duration: TimeInterval)
//}
//
//internal class SIMChatInputPanelAudioViewOfSimulate: UICollectionViewCell {
//}
//
//internal class SIMChatInputPanelAudioViewOfRecord: UICollectionViewCell {
//}
