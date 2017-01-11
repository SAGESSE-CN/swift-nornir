//
//  SIMChatLabel.swift
//  SIMChat <https://github.com/sagesse-cn/swift-chat>
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by sagesse on 4/5/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import SIMChat

import UIKit
import CoreText
import CoreFoundation

public let SIMChatTextAttachmentAttributeName = "SIMChatTextAttachment"

public let SIMChatTextAttachmentToken = "\u{fffc}"
public let SIMChatTextTruncationToken = "\u{2026}"

private func _SIMChatTextDebug(_ path: CGPath?, _ size: CGSize) {
    let context = UIGraphicsGetCurrentContext()
    
    context?.saveGState()
    
//    CGContextTranslateCTM(context, 0, size.height)
    context?.scale(x: 1.0, y: -1.0)
    
    // set attrib
    UIColor.red().setStroke()
    context?.setLineWidth(2)
    // draw
    context?.addPath(path!)
    context?.strokePath()
    
    context?.restoreGState()
    
}

private func _SIMChatTextDraw(_ frame: CTFrame, _ size: CGSize) {
    let context = UIGraphicsGetCurrentContext()
    
    context?.saveGState()
    
    UIColor.purple().setStroke()
    
//    CGContextTranslateCTM(context, 0, size.height)
    context?.scale(x: 1.0, y: -1.0)
    
    CTFrameDraw(frame, context!)
    
    context?.restoreGState()
}
//private func _SIMChatTextDraw(line: CTLine, _ size: CGSize) {
//    let context = UIGraphicsGetCurrentContext()
//    
//    CGContextSaveGState(context)
//    
//    UIColor.purpleColor().setStroke()
//    
////    CGContextTranslateCTM(context, 0, size.height)
//    CGContextScaleCTM(context, 1.0, -1.0)
//    
//    CTLineDraw(line, context!)
//    
//    CGContextRestoreGState(context)
//}

private func _SIMChatTextDebug(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    
    context?.saveGState()
    
//    CGContextTranslateCTM(context, 0, size.height)
//    CGContextScaleCTM(context, 1.0, -1.0)
    
    // set attrib
    UIColor.red().setStroke()
    context?.setLineWidth(1)
    // draw
    context?.addRect(rect)
//    CGContextAddPath(context, path)
    context?.strokePath()
    
    context?.restoreGState()
    
}

private func _SIMChatTextAttachmentRelease(_ ref: UnsafeMutablePointer<Void>) {
//    let _: AnyObject = Unmanaged.fromOpaque(OpaquePointer(ref)).takeRetainedValue()
}
private func _SIMChatTextAttachmentRetain(_ obj: AnyObject) -> UnsafeMutablePointer<Void> {
//    return UnsafeMutablePointer<Void>(Unmanaged.passRetained(obj).toOpaque())
    let x: UnsafeMutablePointer<Void>? = nil
    return x!
}

private func _SIMChatTextAttachmentGetWidth(_ ref: UnsafeMutablePointer<Void>) -> CGFloat {
//    return Unmanaged<SIMChatTextAttachment>.fromOpaque(OpaquePointer(ref)).takeUnretainedValue().width
    return 0
}
private func _SIMChatTextAttachmentGetAscent(_ ref: UnsafeMutablePointer<Void>) -> CGFloat {
//    return Unmanaged<SIMChatTextAttachment>.fromOpaque(OpaquePointer(ref)).takeUnretainedValue().ascent
    return 0
}
private func _SIMChatTextAttachmentGetDescent(_ ref: UnsafeMutablePointer<Void>) -> CGFloat {
//    return Unmanaged<SIMChatTextAttachment>.fromOpaque(OpaquePointer(ref)).takeUnretainedValue().descent
    return 0
}

private func _SIMChatTextDraw(_ line: SIMChatTextLine, context: CGContext?, size: CGSize) {
    (CTLineGetGlyphRuns(line.line) as NSArray).forEach {
        let run = $0 as! CTRun
        let attrs = CTRunGetAttributes(run) as NSDictionary
        let textMatrix = CTRunGetTextMatrix(run)
        let textMatrixIsId = textMatrix.isIdentity
        
        if !textMatrixIsId {
            context?.saveGState()
            context?.textMatrix = (context?.textMatrix.concat(textMatrix))!
        }
        
        CTRunDraw(run, context!, CFRangeMake(0, 0))
        
        if !textMatrixIsId {
            context?.restoreGState()
        }
    }
}

