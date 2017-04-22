//
//  Logger.swift
//
//  Created by SAGESSE on 9/19/15.
//  Copyright © 2015-2017 Sagesse. All rights reserved.
//

import Foundation


internal class Logger {
    
    internal enum Priority: Int, CustomStringConvertible, Comparable {
        
        /// The ALL has the lowest possible rank and is intended to turn on all logging.
        case all
        /// The TRACE Level designates finer-grained informational events than the DEBUG
        case trace
        /// The DEBUG Level designates fine-grained informational events that are most useful to debug an application.
        case debug
        /// The INFO level designates informational messages that highlight the progress of the application at coarse-grained level.
        case info
        /// The WARN level designates potentially harmful situations.
        case warn
        /// The ERROR level designates error events that might still allow the application to continue running.
        case error
        /// The FATAL level designates very severe error events that will presumably lead the application to abort.
        case fatal
        /// The OFF has the highest possible rank and is intended to turn off logging.
        case off
        
        ///
        /// A textual representation of this instance.
        ///
        /// Instead of accessing this property directly, convert an instance of any
        /// type to a string by using the `String(describing:)` initializer. For
        ///
        internal var description: String {
            switch self {
            case .all: return "ALL"
            case .trace: return "TRACE"
            case .debug: return "DEBUG"
            case .info: return "INFO"
            case .warn: return "WARN"
            case .error: return "ERROR"
            case .fatal: return "FATAL"
            case .off: return "OFF"
            }
        }
        
        ///
        /// Returns a Boolean value indicating whether the value of the first
        /// argument is less than that of the second argument.
        ///
        /// This function is the only requirement of the `Comparable` protocol. The
        /// remainder of the relational operator functions are implemented by the
        /// standard library for any type that conforms to `Comparable`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        ///
        internal static func <(lhs: Logger.Priority, rhs: Logger.Priority) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        ///
        /// Create priority with name
        ///
        /// - Parameters:
        ///   - name: the priority string name
        ///
        internal init?(name: String) {
            switch name.uppercased() {
            case "ALL": self = .all
            case "TRACE": self = .trace
            case "DEBUG": self = .debug
            case "INFO": self = .info
            case "WARN": self = .warn
            case "ERROR": self = .error
            case "FATAL": self = .fatal
            case "OFF": self = .off
            default: return nil
            }
        }
    }
    
    internal class Log {
        
        internal init(`class`: String, priority: Priority) {
            self.class = `class`
            self.priority = priority
        }
        internal let `class`: String
        internal let `priority`: Priority
        
        internal var date: Date = .init()
        internal var line: Int = 0
        
        internal var thread: mach_port_t = 0
        
        internal var fileName: String = ""
        internal var file: String = "" {
            willSet {
                fileName = (newValue as NSString).lastPathComponent
            }
        }
        
        internal var method: String = ""
        internal var message: String = ""
    }
    internal class Layout {
        ///
        /// create a forrmater
        ///
        /// - Parameter format: %[algin][min].[max][command]{attachment}
        ///
        internal init(pattern: String) {
            // create a regular expression parsing
            let length = pattern.lengthOfBytes(using: .utf8)
            let regex = try? NSRegularExpression(pattern: "%(-?\\d*(?:\\.\\d+)?)([cCdFlLmMnprt])(?:(?<=d)\\{([^}]+)\\})?")
            // fetch matching results
            let format = NSMutableString(string: pattern)
            let results = regex?.matches(in: pattern, options: .withoutAnchoringBounds, range: .init(location: 0, length: length)) ?? []
            // convert result to node
            // note: must be from the front after processing order
            _format = format
            _nodes = results.reversed().map {
                // get sub string
                func substr(_ str: NSString, with range: NSRange) -> String? {
                    guard range.location != NSNotFound else {
                        return nil
                    }
                    return str.substring(with: range)
                }
                // 0: all, 1:limit, 2:cmd: 3:att
                let node = Node()
                
                // get base
                node.format = substr(format, with: $0.range) ?? ""
                node.command = substr(format, with: $0.rangeAt(2)) ?? ""
                // get attachment
                node.attachment = substr(format, with: $0.rangeAt(3))
                
                // update the format
                format.replaceCharacters(in: $0.range, with: "%\(substr(format, with: $0.rangeAt(1)) ?? "")S")
                
                return node
                }.reversed()
        }
        // use the log format string
        internal func format(with log: Log) -> String {
            // the format string, note: that you should hold the array to use pointer
            let parameters = _nodes.map({ $0.format(with: log) })
            // convert a string to CVarArg
            return .init(format: (_format as String), arguments: parameters.map {
                return ($0 as NSString).cString(using: String.Encoding.utf16.rawValue)!
            })
        }
        
        private let _format: NSString
        private let _nodes: Array<Node>
        
        private class Node {
            
            var format: String = "" // 格式
            var command: String = "" // 命令
            var attachment: String? // 附加信息
            
            func format(with log: Log) -> String {
                switch command {
                    
                case "r": // 输出自应用启动到输出该log信息耗费的毫秒数
                    return "\(ProcessInfo().systemUptime)"
                    
                case "t": // 输出产生该日志事件的线程名
                    return "\(log.thread)"
                    
                case "d": // 输出日志时间点的日期或时间，默认格式为ISO8601，也可以在其后指定格式.
                    let df = DateFormatter()
                    if let fmt = attachment {
                        df.dateFormat = fmt
                    } else {
                        df.dateFormat = "yyyy-MM-dd HH:mm:ss,SSS"
                    }
                    return df.string(from: log.date)
                    
                case "p": // 输出日志信息优先级，即DEBUG，INFO，WARN，ERROR，FATAL,
                    return log.priority.description
                    
                case "m": // 输出日志信息
                    return log.message
                    
                case "n": // 输出一个回车换行符，Windows平台为"\r\n"，Unix平台为"\n"输出日志信息换行
                    return "\n"
                    
                case "F": // 输出日志消息产生时所在的文件名称
                    return log.fileName
                    
                case "L": // 输出代码中的行号
                    return "\(log.line)"
                    
                case "C", "c": // 输出日志信息所属的类目，通常就是所在类的全名
                    return log.class
                    
                case "M": // 输出代码中的方法名
                    return log.method
                    
                case "l": // 输出日志事件的发生位置，相当于%C.%M(%F:%L)的组合, 包括类目名、发生的线程，以及在代码中的行数.
                    return "\(log.class).\(log.method)(\(log.fileName):\(log.line))"
                    
                default: // 未知参数
                    return "<Unknow>"
                }
            }
        }
    }
    internal class Stream {
        
