//
//  SIMChatMessageBox.swift
//  SIMChat
//
//  Created by sagesse on 2/22/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation
//
//public struct SIMChatMessageBox {
//    public struct Alert {
//        ///
//        /// Alert Event, Isolation CustomAlert
//        ///
//        public class Event {
//            ///
//            /// Show dialog
//            ///
//            public func show() -> Self {
//                // anyway switch thread
//                DispatchQueue.main.async {
//                    self.alert.show()
//                }
//                return self
//            }
//            ///
//            /// Hide dialog
//            ///
//            public func dismiss() {
//                DispatchQueue.main.async {
//                    self.alert.dismiss(withClickedButtonIndex: self.alert.cancelButtonIndex, animated: true)
//                }
//            }
//            ///
//            /// setup confirm block
//            ///
//            public func confirm(_ block: @escaping ((Void) -> Void)) -> Self {
//                self.alert.confirm(block)
//                return self
//            }
//            ///
//            /// setup cancel block
//            ///
//            public func cancel(_ title: String = "取消", block: ((Void) -> Void)? = nil) -> Self {
//                self.alert.cancel(title, block: block)
//                return self
//            }
//            ///
//            /// setup custom
//            ///
//            public func custom(_ btn: String, block: @escaping ((Void) -> Void)) -> Self {
//                self.alert.custom(btn, block: block)
//                return self
//            }
//            
//            /// map to alert
//            private let alert: CustomAlert
//            private init(_ alert: CustomAlert) {
//                self.alert = alert
//            }
//        }
//        ///
//        /// Alert Event extrion, Isolation CustomAlert
//        ///
//        public class EventEx : Event {
//            ///
//            /// setup username block
//            ///
//            public func username(_ value: String? = nil, block: ((String?) -> Void)) -> Self {
//                self.alert.username(value, block: block)
//                return self
//            }
//            ///
//            /// setup password block
//            ///
//            public func password(_ value: String? = nil, block: ((String?) -> Void)) -> Self {
//                self.alert.password(value, block: block)
//                return self
//            }
//        }
//        ///
//        /// show error style dialog
//        ///
//        public static func notice(
//            _ message: String,
//            title: String = "通知",
//            confirm: String = "好") -> Event {
//                return Event(CustomAlert(title: title, message: message, confirm: confirm)).show()
//        }
//        ///
//        /// show error style dialog
//        public static func error(
//            _ error: NSError,
//            title: String = "错误",
//            confirm: String = "好") -> Event {
//                return self.error(error.localizedDescription, title: title, confirm: confirm)
//        }
//        ///
//        ///
//        /// show error style dialog
//        ///
//        public static func error(
//            _ message: String,
//            title: String = "错误",
//            confirm: String = "好") -> Event {
//                return Event(CustomAlert(title: title, message: message, confirm: confirm)).show()
//        }
//        ///
//        /// show warning style dialog
//        ///
//        public static func warning(
//            _ message: String,
//            title: String = "警告",
//            confirm: String = "好") -> Event {
//                return Event(CustomAlert(title: title, message: message, confirm: confirm)).show()
//        }
//        ///
//        /// show input style dialog
//        ///
//        public static func input(
//            _ message: String,
//            title: String = "",
//            confirm: String = "好") -> EventEx {
//                return EventEx(CustomAlert(title: title, message: message, confirm: confirm)).show()
//        }
//        
//        ///
//        private class CustomAlert : UIAlertView, UIAlertViewDelegate {
//            convenience init(title: String, message: String, confirm: String) {
//                self.init(title: title, message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: confirm)
//                self.delegate = self
//            }
//            /// setup confirm block
//            func confirm(_ block: @escaping ((Void) -> Void)) -> Self {
//                confirmBlock = block
//                return self
//            }
//            /// setup cancel block
//            func cancel(_ title: String, block: ((Void) -> Void)? = nil) -> Self {
//                // been added
//                if cancelBlock != nil {
//                    // title change no imp
//                    cancelBlock = block
//                    return self
//                }
//                cancelBlock = block
//                cancelButtonIndex = addButton(withTitle: title)
//                return self
//            }
//            /// setup custom
//            func custom(_ btn: String, block: @escaping ((Void) -> Void)) -> Self {
//                let idx = addButton(withTitle: btn)
//                otherBlocks[idx] = block
//                return self
//            }
//            /// setup username block
//            func username(_ value: String? = nil, block: @escaping ((String?) -> Void)) -> Self {
//                usernameBlock = block
//                usernameDefaultValue = value
//                updateUsernameAndPassword()
//                return self
//            }
//            /// setup password block
//            func password(_ value: String? = nil, block: @escaping ((String?) -> Void)) -> Self {
//                passwordBlock = block
//                passwordDefaultValue = value
//                updateUsernameAndPassword()
//                return self
//            }
//            
//            /// did select
//            @objc func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
//                // Must be before the click event
//                // Ignore the cancel event
//                if buttonIndex != cancelButtonIndex {
//                    switch (usernameBlock, passwordBlock) {
//                    case (.some, .some): usernameBlock?(textField(at: 0)?.text)
//                    passwordBlock?(textField(at: 1)?.text)
//                    case (.some, .none): usernameBlock?(textField(at: 0)?.text)
//                    case (.none, .some): passwordBlock?(textField(at: 0)?.text)
//                    case (.none, .none): break
//                    }
//                }
//                switch buttonIndex {
//                case 0:                 confirmBlock?()
//                case cancelButtonIndex: cancelBlock?()
//                default:                otherBlocks[buttonIndex]?()
//                }
//            }
//            
//            /// update username & password
//            func updateUsernameAndPassword() {
//                switch (usernameBlock, passwordBlock) {
//                case (.some, .some):
//                    alertViewStyle = .loginAndPasswordInput
//                    textField(at: 0)?.text = usernameDefaultValue
//                    textField(at: 1)?.text = passwordDefaultValue
//                case (.some, .none):
//                    alertViewStyle = .plainTextInput
//                    textField(at: 0)?.text = usernameDefaultValue
//                case (.none, .some):
//                    alertViewStyle = .secureTextInput
//                    textField(at: 0)?.text = passwordDefaultValue
//                case (.none, .none):
//                    alertViewStyle = .default
//                }
//            }
//            
//            // attrib
//            var cancelBlock: ((Void) -> Void)?
//            var confirmBlock: ((Void) -> Void)?
//            var otherBlocks: [Int: ((Void) -> Void)] = [:]
//            
//            // input attrib
//            var usernameBlock: ((String?) -> Void)?
//            var passwordBlock: ((String?) -> Void)?
//            var usernameDefaultValue: String?
//            var passwordDefaultValue: String?
//        }
//    }
//    public struct ActionSheet {
//        ///
//        /// Menu event
//        ///
//        public class Event {
//            ///
//            /// Hide for window
//            ///
//            public func dismiss() {
//                DispatchQueue.main.async {
//                    self.sheet.dismiss(withClickedButtonIndex: self.sheet.cancelButtonIndex, animated: true)
//                }
//            }
//            ///
//            /// setup & add a option
//            ///
//            public func option(_ title: String, block: @escaping ((Void) -> Void)) -> Self {
//                sheet.option(title, block: block)
//                return self
//            }
//            ///
//            /// setup cancel event
//            ///
//            public func cancel(_ block: @escaping ((Void) -> Void)) -> Self {
//                sheet.cancel(block)
//                return self
//            }
//            ///
//            /// setup & add a destructive
//            ///
//            public func destructive(_ title: String, block: @escaping ((Void) -> Void)) -> Self {
//                sheet.destructive(title, block: block)
//                return self
//            }
//            
//            /// map to sheet
//            private let sheet: CustomActionSheet
//            private init(_ sheet: CustomActionSheet) {
//                self.sheet = sheet
//            }
//        }
//        ///
//        /// show menu to window
//        ///
//        public static func show(_ title: String? = nil, cancel: String = "取消") -> Event {
//            return Event(CustomActionSheet(title: title, cancel: cancel).show())
//        }
//        
//        ///
//        private class CustomActionSheet : UIActionSheet, UIActionSheetDelegate {
//            convenience init(title: String?, cancel: String?) {
//                self.init(title: title, delegate: nil, cancelButtonTitle: cancel, destructiveButtonTitle: nil)
//                self.delegate = self
//            }
//            /// Display to window
//            func show() -> Self {
//                DispatchQueue.main.async {
//                    guard let window = UIApplication.shared.keyWindow else {
//                        return
//                    }
//                    self.show(in: window)
//                }
//                return self
//            }
//            /// setup & add a option
//            func option(_ title: String, block: @escaping ((Void) -> Void)) -> Self {
//                let idx = addButton(withTitle: title)
//                optionBlocks[idx] = block
//                return self
//            }
//            /// setup cancel event
//            func cancel(_ block: @escaping ((Void) -> Void)) -> Self {
//                cancelBlock = block
//                return self
//            }
//            /// setup & add a destructive
//            func destructive(_ title: String, block: @escaping ((Void) -> Void)) -> Self {
//                if destructiveBlock != nil {
//                    destructiveBlock = block
//                    return self
//                }
//                destructiveBlock = block
//                destructiveButtonIndex = addButton(withTitle: title)
//                return self
//            }
//            
//            /// did select row
//            @objc func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
//                switch buttonIndex {
//                case cancelButtonIndex:         cancelBlock?()
//                case destructiveButtonIndex:    destructiveBlock?()
//                default:                        optionBlocks[buttonIndex]?()
//                }
//            }
//            
//            // attrib
//            var cancelBlock: ((Void) -> Void)?
//            var destructiveBlock: ((Void) -> Void)?
//            var optionBlocks: [Int: (Void) -> Void] = [:]
//        }
//    }
//    public struct ActivityIndicator {
//        ///
//        /// start
//        ///
//        public static func begin() {
//            objc_sync_enter(taskCount)
//            if taskCount == 0 {
//                UIApplication.shared.isNetworkActivityIndicatorVisible = true
//            }
//            taskCount += 1
//            objc_sync_exit(taskCount)
//        }
//        ///
//        /// stop
//        ///
//        public static func end() {
//            objc_sync_enter(taskCount)
//            if taskCount > 0 {
//                taskCount -= 1
//                if taskCount == 0 {
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                }
//            }
//            objc_sync_exit(taskCount)
//        }
//        
//        /// Background task count
//        private static var taskCount: Int = 0
//    }
//}