//static void YYTextDrawRun(YYTextLine *line, CTRunRef run, CGContextRef context, CGSize size, BOOL isVertical, NSArray *runRanges, CGFloat verticalOffset) {
//    CGAffineTransform runTextMatrix = CTRunGetTextMatrix(run);
//    BOOL runTextMatrixIsID = CGAffineTransformIsIdentity(runTextMatrix);
//    
//    CFDictionaryRef runAttrs = CTRunGetAttributes(run);
//    NSValue *glyphTransformValue = CFDictionaryGetValue(runAttrs, (__bridge const void *)(YYTextGlyphTransformAttributeName));
//    if (!isVertical && !glyphTransformValue) { // draw run
//        if (!runTextMatrixIsID) {
//            CGContextSaveGState(context);
//            CGAffineTransform trans = CGContextGetTextMatrix(context);
//            CGContextSetTextMatrix(context, CGAffineTransformConcat(trans, runTextMatrix));
//        }
//        CTRunDraw(run, context, CFRangeMake(0, 0));
//        if (!runTextMatrixIsID) {
//            CGContextRestoreGState(context);
//        }
//    } else { // draw glyph
//        CTFontRef runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
//        if (!runFont) return;
//        NSUInteger glyphCount = CTRunGetGlyphCount(run);
//        if (glyphCount <= 0) return;
//        
//        CGGlyph glyphs[glyphCount];
//        CGPoint glyphPositions[glyphCount];
//        CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
//        CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
//        
//        CGColorRef fillColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTForegroundColorAttributeName);
//        if (!fillColor) fillColor = [UIColor blackColor].CGColor;
//        NSNumber *strokeWidth = CFDictionaryGetValue(runAttrs, kCTStrokeWidthAttributeName);
//        
//        CGContextSaveGState(context); {
//            CGContextSetFillColorWithColor(context, fillColor);
//            if (!strokeWidth || strokeWidth.floatValue == 0) {
//                CGContextSetTextDrawingMode(context, kCGTextFill);
//            } else {
//                CGColorRef strokeColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTStrokeColorAttributeName);
//                if (!strokeColor) strokeColor = fillColor;
//                CGContextSetStrokeColorWithColor(context, strokeColor);
//                CGContextSetLineWidth(context, CTFontGetSize(runFont) * fabs(strokeWidth.floatValue * 0.01));
//                if (strokeWidth.floatValue > 0) {
//                    CGContextSetTextDrawingMode(context, kCGTextStroke);
//                } else {
//                    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
//                }
//            }
//            
//            if (isVertical) {
//                CFIndex runStrIdx[glyphCount + 1];
//                CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
//                CFRange runStrRange = CTRunGetStringRange(run);
//                runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
//                CGSize glyphAdvances[glyphCount];
//                CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
//                CGFloat ascent = CTFontGetAscent(runFont);
//                CGFloat descent = CTFontGetDescent(runFont);
//                CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
//                CGPoint zeroPoint = CGPointZero;
//                
//                for (YYTextRunGlyphRange *oneRange in runRanges) {
//                    NSRange range = oneRange.glyphRangeInRun;
//                    NSUInteger rangeMax = range.location + range.length;
//                    YYTextRunGlyphDrawMode mode = oneRange.drawMode;
//                    
//                    for (NSUInteger g = range.location; g < rangeMax; g++) {
//                        CGContextSaveGState(context); {
//                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//                            if (glyphTransformValue) {
//                                CGContextSetTextMatrix(context, glyphTransform);
//                            }
//                            if (mode) { // CJK glyph, need rotated
//                                CGFloat ofs = (ascent - descent) * 0.5;
//                                CGFloat w = glyphAdvances[g].width * 0.5;
//                                CGFloat x = x = line.position.x + verticalOffset + glyphPositions[g].y + (ofs - w);
//                                CGFloat y = -line.position.y + size.height - glyphPositions[g].x - (ofs + w);
//                                if (mode == YYTextRunGlyphDrawModeVerticalRotateMove) {
//                                    x += w;
//                                    y += w;
//                                }
//                                CGContextSetTextPosition(context, x, y);
//                            } else {
//                                CGContextRotateCTM(context, DegreesToRadians(-90));
//                                CGContextSetTextPosition(context,
//                                                         line.position.y - size.height + glyphPositions[g].x,
//                                                         line.position.x + verticalOffset + glyphPositions[g].y);
//                            }
//                            
//                            if (CTFontContainsColorBitmapGlyphs(runFont)) {
//                                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
//                            } else {
//                                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                                CGContextSetFont(context, cgFont);
//                                CGContextSetFontSize(context, CTFontGetSize(runFont));
//                                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
//                                CGFontRelease(cgFont);
//                            }
//                        } CGContextRestoreGState(context);
//                    }
//                }
//            } else { // not vertical
//                if (glyphTransformValue) {
//                    CFIndex runStrIdx[glyphCount + 1];
//                    CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
//                    CFRange runStrRange = CTRunGetStringRange(run);
//                    runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
//                    CGSize glyphAdvances[glyphCount];
//                    CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
//                    CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
//                    CGPoint zeroPoint = CGPointZero;
//                    
//                    for (NSUInteger g = 0; g < glyphCount; g++) {
//                        CGContextSaveGState(context); {
//                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//                            CGContextSetTextMatrix(context, glyphTransform);
//                            CGContextSetTextPosition(context,
//                                                     line.position.x + glyphPositions[g].x,
//                                                     size.height - (line.position.y + glyphPositions[g].y));
//                            
//                            if (CTFontContainsColorBitmapGlyphs(runFont)) {
//                                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
//                            } else {
//                                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                                CGContextSetFont(context, cgFont);
//                                CGContextSetFontSize(context, CTFontGetSize(runFont));
//                                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
//                                CGFontRelease(cgFont);
//                            }
//                        } CGContextRestoreGState(context);
//                    }
//                } else {
//                    if (CTFontContainsColorBitmapGlyphs(runFont)) {
//                        CTFontDrawGlyphs(runFont, glyphs, glyphPositions, glyphCount, context);
//                    } else {
//                        CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                        CGContextSetFont(context, cgFont);
//                        CGContextSetFontSize(context, CTFontGetSize(runFont));
//                        CGContextShowGlyphsAtPositions(context, glyphs, glyphPositions, glyphCount);
//                        CGFontRelease(cgFont);
//                    }
//                }
//            }
//            
//        } CGContextRestoreGState(context);
//    }
//}

