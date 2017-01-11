//
//  SACMessageTimeLineContent.swift
//  SAChat
//
//  Created by sagesse on 06/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACMessageTimeLineContent: NSObject, SACMessageContentType {
    
    open var layoutMargins: UIEdgeInsets = .zero//.init(top: 8, left: 0, bottom: -8, right: 0)
    
    open class var viewType: SACMessageContentViewType.Type {
        return SACMessageTimeLineContentView.self
    }
    
    public init(date: Date) {
        self.date = date
        self.text = SACMessageTimeLineContent.dd(date)
        super.init()
    }
    
    internal var before: SACMessageType?
    internal var after: SACMessageType?
    
    open var date: Date
    open var text: String
    
    static func dd(_ date: Date) -> String {
        
        // yy-MM-dd hh:mm
        // 星期一 hh:mm - 7 * 24小时内
        // 昨天 hh:mm - 2 * 24小时内
        // 今天 hh:mm - 24小时内
        
        let s1 = TimeInterval(date.timeIntervalSince1970)
        let s2 = TimeInterval(time(nil))
        
        let dz = TimeInterval(TimeZone.current.secondsFromGMT())
        
        let formatter = DateFormatter()
        let format1 = DateFormatter.dateFormat(fromTemplate: "hh:mm", options: 0, locale: nil) ?? "hh:mm"
        
        let days1 = Int64(s1 + dz) / (24 * 60 * 60)
        let days2 = Int64(s2 + dz) / (24 * 60 * 60)
        
        switch days1 - days2 {
        case +0:
            // Today
            formatter.dateFormat = "'Today' \(format1)"
        case +1:
            // Tomorrow
            formatter.dateFormat = "'Tomorrow' \(format1)"
        case +2 ... +7:
            // 2 - 7 day later
            formatter.dateFormat = "EEEE \(format1)"
        case -1:
            // Yesterday
            formatter.dateFormat = "'Yesterday' \(format1)"
        case -7 ... -2:
            // 2 - 7 day ago
            formatter.dateFormat = "EEEE \(format1)"
        default:
            // Distant
            formatter.dateFormat = "yy-MM-dd \(format1)"
        }
        
        return formatter.string(from: date)
    }
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: size.width, height: 20)
    }
}
