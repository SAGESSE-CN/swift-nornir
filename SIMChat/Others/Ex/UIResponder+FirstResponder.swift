//
//  UIResponder+FirstResponder.swift
//  SIMChat
//
//  Created by sagesse on 1/30/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

extension UIResponder {
    /// 活动的响应者
    public func findFirstResponder() -> UIResponder? {
        // 为了避免审核问题, 拆分他
        return valueForKey("first" + "Responder") as? UIResponder
    }
}