private func _SIMChatTextDraw(_ layout: SIMChatTextLayout, context: CGContext?, rect: CGRect) {
}
//static void YYTextDrawText(YYTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
//    CGContextSaveGState(context); {
//        
//        CGContextTranslateCTM(context, point.x, point.y);
//        CGContextTranslateCTM(context, 0, size.height);
//        CGContextScaleCTM(context, 1, -1);
//        CGContextSetShadow(context, CGSizeZero, 0);
//        
//        BOOL isVertical = layout.container.verticalForm;
//        CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
//        
//        NSArray *lines = layout.lines;
//        for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
//            YYTextLine *line = lines[l];
//            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
//            NSArray *lineRunRanges = line.verticalRotateRange;
//            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//            CGContextSetTextPosition(context, line.position.x + verticalOffset, size.height - line.position.y);
//            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
//            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
//                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
//                YYTextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
//            }
//            if (cancel && cancel()) break;
//        }
//        
//        // Use this to draw frame for test/debug.
//        // CGContextTranslateCTM(context, verticalOffset, size.height);
//        // CTFrameDraw(layout.frame, context);
//        
//    } CGContextRestoreGState(context);
//}


///
/// The SIMChatTextContainer class defines a region in which text is laid out.
/// SIMChatTextLayout class uses one or more SIMChatTextContainer objects to generate layouts.
/// 
/// A SIMChatTextContainer defines rectangular regions (`size` and `insets`) or
/// nonrectangular shapes (`path`), and you can define exclusion paths inside the
/// text container's bounding rectangle so that text flows around the exclusion
/// path as it is laid out.
/// 
/// Example:
/// 
///     ┌─────────────────────────────┐  <------- container
///     │                             │
///     │    asdfasdfasdfasdfasdfa   <------------ container insets
///     │    asdfasdfa   asdfasdfa    │
///     │    asdfas         asdasd    │
///     │    asdfa        <----------------------- container exclusion path
///     │    asdfas         adfasd    │
///     │    asdfasdfa   asdfasdfa    │
///     │    asdfasdfasdfasdfasdfa    │
///     │                             │
///     └─────────────────────────────┘
///
public class SIMChatTextContainer {
    
    ///
    /// Creates a container with the specified path.
    ///
    /// - parameter path: The path.
    ///
    public init(path: UIBezierPath) {
        self.path = path
    }
    
    ///
    /// Creates a container with the specified size.
    ///
    /// - parameter size: The size.
    /// - parameter insets: The insets.
    ///
    public init(size: CGSize, insets: UIEdgeInsets = UIEdgeInsetsZero) {
        self.size = size
        self.insets = insets
    }
    
    /// The constrained size. (if the size is larger than CGRectMake(CGFloat.max, CGFloat.max), it will be clipped)
    public lazy var size: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    
    /// The insets for constrained size. The inset value should not be negative. Default is UIEdgeInsetsZero.
    public lazy var insets: UIEdgeInsets = UIEdgeInsetsZero
    
    /// Default value: NSLineBreakByWordWrapping  The line break mode defines the behavior of the last line inside the text container.
    public lazy var lineBreakMode: NSLineBreakMode = .byWordWrapping
    
    /// Maximum number of rows, 0 means no limit. Default is 0.
    public lazy var maximumNumberOfLines: Int = 0
    
    /// An array of `UIBezierPath` for path exclusion. Default is nil.
    public lazy var exclusionPaths: [UIBezierPath] = []
    
    /// Custom constrained path. Set this property to ignore `size` and `insets`. Default is nil.
    @NSCopying public var path: UIBezierPath?
    
    /// The truncation token. If nil, the layout will use "…" instead. Default is nil.
    @NSCopying public var truncationToken: AttributedString?
}

///
/// SIMChatTextLayout class is a readonly class stores text layout result.
/// All the property in this class is readonly, and should not be changed.
/// The methods in this class is thread-safe (except some of the draw methods).
/// 
/// example: (layout with a circle exclusion path)
/// 
///     ┌──────────────────────────┐  <------ container
///     │ [--------Line0--------]  │  <- Row0
///     │ [--------Line1--------]  │  <- Row1
///     │ [-Line2-]     [-Line3-]  │  <- Row2
///     │ [-Line4]       [Line5-]  │  <- Row3
///     │ [-Line6-]     [-Line7-]  │  <- Row4
///     │ [--------Line8--------]  │  <- Row5
///     │ [--------Line9--------]  │  <- Row6
///     └──────────────────────────┘
///
public class SIMChatTextLayout {
    
    public let text: AttributedString
    public let range: NSRange
    public let container: SIMChatTextContainer
    
    public let frameSetter: CTFramesetter
    public let frame: CTFrame
    
    public let lines: Array<SIMChatTextLine>
    public let attachments: Array<(SIMChatTextAttachment, NSRange, CGRect)>
    //public let attachmentContents: Set<SIMChatTextAttachment>
    
    public let rowCount: Int
    public let visibleRange: NSRange
    public let textBoundingRect: CGRect
    public let textBoundingSize: CGSize
    
    public let truncatedLine: SIMChatTextLine?
    
    private(set) public var containsHighlight: Bool = false
    
    // MARK: draw options
    
    private(set) public var needDrawText: Bool = false
    private(set) public var needDrawAttachment: Bool = false
    private(set) public var needDrawStrikethrough: Bool = false
    private(set) public var needDrawShadow: Bool = false
    private(set) public var needDrawInnerShadow: Bool = false
    private(set) public var needDrawUnderline: Bool = false
    private(set) public var needDrawBorder: Bool = false
    private(set) public var needDrawBlockBorder: Bool = false
    private(set) public var needDrawBackgroundBorder: Bool = false
    
    // MARK: draw method
    
//static void YYTextDrawBlockBorder(YYTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
    