        internal init(class: String, priority: Priority) {
            _class = `class`
            _priority = `priority`
        }
        
        // This is the most generic printing method.
        internal func write(_ items: Any..., method: String = #function, file: String = #file, line: Int = #line) {
            _write(items, method: method, file: file, line: line)
        }
        
        private func _write(_ items: [Any], method: String, file: String, line: Int) {
            // collect the log information
            let log = Log(class: _class, priority: _priority)
            log.thread = mach_thread_self()
            log.file = file
            log.line = line
            log.method = method
            log.message = items.reduce(nil) {
                $0?.appending(", \($1)") ?? "\($1)"
            } ?? ""
            // output
            Logger.appender.forEach {
                // check the output priority
                guard log.priority >= $0.threshold else {
                    return
                }
                $0.write(log)
            }
        }
        
        private var _class: String
        private var _priority: Priority
    }
    internal class Appender {
        // default init
        internal init(name: String = "default", pattern: String = "%m%n", threshold: Priority = .all) {
            
            self.name = name
            self.pattern = pattern
            self.threshold = threshold
            
            self.layout = .init(pattern: pattern)
        }
        // decode init
        internal init?(coder: NSCoder) {
            // read the appender the name
            guard let name = coder.decodeObject(forKey: "name") as? String else {
                return nil
            }
            // read the appender the pattern
            guard let pattern = coder.decodeObject(forKey: "pattern") as? String else {
                return nil
            }
            // read the appender the threshold
            guard let threshold = Priority(name: coder.decodeObject(forKey: "threshold") as? String ?? "") else {
                return nil
            }
            // init
            self.name = name
            self.pattern = pattern
            self.threshold = threshold
            
            self.layout = .init(pattern: pattern)
        }
        
        /// write a log, default is no imp
        internal func write(_ parameter: Log) {
            assertionFailure()
        }
        
        /// appender name
        internal let name: String
        /// appender pattern , default is %m%n
        internal let pattern: String
        /// appender threshold, default is all
        internal let threshold: Priority
        
        internal let layout: Layout
        
        // stream write to console
        internal class Console: Appender {
            // init
            internal init(threshold: Priority = .all) {
                super.init(name: "stdout", pattern: "[%-5p] %C.%M: %m%n", threshold: threshold)
            }
            // write a log
            internal override func write(_ log: Logger.Log) {
                #if DEBUG
                    Console._queue.sync {
                        print(self.layout.format(with: log), terminator: "")
                    }
                #else
                    Console._queue.async {
                        print(self.layout.format(with: log), terminator: "")
                    }
                #endif
            }
            
            private static var _queue = DispatchQueue(label: "logger.appender.console", attributes: [])
        }
        // stream write to file
        internal class File: Appender {
            // init
            internal init() {
                super.init(name: "file", pattern: "%d [%-5p] %l: %m%n")
                
                let t = NSTemporaryDirectory()
                print(t)
                //_file = fopen("\(t)/verbose.log", "a+")
                _file = fopen("\(t)/verbose.log", "w")
            }
            deinit {
                guard let file = _file else {
                    return
                }
                fclose(file)
            }
            // write a log
            internal override func write(_ log: Logger.Log) {
                guard let file = _file else {
                    return
                }
                // TODO: 自动文件名
                // TODO: 文件自动截断
                
                File._queue.async {
                    // 写入并更新文件
                    let str = self.layout.format(with: log)
                    fwrite(str, str.lengthOfBytes(using: .utf8), 1, file)
                    fflush(file)
                }
            }
            
            private var _file: UnsafeMutablePointer<FILE>?
            private static var _queue = DispatchQueue(label: "logger.appender.file", attributes: [])
        }
        
    }
    
    fileprivate init() {
        _name = ""
    }
    fileprivate init(class: AnyClass) {
        _name = "\(`class`)"
    }
    
    fileprivate let _name: String
    fileprivate func _logger(_ priority: Priority) -> Stream? {
        // the level is enabled?
        guard priority >= Logger.threshold else {
            return nil
        }
        // make
        return Stream(class: _name, priority: priority)
    }
    
    internal var trace: Stream? {
        return _logger(.trace)
    }
    internal var debug: Stream? {
        return _logger(.debug)
    }
    internal var info: Stream? {
        return _logger(.info)
    }
    internal var warning: Stream? {
        return _logger(.warn)
    }
    internal var error: Stream? {
        return _logger(.error)
    }
    internal var fatal: Stream? {
        return _logger(.fatal)
    }
    
    internal static var threshold: Priority = Logger.appender.reduce(.off) {
        guard $1.threshold < $0 else {
            return $0
        }
        return $1.threshold
    }
    internal static var appender: Array<Appender> = [
        Appender.File(),
        Appender.Console(threshold: .all),
    ]
}

internal let logger = Logger()
internal extension NSObjectProtocol {
    internal var logger: Logger {
        return Logger(class: type(of: self))
    }
}
