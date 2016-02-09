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
    
    public func insertAttributedText(attributedText: NSAttributedString) {
        let currnetTextRange = selectedTextRange ?? UITextRange()
        let newTextLength = attributedText.length
        
        // read postion
        let location = offsetFromPosition(beginningOfDocument, toPosition: currnetTextRange.start)
        let length = offsetFromPosition(currnetTextRange.start, toPosition: currnetTextRange.end)
        let newRange = NSMakeRange(location, newTextLength)
        
        // update text
        let att = typingAttributes
        textStorage.replaceCharactersInRange(NSMakeRange(location, length), withAttributedString: attributedText)
        textStorage.addAttributes(att, range: newRange)
        
        // update new text range
        let newPosition = positionFromPosition(beginningOfDocument, offset: location + newTextLength) ?? UITextPosition()
        selectedTextRange = textRangeFromPosition(newPosition, toPosition: newPosition)
    }
    
    public func clearText() {
        text = nil
    }
}