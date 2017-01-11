//
//  SAIAudioEffect.swift
//  SAC
//
//  Created by SAGESSE on 9/19/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal enum SAIAudioEffectType: Int {
    
    case original = 0
    case ef1 = 1 // 萝莉
    case ef2 = 2 // 大叔
    case ef3 = 3 // 惊悚
    case ef4 = 4 // 搞怪
    case ef5 = 5 // 空灵
}

internal protocol SAIAudioEffectDelegate: NSObjectProtocol {
    
    func audioEffect(_ audioEffect: SAIAudioEffect, shouldStartProcessAt url: URL) -> Bool
    func audioEffect(_ audioEffect: SAIAudioEffect, didStartProcessAt url: URL)
    
    func audioEffect(_ audioEffect: SAIAudioEffect, didFinishProcessAt url: URL)
    func audioEffect(_ audioEffect: SAIAudioEffect, didErrorOccur error: NSError)
}

internal class SAIAudioEffect: NSObject {
    
    func stop() {
    }
    
    func process(at url: URL) {
        guard delegate?.audioEffect(self, shouldStartProcessAt: url) ?? true else {
            return
        }
        delegate?.audioEffect(self, didStartProcessAt: url)
        
        // 如果是原声, 直接返回不需要做任何处理
        guard type != .original else {
            delegate?.audioEffect(self, didFinishProcessAt: url)
            return
        }
        let nurl = url.appendingPathExtension("\(type)")
        // 如果己经处理过了, 直接返回不需要做额外处理
        if let dst = lastDestURL, lastSrcURL == url {
            delegate?.audioEffect(self, didFinishProcessAt: dst)
            return
        }
        // 开始处理
        process(from: url, to: nurl) {
            if let err = $1 {
                self.lastSrcURL = url
                self.lastDestURL = nil
                self.delegate?.audioEffect(self, didErrorOccur: err)
            } else {
                self.lastSrcURL = url
                self.lastDestURL = $0
                self.delegate?.audioEffect(self, didFinishProcessAt: $0)
            }
        }
    }
    
    func process(from srcURL: URL, to destURL: URL, clouser: @escaping (URL, NSError?) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(3)) {
            let fm = FileManager.default
            
            // TODO: 音频变声处理
            _ = try? fm.removeItem(at: destURL)
            _ = try? fm.copyItem(at: srcURL, to: destURL)
            
            DispatchQueue.main.async {
                clouser(destURL, nil)
            }
        }
    }
    
    func clearCache() {
        lastSrcURL = nil
        lastDestURL = nil
    }
    
    var type: SAIAudioEffectType
    weak var delegate: SAIAudioEffectDelegate?
    
    var title: String? {
        if type.rawValue < _titles.count {
            return _titles[type.rawValue]
        }
        return nil
    }
    var image: UIImage? {
        if let image = _image {
            return image
        }
        let image = UIImage.sai_init(named: "keyboard_audio_simulate_effect_\(type.rawValue)")
        _image = image
        return image
    }
    
    // 最后一次处理的文件
    var lastSrcURL: URL?
    var lastDestURL: URL?
    
    private var _image: UIImage??
    private lazy var _titles: [String] = [
        "原声",
        "萝莉",
        "大叔",
        "惊悚",
        "搞怪",
        "空灵",
    ]
    
    init(type: SAIAudioEffectType) {
        self.type = type
        super.init()
    }
}
