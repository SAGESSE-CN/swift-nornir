//
//  SAIAudioStatus.swift
//  SAC
//
//  Created by SAGESSE on 9/19/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal enum SAIAudioStatus: CustomStringConvertible {
    
    case none
    case waiting
    case recording
    case processing
    case processed
    case playing
    case error(String)
    
    var isNone: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
    var isWaiting: Bool {
        switch self {
        case .waiting: return true
        default: return false
        }
    }
    var isRecording: Bool {
        switch self {
        case .recording: return true
        default: return false
        }
    }
    var isProcessing: Bool {
        switch self {
        case .processing: return true
        default: return false
        }
    }
    var isProcessed: Bool {
        switch self {
        case .processed: return true
        default: return false
        }
    }
    var isPlaying: Bool {
        switch self {
        case .playing: return true
        default: return false
        }
    }
    var isError: Bool {
        switch self {
        case .error(_): return true
        default: return false
        }
    }
    
    var description: String {
        switch self {
        case .none: return "None"
        case .waiting: return "Waiting"
        case .recording: return "Recording"
        case .processing: return "Processing"
        case .processed: return "Processed"
        case .playing: return "Playing"
        case .error(let e): return "Error(\(e))"
        }
    }
}