    private func drawBlockBorder(_ context: CGContext, _ size: CGSize, _ position: CGPoint, _ cancel: ((Void) -> Bool)) throws {
        context.saveGState()
        context.translate(x: position.x, y: position.y)
        
//        for line in lines {
//            guard !cancel() else {
//                break
//            }
//            line.enumerateRun {
//                guard CTRunGetGlyphCount($2) > 0 else {
//                    return
//                }
//                guard let border = $1["YYTextBlockBorderAttributeName"] else {
//                    return
//                }
//                
//            }
//        }
        
        context.restoreGState()
    }
    private func drawBorder() throws {
    }
    private func drawShadow() throws {
    }
    private func drawDecoration() throws {
    }
    
    
    private func drawText(_ context: CGContext, _ size: CGSize, _ position: CGPoint, _ cancel: ((Void) -> Bool)) throws {
        context.saveGState()
        
        context.translate(x: position.x, y: position.y)
        context.translate(x: 0, y: size.height)
        context.scale(x: 1, y: -1)
        context.setShadow(offset: CGSize.zero, blur: 0)
        
        for line in lines {
            guard !cancel() else {
                break
            }
            
            context.textMatrix = CGAffineTransform.identity
            context.setTextPosition(x: line.position.x, y: size.height - line.position.y)
            
            (CTLineGetGlyphRuns(line.line) as NSArray).forEach {
                drawTextRun(context, $0 as! CTRun, line, size)
            }
        }
        
        // Use this to draw frame for test/debug.
        // CGContextTranslateCTM(context, 0, size.height)
        // CTFrameDraw(frame, context)
        
        context.restoreGState()
    }
    private func drawTextRun(_ context: CGContext, _ run: CTRun, _ line: SIMChatTextLine, _ size: CGSize) {
        
        //let attrs = CTRunGetAttributes(run) as NSDictionary
        let textMatrix = CTRunGetTextMatrix(run)
        let textMatrixIsId = textMatrix.isIdentity
        
//        guard let transform = attrs["YYTextGlyphTransformAttributeName"] else {
            // draw run
            if !textMatrixIsId {
                context.saveGState()
                context.textMatrix = context.textMatrix.concat(textMatrix)
            }
            
            CTRunDraw(run, context, CFRangeMake(0, 0))
            
            if !textMatrixIsId {
                context.restoreGState()
            }
//            return
//        }
        
        // draw glyph
        
//        CTFontRef runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
//        if (!runFont) return;
//        NSUInteger glyphCount = CTRunGetGlyphCount(run);
//        if (glyphCount <= 0) return;
//        
//        CGGlyph glyphs[glyphCount];
//        CGPoint glyphPositions[glyphCount];
//        CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
//        CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
//        
//        guard let font = attrs[String(kCTFontAttributeName)] as! CTFont? else {
//            return // draw fail
//        }
        
//        CGGlyph glyphs[glyphCount];
//        CGPoint glyphPositions[glyphCount];
//        CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
//        CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
//        let fillColor = attrs[String(kCTForegroundColorAttributeName)] as! CGColor? ?? UIColor.blackColor().CGColor
//        
//        CGContextSaveGState(context)
//        
//        CGContextSetFillColorWithColor(context, fillColor)
//        
//        if let strokeWidth = attrs[String(kCTStrokeWidthAttributeName)] as? CGFloat where strokeWidth != 0 {
//            let strokeColor = attrs[String(kCTStrokeColorAttributeName)] as! CGColor? ?? fillColor
//            let drawingMode: CGTextDrawingMode = strokeWidth > 0 ? .Stroke : .FillStroke
//            
//            CGContextSetLineWidth(context, CTFontGetSize(font) * fabs(strokeWidth * 0.01))
//            CGContextSetTextDrawingMode(context, drawingMode)
//            CGContextSetStrokeColorWithColor(context, strokeColor)
//        } else {
//            CGContextSetTextDrawingMode(context, .Fill)
//        }
//        
//        
//                    CFIndex runStrIdx[glyphCount + 1];
//                    CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
//                    CFRange runStrRange = CTRunGetStringRange(run);
//                    runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
//                    CGSize glyphAdvances[glyphCount];
//                    CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
//                    CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
//                    CGPoint zeroPoint = CGPointZero;
//                    
//                    for (NSUInteger g = 0; g < glyphCount; g++) {
//                        CGContextSaveGState(context); {
//                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//                            CGContextSetTextMatrix(context, glyphTransform);
//                            CGContextSetTextPosition(context,
//                                                     line.position.x + glyphPositions[g].x,
//                                                     size.height - (line.position.y + glyphPositions[g].y));
//                            
//                            if (CTFontContainsColorBitmapGlyphs(runFont)) {
//                                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
//                            } else {
//                                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                                CGContextSetFont(context, cgFont);
//                                CGContextSetFontSize(context, CTFontGetSize(runFont));
//                                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
//                                CGFontRelease(cgFont);
//                            }
//                        } CGContextRestoreGState(context);
//                    }
        
//
//                if (glyphTransformValue) {
//                    CFIndex runStrIdx[glyphCount + 1];
//                    CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
//                    CFRange runStrRange = CTRunGetStringRange(run);
//                    runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
//                    CGSize glyphAdvances[glyphCount];
//                    CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
//                    CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
//                    CGPoint zeroPoint = CGPointZero;
//                    
//                    for (NSUInteger g = 0; g < glyphCount; g++) {
//                        CGContextSaveGState(context); {
//                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//                            CGContextSetTextMatrix(context, glyphTransform);
//                            CGContextSetTextPosition(context,
//                                                     line.position.x + glyphPositions[g].x,
//                                                     size.height - (line.position.y + glyphPositions[g].y));
//                            
//                            if (CTFontContainsColorBitmapGlyphs(runFont)) {
//                                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
//                            } else {
//                                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                                CGContextSetFont(context, cgFont);
//                                CGContextSetFontSize(context, CTFontGetSize(runFont));
//                                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
//                                CGFontRelease(cgFont);
//                            }
//                        } CGContextRestoreGState(context);
//                    }
//                } else {
//                    if (CTFontContainsColorBitmapGlyphs(runFont)) {
//                        CTFontDrawGlyphs(runFont, glyphs, glyphPositions, glyphCount, context);
//                    } else {
//                        CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                        CGContextSetFont(context, cgFont);
//                        CGContextSetFontSize(context, CTFontGetSize(runFont));
//                        CGContextShowGlyphsAtPositions(context, glyphs, glyphPositions, glyphCount);
//                        CGFontRelease(cgFont);
//                    }
//                }
//
//        } 
//            CGContextRestoreGState(context)
    }
   
    
    private func drawAttachment() throws {
    }
    private func drawInnerShadow() throws {
    }
    private func drawDebug() throws {
    }
    
