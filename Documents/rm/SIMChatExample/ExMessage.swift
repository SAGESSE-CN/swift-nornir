//
//  ExMessage.swift
//  SIMChatExample
//
//  Created by sagesse on 3/4/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
//import ImSDK
import SIMChat

//class ExMessage: SIMChatBaseMessage {
//    
////    lazy var imp: TIMMessage = {
////        let message = TIMMessage()
////        message.addElem(self.content.toTIMElem())
////        return message
////    }()
//}

//class ExUnknowContent: SIMChatMessageBody {
//}

//class ExTIMAudioResource: SIMChatResourceProtocol {
//    
//    init(sound: TIMSoundElem) {
//        _sound = sound
//    }
//    
//    /// 资源id
//    var identifier: String { return _sound.uuid }
//    /// 资源链接
//    var resourceURL: NSURL { return NSURL(string: "simchat://tim-sound")! }
//    
//    ///
//    /// 获取资源
//    ///
//    /// - parameter closure: 结果回调
//    ///
//    func resource(closure: SIMChatResult<AnyObject, NSError> -> Void) {
//        _sound.getSound({ data in
//            closure(.Success(data))
//            },
//            fail: { code, error in
//                closure(.Failure(NSError(domain: error, code: Int(code), userInfo: nil)))
//        })
//    }
//    
//    private var _sound: TIMSoundElem
//}
//
//class ExTIMImageResource: SIMChatResourceProtocol {
//    
//    init(image: TIMImage) {
//        _image = image
//    }
//    
//    /// 资源id
//    var identifier: String { return _image.uuid }
//    /// 资源链接
//    var resourceURL: NSURL { return NSURL(string: _image.url!)! }
//    
//    ///
//    /// 获取资源
//    ///
//    /// - parameter closure: 结果回调
//    ///
//    func resource(closure: SIMChatResult<AnyObject, NSError> -> Void) {
//        let path = NSTemporaryDirectory() + "tim_\(identifier).jpg"
//        _image.getImage(path,
//            succ: {
//                if let image = UIImage(contentsOfFile: path) {
//                    closure(.Success(image))
//                } else {
//                    closure(.Failure(NSError(domain: "Load Image Failure", code: -1, userInfo: nil)))
//                }
//            },
//            fail: { code, error in
//                closure(.Failure(NSError(domain: error, code: Int(code), userInfo: nil)))
//        })
//    }
//    
//    private var _image: TIMImage
//}
//
//extension TIMElem {
//    func toSIMChatMessageContent() -> SIMChatMessageBody {
//        switch self {
//        case let text as TIMTextElem:
//            return SIMChatBaseMessageTextContent(content: text.text)
//        case let sound as TIMSoundElem:
//            let resource = ExTIMAudioResource(sound: sound)
//            return SIMChatBaseMessageAudioContent(origin: resource, duration: Double(sound.second))
//        case let image as TIMImageElem:
//            var tmp: CGSize?
//            var originResource: SIMChatResourceProtocol?
//            var thumbnailResource: SIMChatResourceProtocol?
//            
//            image.imageList.forEach {
//                guard let image = $0 as? TIMImage else {
//                    return
//                }
//                switch image.type {
//                case .ORIGIN, .LARGE:
//                    tmp = CGSizeMake(CGFloat(image.width), CGFloat(image.height))
//                    originResource = ExTIMImageResource(image: image)
//                case .THUMB:
//                    thumbnailResource = ExTIMImageResource(image: image)
//                }
//            }
//            
//            guard let size = tmp, origin = originResource else {
//                return ExUnknowContent()
//            }
//            
//            return SIMChatBaseMessageImageContent(origin: origin, thumbnail: thumbnailResource, size: size)
//        default:
//            return SIMChatBaseMessageTextContent(content: "")
//        }
//    }
//}
//
//extension SIMChatMessageBody {
//    func toTIMElem() -> TIMElem {
//        switch self {
//        case let text as SIMChatBaseMessageTextContent:
//            let e = TIMTextElem()
//            e.text = text.content
//            return e
//        case let image as SIMChatBaseMessageImageContent:
//            let e = TIMImageElem()
//            e.path = image.localURL!.path
//            return e
//        case let sound as SIMChatBaseMessageAudioContent:
//            let e = TIMSoundElem()
//            e.data = NSData(contentsOfURL: sound.localURL!)
//            e.second = Int32(sound.duration)
//            return e
//        default:
//            return TIMElem()
//        }
//    }
//}
