//
//  SAIPhotoInputView.swift
//  SAC
//
//  Created by SAGESSE on 9/12/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import SAPhotos


// # TODO
// [x] SAIPhotoInputView - 横屏支持
// [x] SAIPhotoInputView - 预览选中的图片
// [ ] * - 发送图片(读取)


@objc public protocol SAIPhotoInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
}

public class SAIPhotoInputView: UIView {
    
    public var allowsMultipleSelection: Bool = true {
        didSet {
            //_picker?.allowsMultipleSelection = allowsMultipleSelection
            //_contentView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    
    public weak var delegate: SAIPhotoInputViewDelegate?
        
        
    public override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
    
    func toolbarItems(for context: SAPToolbarContext) -> [UIBarButtonItem]? {
        switch context {
        case .panel:    return [_pickBarItem, _editBarItem, _originalBarItem, _spaceBarItem, _sendBarItem]
        default:        return nil
        }
    }
    
    private func _init() {
        _logger.trace()

        let color = UIColor(red: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
        tintColor = color
        
        _pickBarItem = SAPButtonBarItem(title: "相册", type: .normal, target: self, action: #selector(pickerHandler(_:)))
        _editBarItem = SAPButtonBarItem(title: "编辑", type: .normal, target: self, action: #selector(onEditor(_:)))
        _sendBarItem = SAPButtonBarItem(title: "发送", type: .send, target: self, action: #selector(onSendForPicker(_:)))
        _originalBarItem = SAPButtonBarItem(title: "原图", type: .original, target: self, action: #selector(onChangeOriginal(_:)))
        
        _tabbar.translatesAutoresizingMaskIntoConstraints = false
        _tabbar.items = toolbarItems(for: .panel)
        
        _contentView.delegate = self
        _contentView.allowsMultipleSelection = allowsMultipleSelection
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(_contentView)
        addSubview(_tabbar)
        
        addConstraint(_SAILayoutConstraintMake(_contentView, .top, .equal, self, .top))
        addConstraint(_SAILayoutConstraintMake(_contentView, .left, .equal, self, .left))
        addConstraint(_SAILayoutConstraintMake(_contentView, .right, .equal, self, .right))
        
        addConstraint(_SAILayoutConstraintMake(_tabbar, .top, .equal, _contentView, .bottom))
        addConstraint(_SAILayoutConstraintMake(_tabbar, .left, .equal, self, .left))
        addConstraint(_SAILayoutConstraintMake(_tabbar, .right, .equal, self, .right))
        addConstraint(_SAILayoutConstraintMake(_tabbar, .bottom, .equal, self, .bottom))
        
        addConstraint(_SAILayoutConstraintMake(_tabbar, .height, .equal, nil, .notAnAttribute, 44))
        
        _updatePhotoCount(0)
    }
    
    fileprivate var _isOriginalImage: Bool = false
    
    fileprivate lazy var _selectedPhotos: Array<SAPAsset> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPAsset> = []
    
    fileprivate var _pickBarItem: SAPButtonBarItem!
    fileprivate var _editBarItem: SAPButtonBarItem!
    fileprivate var _originalBarItem: SAPButtonBarItem!
    fileprivate var _sendBarItem: SAPButtonBarItem!
    fileprivate var _spaceBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    fileprivate lazy var _tabbar: SAPToolbar = SAPToolbar()
    fileprivate lazy var _contentView: SAPPickerView = SAPPickerView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

// MARK: - Touch Events

extension SAIPhotoInputView {
    
    @objc func onSendForPicker(_ sender: Any) {
        _logger.trace()
        
        //_picker?.dismiss(animated: true, completion: nil)
        
        //_contentView.updateSelectionOfItems()
    }
    @objc func onChangeOriginal(_ sender: UIButton) {
        _logger.trace()
        
        _contentView.alwaysSelectOriginal = !_contentView.alwaysSelectOriginal
        _originalBarItem.isSelected = _contentView.alwaysSelectOriginal
    }
    
    @objc func pickerHandler(_ sender: Any) {
        _logger.trace()
        
        _showPicker()
    }
    
    @objc func onEditor(_ sender: Any) {
        _logger.trace(sender)
    }
    
    func confrim(photos: Array<SAPAsset>) {
        _logger.trace()
        
//        // 清除所有选中
//        _contentView.selectedPhotos = []
//        _updatePhotoCount()
    }
    func cancel(photo: Array<SAPAsset>) {
        _logger.trace()
        
//        // 清除所有选中
//        _contentView.selectedPhotos = []
//        _updatePhotoCount()
    }
    
}

fileprivate extension SAIPhotoInputView {
    
    func _updatePhotoCount(_ count: Int) {
        
        if count != 0 {
            _sendBarItem.title = "发送(\(count))"
        } else {
            _sendBarItem.title = "发送"
        }
        
        _editBarItem.isEnabled = count == 1
        _sendBarItem.isEnabled = count != 0
        _originalBarItem.isEnabled = count != 0
    }
    func _updateBytesLenght(_ lenght: Int) {
        _logger.trace(lenght)
        
        if !_contentView.alwaysSelectOriginal || lenght <= 0 {
            _originalBarItem.title = "原图"
        } else {
            _originalBarItem.title = "原图(\(SAPStringForBytesLenght(lenght)))"
        }
    }
    
    /// 显示图片选择器
    func _showPicker() {
        guard let window = UIApplication.shared.delegate?.window else {
            return // no window, is unknow error
        }
        let picker = SAPPicker()
        
        picker.delegate = self
        picker.selectedPhotos = _contentView.selectedPhotos
        
        picker.allowsEditing = _contentView.allowsEditing
        picker.allowsMultipleSelection = _contentView.allowsMultipleSelection
        picker.alwaysSelectOriginal = _contentView.alwaysSelectOriginal
        
        window?.rootViewController?.present(picker, animated: true, completion: nil)
    }
    /// 显示图片选择器(预览模式)
    func _showPickerForPreview(_ photo: SAPAsset) {
        guard let window = UIApplication.shared.delegate?.window else {
            return // no window, is unknow error
        }
        let options = SAPPickerOptions(album: photo.album, default: photo, ascending: false)
        let picker = SAPPicker(preview: options)
            
        picker.delegate = self
        picker.selectedPhotos = _contentView.selectedPhotos
        
        picker.allowsEditing = _contentView.allowsEditing
        picker.allowsMultipleSelection = _contentView.allowsMultipleSelection
        picker.alwaysSelectOriginal = _contentView.alwaysSelectOriginal
        
        window?.rootViewController?.present(picker, animated: true, completion: nil)
    }
}

// MARK: - SAPPickerViewDelegate

extension SAIPhotoInputView: SAPPickerViewDelegate {

    // check whether item can select
    public func pickerView(_ pickerView: SAPPickerView, shouldSelectItemFor photo: SAPAsset) -> Bool {
        // 可以在这里进行数量限制/图片类型限制
        //
        // if _selectedPhotoSets.count >= 9 {
        //     return false // 只能选择9张图片
        // }
        // if photo.mediaType != .image {
        //     return false // 只能选择图片
        // }
        return true
    }
    public func pickerView(_ pickerView: SAPPickerView, didSelectItemFor photo: SAPAsset) {
        _logger.trace()
        
        _updatePhotoCount(pickerView.selectedPhotos.count)
    }
    
    // check whether item can deselect
    public func pickerView(_ pickerView: SAPPickerView, shouldDeselectItemFor photo: SAPAsset) -> Bool {
        return true
    }
    public func pickerView(_ pickerView: SAPPickerView, didDeselectItemFor photo: SAPAsset) {
        _logger.trace()
        
        _updatePhotoCount(pickerView.selectedPhotos.count)
    }
    
    // data bytes lenght change
    public func pickerView(_ pickerView: SAPPickerView, didChangeBytes bytes: Int) {
        _updateBytesLenght(bytes)
    }
    
    public func pickerView(_ pickerView: SAPPickerView, tapItemFor photo: SAPAsset, with sender: Any) {
        _logger.trace()
        
        _showPickerForPreview(photo)
    }
}


// MARK: - SAPPickerDelegate

extension SAIPhotoInputView: SAPPickerDelegate {
    
    // check whether item can select
    public func picker(_ picker: SAPPicker, shouldSelectItemFor photo: SAPAsset) -> Bool {
        // 可以在这里进行数量限制/图片类型限制
        //
        // if _selectedPhotoSets.count >= 9 {
        //     return false // 只能选择9张图片
        // }
        // if photo.mediaType != .image {
        //     return false // 只能选择图片
        // }
        return true
    }
    public func picker(_ picker: SAPPicker, didSelectItemFor photo: SAPAsset) {
        _logger.trace()
        
        _contentView.scroll(to: photo, animated: true)
    }
    
    // check whether item can deselect
    public func picker(_ picker: SAPPicker, shouldDeselectItemFor photo: SAPAsset) -> Bool {
        return true
    }
    public func picker(_ picker: SAPPicker, didDeselectItemFor photo: SAPAsset) {
        _logger.trace()
        
    }
    
    // data bytes lenght change
    public func picker(_ picker: SAPPicker, didChangeBytes bytes: Int) {
        _updateBytesLenght(bytes)
    }
    
    public func picker(_ picker: SAPPicker, canConfrim photos: Array<SAPAsset>) -> Bool {
        _updatePhotoCount(photos.count)
        return _sendBarItem.isEnabled
    }
    
    public func picker(_ picker: SAPPicker, willDismiss animated: Bool) {
        _logger.trace()
        
        // 同步
        _contentView.selectedPhotos = picker.selectedPhotos
        _contentView.alwaysSelectOriginal = picker.alwaysSelectOriginal
        
        _originalBarItem.isSelected = picker.alwaysSelectOriginal
    }
    
    // end
    public func picker(_ picker: SAPPicker, confrim photos: Array<SAPAsset>) {
        _logger.trace()
        
    }
    public func picker(_ picker: SAPPicker, cancel photos: Array<SAPAsset>) {
        _logger.trace()
        
    }
}