    private func drawInContext(_ context: CGContext, size: CGSize, position: CGPoint, view: UIView? = nil, layer: CALayer? = nil, cancel: ((Void) -> Bool)? = nil) {
        // generate test function
        let needDrawDebug = true
        let cancel = {
            return cancel?() ?? false
        }
        let drawCheck = {
            if cancel() {
                throw NSError(domain: "use cancel", code: 0, userInfo: nil)
            }
        }
        do {
            if needDrawBlockBorder {
                try drawCheck()
                try drawBlockBorder(context, size, position, cancel)
            }
            if needDrawBackgroundBorder {
                try drawCheck()
                try drawBorder()
            }
            if needDrawShadow{
                try drawCheck()
                try drawShadow()
            }
            if needDrawUnderline {
                try drawCheck()
                try drawDecoration()
            }
            if needDrawText {
                try drawCheck()
                try drawText(context, size, position, cancel)
            }
            if needDrawAttachment {
                try drawCheck()
                try drawAttachment()
            }
            if needDrawInnerShadow {
                try drawCheck()
                try drawInnerShadow()
            }
            if needDrawStrikethrough {
                try drawCheck()
                try drawDecoration()
            }
            if needDrawBorder {
                try drawCheck()
                try drawBorder()
            }
            if needDrawDebug {
                try drawCheck()
                try drawDebug()
            }
        } catch {
            return
        }
    }
    
    // MARK: create
    
    ///
    /// Creates a layout with the container.
    ///
    /// - parameter text: The text.
    /// - parameter container: The container.
    /// - parameter range: The range.
    ///
    private init(text: AttributedString, container: SIMChatTextContainer, range: NSRange) {
        
        let canvas: CGPath = {
            // generate of default canvas
            var canvas = container.path?.cgPath ?? {
                let rect = CGRect(origin: CGPoint.zero, size: container.size)
                let box = UIEdgeInsetsInsetRect(rect, container.insets)
                return CGPath(rect: box, transform: nil)
                }()
            // add the exclusion path to canvas, if need
            if !container.exclusionPaths.isEmpty {
                canvas = container.exclusionPaths.reduce(canvas.mutableCopy()) {
                    $0?.addPath(nil, path: $1.cgPath)
                    return $0
                    } ?? canvas
            }
            return canvas
        }()
        let canvasVirtual: CGPath = {
            var trans = CGAffineTransform(scaleX: 1, y: -1)
            return canvas.mutableCopy(using: &trans)
        }() ?? canvas
        let canvasRect = canvas.boundingBoxOfPath
        
        // frame setter config
        let frameAttrs = NSMutableDictionary()
        
        // create coretext objcts
        let frameSetter = CTFramesetterCreateWithAttributedString(text)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(range.location, range.length), canvasVirtual, frameAttrs)
       
        var row = 0
        var last: (position: CGPoint, rect: CGRect)? = nil
        var needTruncation = false
        var textBoundingRect = CGRect.zero
        
        // calculate line frame
        let lines: Array<SIMChatTextLine> = (CTFrameGetLines(frame) as NSArray).enumerated().flatMap { (i, e) in
            let position: CGPoint = {
                var origin = CGPoint.zero
                // read origin form frame
                CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &origin)
                // convert CoreText coordinate to UIKit coordinate
                return CGPoint(x: canvasRect.minX + origin.x, y: canvasRect.maxY - origin.y)
            }()
            let line = SIMChatTextLine(line: e as! CTLine, position: position)
            let rect = line.frame
            
            // check the line is a new row
            if let last = last {
                let pt = CGPoint(
                    x: last.rect.minX,
                    y: position.y
                )
                let lpt = CGPoint(
                    x: rect.minX,
                    y: last.position.y
                )
                if !(last.rect.contains(pt) || rect.contains(lpt)) {
                    row += 1
                }
            }
            
            _SIMChatTextDebug(rect)
            SIMLog.debug("\(i) => \(row) => \(line.range)")
            
            guard container.maximumNumberOfLines == 0 || row < container.maximumNumberOfLines else {
                needTruncation = true
                return nil
            }
            
            last = (position, rect)
            textBoundingRect = i != 0 ? textBoundingRect.union(rect) : rect
            
            // update line info
            line.row = row
            
