//
//  SAIAudioInputView.swift
//  SAC
//
//  Created by SAGESSE on 9/12/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

// ## TODO
// [x] SAIAudioInputView - 横屏支持
// [x] SAIAudioInputView - 变声模式支持 - 99%, 算法没有实现(soundtouch?)
// [x] SAIAudioInputView - 对讲模式支持
// [x] SAIAudioInputView - 录音模式支持
// [x] SAIAudioInputView - 添加MaskView
// [ ] SAIAudioInputView - 检查录音时间
// [ ] SAIAudioInputView - Mini模式支持
// [x] SAIAudioInputView - 更换图标
// [x] SAIAudioInputView - Tabbar支持
// [x] SAIAudioInputView - 初始化时在中心
// [x] SAIAudioTalkbackView - 长按录音
// [x] SAIAudioTalkbackView - 回放
// [x] SAIAudioTalkbackView - 频谱显示
// [x] SAIAudioRecordView - 点击录音
// [x] SAIAudioRecordView - 回放
// [x] SAIAudioRecordView - 频谱显示
// [x] SAIAudioSimulateView - 长按录音
// [x] SAIAudioSimulateView - 回放
// [x] SAIAudioSimulateView - 频谱显示(录音)
// [x] SAIAudioSimulateView - 频谱显示(回放)
// [ ] SAIAudioSimulateView - 各种效果支持(6) - 50%, 主要是算法没有实现
// [x] SAIAudioSpectrumView - 显示波形
// [ ] SAIAudioSpectrumView - 优化(主要是算法)
// [x] SAIAudioTabbar - Index设置
// [x] SAIAudioTabbar - 点击事件
// [x] SAIAudioTabbar - 颜色
// [ ] 处理中的时候的停止

@objc
public enum SAIAudioType: Int, CustomStringConvertible {
    
    case simulate = 0   // 变声
    case talkback = 1   // 对讲
    case record = 2     // 录音
    
    public var description: String { 
        switch self {
        case .talkback: return "Talkback"
        case .simulate: return "Simulate"
        case .record:   return "Record"
        }
    }
}

@objc
public protocol SAIAudioInputViewDataSource: NSObjectProtocol {
    
    func numberOfAudioTypes(in audio: SAIAudioInputView) -> Int
    func audio(_ audio: SAIAudioInputView, audioTypeForItemAt index: Int) -> SAIAudioType
}

@objc 
public protocol SAIAudioInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
    
    @objc optional func audio(_ audio: SAIAudioInputView, shouldStartRecord url: URL) -> Bool
    @objc optional func audio(_ audio: SAIAudioInputView, didStartRecord url: URL)
    
    @objc optional func audio(_ audio: SAIAudioInputView, didRecordComplete url: URL, duration: TimeInterval)
    @objc optional func audio(_ audio: SAIAudioInputView, didRecordFailure url: URL, duration: TimeInterval)
}

open class SAIAudioInputView: UIView {
    
