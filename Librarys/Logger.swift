//
//  Log.swift
//
//  Created by SAGESSE on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation


internal class Logger {
    init() {
        _name = ""
    }
    init(name: String) {
        _name = name
    }
    
    /// trace level
    func trace(
        _ message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("TRACE", message: message, function: function, file: file, line: line)
    }
    /// debug level
    func debug(
        _ message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("DEBUG", message: message, function: function, file: file, line: line)
    }
    /// info level
    func info(
        _ message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("INFO", message: message, function: function, file: file, line: line)
    }
    /// warning level
    func warning(
        _ message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("WARN", message: message, function: function, file: file, line: line)
    }
    /// error level
    func error(
        _ message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        var msg = message
        if let error = message as? NSError {
            msg = "\(error.domain) => \(error.localizedDescription)"
        }
        log("ERROR", message: msg, function: function, file: file, line: line)
    }
    /// fatal level
    func fatal(
        _ message: Any = "",
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        // Forwarding
        log("FATAL", message: message, function: function, file: file, line: line)
    }
    /// out
    func log(
        _ level: StaticString,
        message: Any,
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line)
    {
        #if DEBUG
            objc_sync_enter(Logger._queue)
            
            //[%-5p](%d{yyyy-MM-dd HH:mm:ss}) %M - %m%n
            print("[\(level)] \(_name).\(function): \(message)")
            
            objc_sync_exit(Logger._queue)
        #else
            Logger._queue.async {
                //[%-5p](%d{yyyy-MM-dd HH:mm:ss}) %M - %m%n
                print("[\(level)] \(self._name).\(function): \(message)")
            }
        #endif
    }
    
    private var _name: String
    private static var _queue = DispatchQueue(label: "log.queue", attributes: [])
}

internal extension NSObjectProtocol {
    var _logger: Logger {
        return objc_getAssociatedObject(self, &__LOGGER) as? Logger ?? {
            let logger = Logger(name: "\(type(of: self))")
            objc_setAssociatedObject(self, &__LOGGER, logger, .OBJC_ASSOCIATION_RETAIN)
            return logger
        }()
    }
    var logger: Logger {
        return _logger
    }
}

private var __LOGGER = "_logger"