            return line
        }
        
        // check last line
        if let last = lines.last {
            if !needTruncation && last.range.location + last.range.length < text.length {
                needTruncation = true
            }
        }
        
        // calculate bounding size
        let textBoundingSize: CGSize = {
            var rect = textBoundingRect
            if container.path == nil {
                let edg = UIEdgeInsetsMake(-container.insets.top,
                                           -container.insets.left,
                                           -container.insets.bottom,
                                           -container.insets.right)
                rect = UIEdgeInsetsInsetRect(rect, edg)
            } else {
                // ..
            }
            
            let width = rect.maxX
            let height = rect.maxY
            
            return CGSize(width: max(ceil(width), 0), height: max(ceil(height), 0))
        }()
        
        self.textBoundingRect = textBoundingRect
        self.textBoundingSize = textBoundingSize
        
        // calculate visibleRange
        var visibleRange: NSRange = {
            let range = CTFrameGetVisibleStringRange(frame)
            return NSMakeRange(range.location, range.length)
        }()
        
        // truncation text, if need
        if let last = lines.last where needTruncation {
            // adj lenght
            visibleRange.length = last.range.location + last.range.length - visibleRange.location
            // create truncated line
            
            // Warning: no imp
            // let truncationToken = container.truncationToken ?? {
            //     var attrs: [String: AnyObject]?
            //     if let run = (CTLineGetGlyphRuns(last.line) as NSArray).lastObject as! CTRun? {
            //         var dic = (CTRunGetAttributes(run) as NSDictionary) as? [String: AnyObject]
            //         
            //         // clean
            //         dic?.removeValueForKey(SIMChatTextAttachmentAttributeName)
            //         dic?[String(kCTFontAttributeName)] = {
            //             var fontSize = CGFloat(12)
            //             if let font = dic?[String(kCTFontAttributeName)] as! CTFont? {
            //                 fontSize = CTFontGetSize(font)
            //             }
            //             return UIFont.systemFontOfSize(fontSize * 0.9)
            //         }() as CTFont
            //         
            //         attrs = dic
            //     }
            //     return NSAttributedString(string: SIMChatTextTruncationToken, attributes: attrs)
            // }()
            // let truncationTokenLine = CTLineCreateWithAttributedString(truncationToken)
            // 
            // let lastLineText = text.attributedSubstringFromRange(last.range).mutableCopy() as! NSMutableAttributedString
            // lastLineText.appendAttributedString(truncationToken)
            // let ctLastLineExtend = CTLineCreateWithAttributedString(lastLineText)
            // let line = CTLineCreateTruncatedLine(ctLastLineExtend, Double(last.bounds.width), .Start, truncationTokenLine)
            // 
            // 
            // let t = SIMChatTextLine(line: line!, position: last.position)
            // 
            // t.row = last.row
            // 
            // lines.removeLast()
            // lines.append(t)
        }
        
//    for (NSUInteger i = 0, max = lines.count; i < max; i++) {
//        YYTextLine *line = lines[i];
//        if (truncatedLine && line.index == truncatedLine.index) line = truncatedLine;
//        if (line.attachments.count > 0) {
//            [attachments addObjectsFromArray:line.attachments];
//            [attachmentRanges addObjectsFromArray:line.attachmentRanges];
//            [attachmentRects addObjectsFromArray:line.attachmentRects];
//            for (YYTextAttachment *attachment in line.attachments) {
//                if (attachment.content) {
//                    [attachmentContentsSet addObject:attachment.content];
//                }
//            }
//        }
//    }
        
        // checking
        let block = { (dic: [String: AnyObject], range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) in
//            if dic[YYTextHighlightAttributeName] != nil {
//                self.containsHighlight = true
//            }
//            if dic[YYTextBlockBorderAttributeName] != nil {
//                self.needDrawBlockBorder = true
//            }
//            if dic[YYTextBackgroundBorderAttributeName] != nil {
//                self.needDrawBackgroundBorder = true
//            }
//            if dic[YYTextShadowAttributeName] != nil || dic[NSShadowAttributeName] != nil {
//                self.needDrawShadow = true
//            }
//            if dic[YYTextUnderlineAttributeName] != nil {
//                self.needDrawUnderline = true
//            }
//            if dic[YYTextAttachmentAttributeName] != nil {
//                self.needDrawAttachment = true
//            }
//            if dic[YYTextInnerShadowAttributeName] != nil {
//                self.needDrawInnerShadow = true
//            }
//            if dic[YYTextStrikethroughAttributeName] != nil {
//                self.needDrawStrikethrough = true
//            }
//            if dic[YYTextBorderAttributeName] != nil {
//                self.needDrawBorder = true
//            }
        }
        
        self.needDrawText = true
        
        text.enumerateAttributes(in: visibleRange, options: .longestEffectiveRangeNotRequired, using: block)
