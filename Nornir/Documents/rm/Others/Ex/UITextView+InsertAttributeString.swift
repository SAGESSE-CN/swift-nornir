//
//  UITextView+InsertAttributeString.swift
//  SIMChat
//
//  Created by sagesse on 2/7/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

extension UITextView {
    
    // system provide
    
    // public func hasText() -> Bool
    // public func insertText(text: String)
    // public func deleteBackward()
    
    // custom
    
//    public func insertAttributedText(_ attributedText: NSAttributedString) {
//        let currnetTextRange = selectedTextRange ?? UITextRange()
//        let newTextLength = attributedText.length
//        
//        // read postion
//        let location = offset(from: beginningOfDocument, to: currnetTextRange.start)
//        let length = offset(from: currnetTextRange.start, to: currnetTextRange.end)
//        let newRange = NSMakeRange(location, newTextLength)
//        
//        // update text
//        let att = typingAttributes
//        textStorage.replaceCharacters(in: NSMakeRange(location, length), with: attributedText)
//        textStorage.addAttributes(att, range: newRange)
//        
//        // update new text range
//        let newPosition = position(from: beginningOfDocument, offset: location + newTextLength) ?? UITextPosition()
//        selectedTextRange = textRange(from: newPosition, to: newPosition)
//    }
//    
//    public func clearText() {
//        text = nil
//    }
}
