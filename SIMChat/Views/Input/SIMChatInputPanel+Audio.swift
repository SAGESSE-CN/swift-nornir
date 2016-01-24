//
//  SIMChatInputPanel+Audio.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

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
        
        private func build() {
            backgroundColor = UIColor(hex: 0xEBECEE)
        }
    }
}