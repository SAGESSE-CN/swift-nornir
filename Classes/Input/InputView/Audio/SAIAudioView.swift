//
//  SAIAudioView.swift
//  SAC
//
//  Created by SAGESSE on 9/16/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal protocol SAIAudioViewDelegate: NSObjectProtocol {
    
    func audioView(_ audioView: SAIAudioView, shouldStartRecord url: URL) -> Bool
    func audioView(_ audioView: SAIAudioView, didStartRecord url: URL)
    
    func audioView(_ audioView: SAIAudioView, didComplete url: URL, duration: TimeInterval)
    func audioView(_ audioView: SAIAudioView, didFailure url: URL, duration: TimeInterval)
    
}

internal class SAIAudioView: UICollectionViewCell {
    
    var audioType: SAIAudioType?
    
    weak var delegate: SAIAudioViewDelegate?
}