//    if (visibleRange.length > 0) {
//        layout.needDrawText = YES;
//        
//        void (^block)(NSDictionary *attrs, NSRange range, BOOL *stop) = ^(NSDictionary *attrs, NSRange range, BOOL *stop) {
//            if (attrs[YYTextHighlightAttributeName]) layout.containsHighlight = YES;
//            if (attrs[YYTextBlockBorderAttributeName]) layout.needDrawBlockBorder = YES;
//            if (attrs[YYTextBackgroundBorderAttributeName]) layout.needDrawBackgroundBorder = YES;
//            if (attrs[YYTextShadowAttributeName] || attrs[NSShadowAttributeName]) layout.needDrawShadow = YES;
//            if (attrs[YYTextUnderlineAttributeName]) layout.needDrawUnderline = YES;
//            if (attrs[YYTextAttachmentAttributeName]) layout.needDrawAttachment = YES;
//            if (attrs[YYTextInnerShadowAttributeName]) layout.needDrawInnerShadow = YES;
//            if (attrs[YYTextStrikethroughAttributeName]) layout.needDrawStrikethrough = YES;
//            if (attrs[YYTextBorderAttributeName]) layout.needDrawBorder = YES;
//        };
//        
//        [layout.text enumerateAttributesInRange:visibleRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:block];
//        if (truncatedLine) {
//            [truncationToken enumerateAttributesInRange:NSMakeRange(0, truncationToken.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:block];
//        }
//    }
        
        
        self.text = text
        self.range = range
        self.container = container
        self.frameSetter = frameSetter
        self.rowCount = row + 1
        self.frame = frame
        self.visibleRange = visibleRange
        
        self.lines = lines
        self.attachments = []
        
        self.truncatedLine = nil
    }
    
    ///
    /// Generate a layout with the given container size and text.
    ///
    /// - parameter text: The text
    /// - parameter size: The text container's size
    ///
    /// - returns A new layout
    ///
    public static func layout(_ text: AttributedString, size: CGSize) -> SIMChatTextLayout {
        return layout(text, container: SIMChatTextContainer(size: size))
    }
    
    ///
    /// Generate a layout with the given container and text.
    ///
    /// - parameter container: The text container
    /// - parameter text:      The text
    /// - parameter range:     The text range. If the length of the range is 0, it means the length is no limit.
    ///
    /// - returns: A new layout
    ///
    public static func layout(_ text: AttributedString, container: SIMChatTextContainer, range: NSRange? = nil) -> SIMChatTextLayout {
        return SIMChatTextLayout(text: text, container: container, range: range ?? NSMakeRange(0, text.length))
    }
    
    ///
    /// Generate layouts with the given containers and text.
    /// 
    /// - parameter containers: An array of SIMChatTextContainer object.
    /// - parameter text:       The text.
    /// - parameter range:      The text range. If the length of the range is 0, it means the length is no limit.
    ///
    /// - returns An array of SIMChatTextLayout object (the count is same as containers)
    ///
    public static func layout(_ text: AttributedString, containers: [SIMChatTextContainer], range: NSRange? = nil) -> [SIMChatTextLayout] {
        var range = range ?? NSMakeRange(0, text.length)
        return containers.flatMap {
            guard range.location + range.length < text.length else {
                return nil
            }
            let layout = self.layout(text, container: $0, range: range)
            
            range.location = layout.visibleRange.location + layout.visibleRange.length
            range.length = text.length - range.location
            
            return layout
        }
    }
    
}

///
/// A text line object wrapped `CTLine`, see `SIMChatTextLayout` for more.
///
public class SIMChatTextLine {
    
    public init(line: CTLine, position: CGPoint = CGPoint.zero) {
        
        let firstOffset: CGPoint = {
            guard let run = (CTLineGetGlyphRuns(line) as NSArray).firstObject as! CTRun? else {
                return CGPoint.zero
            }
            var pos = CGPoint.zero
            CTRunGetPositions(run, CFRangeMake(0, 1), &pos)
            return pos
        }()
        // generate other
        (self.lineWidth, self.trailingWhitespaceWidth, self.ascent, self.descent, self.leading) = {
            var ascent = CGFloat(0)
            var descent = CGFloat(0)
            var leading = CGFloat(0)
            let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            let twWidth = CTLineGetTrailingWhitespaceWidth(line)
            return (CGFloat(width), CGFloat(twWidth), ascent, descent, leading)
            }()
        // generate the bounds
        self.bounds = CGRect(x: 0, y: 0 - ascent + firstOffset.x, width: lineWidth, height: ascent + descent + leading)
        
        self.line = line
        self.position = position
        self.range = {
            let range = CTLineGetStringRange(line)
            return NSMakeRange(range.location, range.length)
        }()
        // generate the attachments
        self.attachments = (CTLineGetGlyphRuns(line) as NSArray).flatMap { e in
            let run = e as! CTRun
            let attrs = CTRunGetAttributes(run) as NSDictionary
            
            guard let attachment = attrs[SIMChatTextAttachmentAttributeName] as? SIMChatTextAttachment else {
                return nil
            }
            
            let range: CFRange = CTRunGetStringRange(run)
            let rect: CGRect = {
                var position = CGPoint.zero
                // get the run origin position
                CTRunGetPositions(run, CFRangeMake(0, 1), &position)
                
                var ascent = CGFloat(0)
                var descent = CGFloat(0)
                var leading = CGFloat(0)
                // get the run parameters
                let width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading))
                
                return CGRect(x: position.x , y: -position.y - ascent, width: width, height: ascent + descent + leading)
            }()

            return (attachment, NSMakeRange(range.location, range.length), rect)
        }
    }
    
    /// enumerate all runs
    public func enumerateRun(_ block: (Int, NSDictionary, CTRun) -> Void) {
        (CTLineGetGlyphRuns(line) as NSArray).enumerated().forEach {
            let run = $0.element as! CTRun
            let attrs = CTRunGetAttributes(run) as NSDictionary
            block($0.offset, attrs, run)
        }
    }
    
    //CTLineGetGlyphRuns
    
    public var row: Int = 0
    
    public var frame: CGRect {
        return CGRect(x: position.x + bounds.minX, y: position.y + bounds.minY, width: bounds.width, height: bounds.height)
    }
    
    public let range: NSRange
    public var bounds: CGRect
    public var position: CGPoint
    
    public let line: CTLine
    public let lineWidth: CGFloat
    public let attachments: Array<(SIMChatTextAttachment, NSRange, CGRect)>
    
    public let ascent: CGFloat
    public let descent: CGFloat
    public let leading: CGFloat
    public let trailingWhitespaceWidth: CGFloat
}

