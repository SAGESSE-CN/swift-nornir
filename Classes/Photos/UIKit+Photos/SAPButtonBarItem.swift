//
//  SAPButtonBarItem.swift
//  SAC
//
//  Created by SAGESSE on 9/22/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

public enum SAPButtonBarItemType: Int {
    case normal
    case original
    case send
}

open class SAPButtonBarItem: UIBarButtonItem {
    
    open var type: SAPButtonBarItemType
    
    open var isSelected: Bool = false {
        willSet {
            guard newValue != isSelected else {
                return
            }
            _customViews.forEach {
                
                let imn = $0.image(for: [.normal])
                let imh = $0.image(for: [.highlighted])
                //let imd = $0.image(for: [.disabled])
                let imsn = $0.image(for: [.selected, .normal])
                let imsh = $0.image(for: [.selected, .highlighted])
                //let imsd = $0.image(for: [.selected, .disabled])
                
                $0.setImage(imsn, for: [.normal])
                $0.setImage(imsh, for: [.highlighted])
                //$0.setImage(imsd, for: [.disabled])
                $0.setImage(imn, for: [.selected, .normal])
                $0.setImage(imh, for: [.selected, .highlighted])
                //$0.setImage(imd, for: [.selected, .disabled])
                
                let imbn = $0.backgroundImage(for: [.normal])
                let imbh = $0.backgroundImage(for: [.highlighted])
                //let imbd = $0.backgroundImage(for: [.disabled])
                let imbsn = $0.backgroundImage(for: [.selected, .normal])
                let imbsh = $0.backgroundImage(for: [.selected, .highlighted])
                //let imbsd = $0.backgroundImage(for: [.selected, .disabled])
                
                $0.setBackgroundImage(imbsn, for: [.normal])
                $0.setBackgroundImage(imbsh, for: [.highlighted])
                //$0.setBackgroundImage(imbsd, for: [.disabled])
                $0.setBackgroundImage(imbn, for: [.selected, .normal])
                $0.setBackgroundImage(imbh, for: [.selected, .highlighted])
                //$0.setBackgroundImage(imbd, for: [.selected, .disabled])
            }                                     
        }
    }

    open override var title: String? {
        willSet {
            _customViews.forEach {
                $0.titleLabel?.text = newValue
                $0.setTitle(newValue, for: .normal)
                $0.sizeToFit()
                
                if type == .send {
                    var nframe = $0.frame
                    nframe.size.width = max(nframe.width, 70)
                    $0.frame = nframe
                }
            }
        }
    }
    
    open override var isEnabled: Bool {
        willSet {
            _customViews.forEach {
                $0.isEnabled = newValue
            }
        }
    }
    
    public init(title: String?, type: SAPButtonBarItemType = .normal, target: AnyObject? = nil, action: Selector? = nil) {
        self.type = type
        super.init()
        self.title = title
        self.target = target
        self.action = action
    }
    public required init?(coder aDecoder: NSCoder) {
        self.type = .normal
        super.init(coder: aDecoder)
    }
    
    func toBarItem() -> UIBarButtonItem {
        // 找一个没有使用的
        if let index = _items.index(where: { $0.customView?.superview == nil }) {
            return _items[index]
        }
        // 如果没有找到, 生成一个
        let item: UIBarButtonItem = {
            switch type {
            case .normal:
                let view = _makeNormalButton(title)
                return UIBarButtonItem(customView: view)
                
            case .original:
                let view = _makeNormalButton(title)
                view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
                if !isSelected {
                    
                    view.setImage(UIImage.sap_init(named: "photo_small_checkbox_normal"), for: .normal)
                    view.setImage(UIImage.sap_init(named: "photo_small_checkbox_selected"), for: .selected)
                } else {
                    view.setImage(UIImage.sap_init(named: "photo_small_checkbox_normal"), for: .selected)
                    view.setImage(UIImage.sap_init(named: "photo_small_checkbox_selected"), for: .normal)
                }
                view.sizeToFit()
                return UIBarButtonItem(customView: view)
                
            case .send:
                let view = _makeSendButton(title)
                return UIBarButtonItem(customView: view)
            }
        }()
        guard let button = item.customView as? UIButton else {
            return item
        }
        
        button.isEnabled = isEnabled
        
        if let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        _items.append(item)
        _customViews.append(button)
        return item
    }
    
    private func _makeNormalButton(_ title: String?) -> UIButton {
        let button = UIButton(type: .system)
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.sizeToFit()
        
        return button
    }
    private func _makeSendButton(_ title: String?) -> UIButton {
        let button = UIButton(type: .custom)
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        button.setBackgroundImage(UIImage.sap_init(named: "photo_button_confirm_nor"), for: .normal)
        button.setBackgroundImage(UIImage.sap_init(named: "photo_button_confirm_press"), for: .highlighted)
        button.setBackgroundImage(UIImage.sap_init(named: "photo_button_confirm_disabled"), for: .disabled)
        button.sizeToFit()
        button.frame = CGRect(x: 0, y: 0, width: max(70, button.frame.width), height: button.frame.height)
        
        return button
    }
    
    
    private lazy var _items: [UIBarButtonItem] = []
    private lazy var _customViews: [UIButton] = []
}

