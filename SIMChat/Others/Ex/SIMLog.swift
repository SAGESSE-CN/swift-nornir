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
    public class func trace(message: Any = "",
        _ function: StaticString = __FUNCTION__,
        _ file: String = __FILE__,
        _ line: Int = __LINE__)
    {
        // Forwarding
        log("TRACE", message, function, file, line)
    }
    /// debug level
    public class func debug(message: Any = "",
        _ function: StaticString = __FUNCTION__,
        _ file: String = __FILE__,
        _ line: Int = __LINE__)
    {
        // Forwarding
        log("DEBUG", message, function, file, line)
    }
    /// info level
    public class func info(message: Any = "",
        _ function: StaticString = __FUNCTION__,
        _ file: String = __FILE__,
        _ line: Int = __LINE__)
    {
        // Forwarding
        log("INFO", message, function, file, line)
    }
    /// warning level
    public class func warning(message: Any = "",
        _ function: StaticString = __FUNCTION__,
        _ file: String = __FILE__,
        _ line: Int = __LINE__)
    {
        // Forwarding
        log("WARN", message, function, file, line)
    }
    /// error level
    public class func error(message: Any = "",
        _ function: StaticString = __FUNCTION__,
        _ file: String = __FILE__,
        _ line: Int = __LINE__)
    {
        // Forwarding
        log("ERROR", message, function, file, line)
    }
    /// fatal level
    public class func fatal(message: Any = "",
        _ function: StaticString = __FUNCTION__,
        _ file: String = __FILE__,
        _ line: Int = __LINE__)
    {
        // Forwarding
        log("FATAL", message, function, file, line)
    }
    /// out
    public class func log(level: StaticString,
        _ message: Any, 
        _ function: StaticString = __FUNCTION__,
        _ file: String = __FILE__,
        _ line: Int = __LINE__)
    {
        let fname = ((file as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
        #if DEBUG
            objc_sync_enter(self.queue)
            
            //[%-5p](%d{yyyy-MM-dd HH:mm:ss}) %M - %m%n
            print("[\(level)] \(fname).\(function): \(message)")
            
            objc_sync_exit(self.queue)
        #else
            dispatch_async(self.queue) {
                //[%-5p](%d{yyyy-MM-dd HH:mm:ss}) %M - %m%n
                print("[\(level)] \(fname).\(function): \(message)")
            }
        #endif
    }
    
    private(set) static var queue = dispatch_queue_create("log.queue", nil)
}