///
/// ![](/Users/sagesse/Projects/swift-chat/Design/Reference/Glyphs_Metris_0.png)
/// ![](/Users/sagesse/Projects/swift-chat/Design/Reference/Glyphs_Metris_1.gif)
///
public class SIMChatTextAttachment {
    ///
    /// Additional information about the the run delegate.
    ///
    public var userInfo: Dictionary<String, AnyObject> {
        set { return _userInfo = newValue }
        get { return _userInfo }
    }
    ///
    /// The typographic width of glyphs in the run.
    ///
    public var width: CGFloat {
        set { return _width = newValue }
        get { return _width }
    }
    ///
    /// The typographic ascent of glyphs in the run.
    ///
    public var ascent: CGFloat {
        set { return _ascent = newValue }
        get { return _ascent }
    }
    ///
    /// The typographic descent of glyphs in the run.
    ///
    public var descent: CGFloat {
        set { return _descent = newValue }
        get { return _descent }
    }
    ///
    /// Creates and returns the CTRunDelegate.
    /// 
    /// The CTRunDelegateRef has a strong reference to this `SIMChatTextAttachment` object.
    /// In CoreText, use CTRunDelegateGetRefCon() to get this `SIMChatTextAttachment` object.
    /// 
    /// - returns: The `CTRunDelegate` object.
    ///
    public var runDelegate: CTRunDelegate {
        get { return _runDelegate }
    }
    
    private lazy var _width: CGFloat = 0.0
    private lazy var _ascent: CGFloat = 0.0
    private lazy var _descent: CGFloat = 0.0
    private lazy var _userInfo: Dictionary<String, AnyObject> = [:]
    
    private lazy var _runDelegate: CTRunDelegate = {
        var callbacks = CTRunDelegateCallbacks(
            version: kCTRunDelegateCurrentVersion,
            dealloc: _SIMChatTextAttachmentRelease,
            getAscent: _SIMChatTextAttachmentGetAscent,
            getDescent: _SIMChatTextAttachmentGetDescent,
            getWidth: _SIMChatTextAttachmentGetWidth)
        return CTRunDelegateCreate(&callbacks, _SIMChatTextAttachmentRetain(self))!
    }()
}


public class SIMChatLabel: UIView {

    public override func draw(_ rect: CGRect) {
        // Drawing code
        
        let path = CGMutablePath()
        
        
        path.addRect(nil, rect: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        
        let ms = NSMutableAttributedString(string: "abcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabc")
//        let ms = NSMutableAttributedString(string: "abcabcabcabcabcabcabcabcabc")
        var attributes: [String: AnyObject] = [:]
        
        attributes[String(kCTForegroundColorAttributeName)] = UIColor.purple().cgColor
        attributes[String(kCTFontAttributeName)] = CTFontCreateWithName(UIFont.italicSystemFont(ofSize: 20).fontName, 20, nil)
        //attributes[String(kCTUnderlineStyleAttributeName)] = 9//kCTUnderlineStyleDouble
        //kCTUnderlineStyleAttributeName
        
//        //换行模式
//        CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;
//        CTParagraphStyleSetting lineBreakMode;
//        lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
//        lineBreakMode.value = &lineBreak;
//        lineBreakMode.valueSize = sizeof(CTLineBreakMode);
        
        ms.addAttributes(attributes, range: NSMakeRange(0, ms.length))
        
        var kk = NSMakeRange(0, ms.length)
        print(ms.attributes(at: 0, effectiveRange: &kk))
        
//        let att = SIMChatTextAttachment()
//        
//        att.width = 88
//        att.ascent = 32
//        att.descent = 0
//        
//        ms.addAttribute(
//            String(kCTRunDelegateAttributeName),
//            value: att.runDelegate,
//            range: NSMakeRange(0, 1))
        
        
        //let c1 = SIMChatTextContainer(path: UIBezierPath(roundedRect: bounds, cornerRadius: 20))
//        let c1 = SIMChatTextContainer(path: UIBezierPath(roundedRect: CGRectMake(0, 0, 320, 320), cornerRadius: 20))
        let c1 = SIMChatTextContainer(size: CGSize(width: 320, height: 320), insets: UIEdgeInsetsMake(10, 10, 10, 10))
        c1.exclusionPaths = [
            UIBezierPath(ovalIn: CGRect(x: (320 - 120) / 2 - 50, y: (320 - 120) / 2 - 50, width: 120, height: 120)),
            UIBezierPath(ovalIn: CGRect(x: (320 - 120) / 2 + 50, y: (320 - 120) / 2 + 50, width: 120, height: 120)),
            UIBezierPath(ovalIn: CGRect(x: (320 - 120) / 2, y: (320 - 120) / 2, width: 120, height: 120))
        ]
        
        c1.maximumNumberOfLines = 2
        
        let layout = SIMChatTextLayout.layout(ms, container: c1)
        
        
        layout.drawInContext(UIGraphicsGetCurrentContext()!, size: CGSize(width: 320, height: 320), position: CGPoint(x: 0, y: 0))
        //let zzz = TTT()
        
//        //CTRunDelegateCreate
//
//        
//        let setter = CTFramesetterCreateWithAttributedString(ms)
//        let frame = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), path, nil)
//        
//        let lines = CTFrameGetLines(frame)
//        
//        print(CFArrayGetCount(lines))
//        
//        let context = UIGraphicsGetCurrentContext()
//        
//        CGContextSaveGState(context)
//        
//        CGContextTranslateCTM(context, 0 ,self.bounds.size.height)
//        CGContextScaleCTM(context, 1.0 ,-1.0)
//        
//        CTFrameDraw(frame, context!)
//    
//        CGContextRestoreGState(context)
    }
}
