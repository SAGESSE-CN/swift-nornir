//
//  SIMLog.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

/// log manager
public class SIMLog : NSObject {
    
    /// trace level
    public class func trace(_ message: Any = "",
        _ function: StaticString = #function,
        _ file: String = #file,
        _ line: Int = #line)
    {
        // Forwarding
        log("TRACE", message, function, file, line)
    }
    /// debug level
    public class func debug(_ message: Any = "",
        _ function: StaticString = #function,
        _ file: String = #file,
        _ line: Int = #line)
    {
        // Forwarding
        log("DEBUG", message, function, file, line)
    }
    /// info level
    public class func info(_ message: Any = "",
        _ function: StaticString = #function,
        _ file: String = #file,
        _ line: Int = #line)
    {
        // Forwarding
        log("INFO", message, function, file, line)
    }
    /// warning level
    public class func warning(_ message: Any = "",
        _ function: StaticString = #function,
        _ file: String = #file,
        _ line: Int = #line)
    {
        // Forwarding
        log("WARN", message, function, file, line)
    }
    /// error level
    public class func error(_ message: Any = "",
        _ function: StaticString = #function,
        _ file: String = #file,
        _ line: Int = #line)
    {
        // Forwarding
        log("ERROR", message, function, file, line)
    }
    /// fatal level
    public class func fatal(_ message: Any = "",
        _ function: StaticString = #function,
        _ file: String = #file,
        _ line: Int = #line)
    {
        // Forwarding
        log("FATAL", message, function, file, line)
    }
    /// out
    public class func log(_ level: StaticString,
        _ message: Any, 
        _ function: StaticString = #function,
        _ file: String = #file,
        _ line: Int = #line)
    {
        let fname = ((file as NSString).lastPathComponent as NSString).deletingPathExtension
        #if DEBUG
            objc_sync_enter(self.queue)
            
            //[%-5p](%d{yyyy-MM-dd HH:mm:ss}) %M - %m%n
            print("[\(level)] \(fname).\(function): \(message)")
            
            objc_sync_exit(self.queue)
        #else
            self.queue.async {
                //[%-5p](%d{yyyy-MM-dd HH:mm:ss}) %M - %m%n
                print("[\(level)] \(fname).\(function): \(message)")
            }
        #endif
    }
    
    private(set) static var queue = DispatchQueue(label: "log.queue", attributes: [])
}