    open weak var dataSource: SAIAudioInputViewDataSource?
    open weak var delegate: SAIAudioInputViewDelegate?
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if _cacheBounds?.width != bounds.width {
            _cacheBounds = bounds
            
            if let idx = _contentViewLayout.lastIndexPath {
                _restoreContentOffset(at: idx)
                _tabbar.index = CGFloat(idx.item) + 0.5
            } else {
            let count = _contentView.numberOfItems(inSection: 0)
                let idx = max(((count + 1) / 2) - 1, 0)
                _contentView.contentOffset = CGPoint(x: _contentView.frame.width * CGFloat(idx), y: 0)
                _tabbar.index = CGFloat(idx) + 0.5
            }
        }
    }
    open override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
    
    private func _restoreContentOffset(at indexPath: IndexPath) {
        _logger.trace(indexPath)
        
        let count = _contentView.numberOfItems(inSection: indexPath.section)
        let item = min(indexPath.item, count - 1)
        
        let x = CGFloat(item) * _contentView.frame.width
        
        _contentView.contentOffset = CGPoint(x: x, y: 0)
    }
    
    private func _init() {
        _logger.trace()
        
        backgroundColor = UIColor(colorLiteralRed: 0xec / 0xff, green: 0xed / 0xff, blue: 0xf1 / 0xff, alpha: 1)
        
        _tabbar.delegate = self
        _tabbar.indicatorColor = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
        _tabbar.textHighlightedColor = _tabbar.indicatorColor
        _tabbar.translatesAutoresizingMaskIntoConstraints = false
        
        _maskView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        _maskView.translatesAutoresizingMaskIntoConstraints = false
        
        _contentView.backgroundColor = .clear
        _contentView.isPagingEnabled = true
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.allowsSelection = false
        _contentView.allowsMultipleSelection = false
        _contentView.alwaysBounceHorizontal = true
        //_contentView.delaysContentTouches = false
        
        _contentView.register(SAIAudioSimulateView.self, forCellWithReuseIdentifier: "\(SAIAudioType.simulate)")
        _contentView.register(SAIAudioTalkbackView.self, forCellWithReuseIdentifier: "\(SAIAudioType.talkback)")
        _contentView.register(SAIAudioRecordView.self, forCellWithReuseIdentifier: "\(SAIAudioType.record)")
        
        _contentView.delegate = self
        _contentView.dataSource = self
        
        // add subview 
        addSubview(_contentView)
        addSubview(_tabbar)
        
        // add constraints
       
        addConstraint(_SAILayoutConstraintMake(_contentView, .top, .equal, self, .top))
        addConstraint(_SAILayoutConstraintMake(_contentView, .left, .equal, self, .left))
        addConstraint(_SAILayoutConstraintMake(_contentView, .right, .equal, self, .right))
        addConstraint(_SAILayoutConstraintMake(_contentView, .bottom, .equal, self, .bottom))
        
        addConstraint(_SAILayoutConstraintMake(_tabbar, .left, .equal, self, .left))
        addConstraint(_SAILayoutConstraintMake(_tabbar, .right, .equal, self, .right))
        addConstraint(_SAILayoutConstraintMake(_tabbar, .bottom, .equal, self, .bottom, -16))
    }
    
    private var _cacheBounds: CGRect?
    
    fileprivate lazy var _tabbar: SAIAudioTabbar = SAIAudioTabbar()
    
    fileprivate lazy var _contentViewLayout: SAIAudioInputViewLayout = SAIAudioInputViewLayout()
    fileprivate lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
    
    fileprivate lazy var _maskView: UIView = UIView()
    fileprivate lazy var _maskViewLayout: [NSLayoutConstraint] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension SAIAudioInputView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = _contentView.indexPathsForVisibleItems.first {
            _tabbar.index = (scrollView.contentOffset.x / scrollView.bounds.width) + 0.5
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfAudioTypes(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = dataSource?.audio(self, audioTypeForItemAt: indexPath.item) else {
            fatalError()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(type)", for: indexPath)
        if let cell = cell as? SAIAudioView {
            cell.audioType = type
            cell.delegate = self
        }
        return cell
    }
}

// MARK: - SAIAudioViewDelegate(Forwarding)

extension SAIAudioInputView: SAIAudioViewDelegate {
    
    func audioView(_ audioView: SAIAudioView, shouldStartRecord url: URL) -> Bool {
        return delegate?.audio?(self, shouldStartRecord: url) ?? true
    }
    func audioView(_ audioView: SAIAudioView, didStartRecord url: URL) {
        addMaskView()
        delegate?.audio?(self, didStartRecord: url)
    }
    
    func audioView(_ audioView: SAIAudioView, didComplete url: URL, duration: TimeInterval) {
        removeMaskView()
        delegate?.audio?(self, didRecordComplete: url, duration: duration)
    }
    func audioView(_ audioView: SAIAudioView, didFailure url: URL, duration: TimeInterval) {
        removeMaskView()
        delegate?.audio?(self, didRecordFailure: url, duration: duration)
    }
    
    func addMaskView() {
        guard let window = window, _maskView.superview == nil else {
            return
        }
        _logger.trace()
        
        window.addSubview(_maskView)
        _maskViewLayout = [
            _SAILayoutConstraintMake(_maskView, .top, .equal, window, .top),
            _SAILayoutConstraintMake(_maskView, .left, .equal, window, .left),
            _SAILayoutConstraintMake(_maskView, .right, .equal, window, .right),
            _SAILayoutConstraintMake(_maskView, .bottom, .equal, self, .top),
        ]
        window.addConstraints(_maskViewLayout)
        
        self._maskView.alpha = 0
        self._tabbar.transform = .identity
        UIView.animate(withDuration: 0.25, animations: {
            self._maskView.alpha = 1
            self._tabbar.transform = CGAffineTransform(translationX: 0, y: self._tabbar.frame.height + 16)
        }, completion: { _ in
            self._tabbar.isHidden = true
        })
        _contentView.isScrollEnabled = false
        _contentView.panGestureRecognizer.isEnabled = false
    }
    func removeMaskView() {
        guard _maskView.superview != nil else {
            return
        }
        _logger.trace()
        
        UIView.animate(withDuration: 0.25, delay: 0.2, options: .curveEaseInOut, animations: {
            self._tabbar.transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, animations: {
            self._maskView.alpha = 0
        }, completion: { _ in
            self._maskView.superview?.removeConstraints(self._maskViewLayout)
            self._maskView.removeFromSuperview()
            self._maskViewLayout = []
        })
        
        _tabbar.isHidden = false
        _contentView.isScrollEnabled = true
        _contentView.panGestureRecognizer.isEnabled = true
    }
}

// MARK: - SAIAudioTabbarDelegate

extension SAIAudioInputView: SAIAudioTabbarDelegate {
    
    func numberOfItemsInTabbar(_ tabbar: SAIAudioTabbar) -> Int {
        return dataSource?.numberOfAudioTypes(in: self) ?? 0
    }
    func tabbar(_ tabbar: SAIAudioTabbar, titleAt index: Int) -> String {
        guard let type = dataSource?.audio(self, audioTypeForItemAt: index) else {
            fatalError()
        }
        switch type {
        case .record: return "录音"
        case .talkback: return "对讲"
        case .simulate: return "变声"
        }
    }
    
    func tabbar(_ tabbar: SAIAudioTabbar, shouldSelectItemAt index: Int) -> Bool {
        return true
    }
    func tabbar(_ tabbar: SAIAudioTabbar, didSelectItemAt index: Int) {
        _contentView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
}
