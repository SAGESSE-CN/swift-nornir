//
//  SAMAudioPlayerViewController.swift
//  SAMedia
//
//  Created by sagesse on 27/10/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit
import SIMChat

class SAMAudioPlayerViewController: UIViewController, SAMAudioPlayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let mp3 = Bundle.main.url(forResource: "m1", withExtension: "m4a") else {
            return
        }
        playItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(play(_:)))
        pauseItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(pause(_:)))
        stopItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stop(_:)))
        
        player = try? SAMAudioPlayer(contentsOf: mp3)
        player?.delegate = self
        //player?.prepareToPlay()
        
        navigationItem.rightBarButtonItems = [playItem]
    }
    
    var playItem: UIBarButtonItem!
    var pauseItem: UIBarButtonItem!
    var stopItem: UIBarButtonItem!
    
    func play(_ sender: AnyObject) {
        
        player?.play()
    }
    func pause(_ sender: AnyObject) {
        
        player?.pause()
    }
    func stop(_ sender: AnyObject) {
        
        player?.stop()
    }
    

    func audioPlayer(shouldPreparing audioPlayer: SAMAudioPlayer) -> Bool {
        print(#function)
        return true
    }
    func audioPlayer(didPreparing audioPlayer: SAMAudioPlayer) {
        print(#function)
    }
    
    func audioPlayer(shouldPlaying audioPlayer: SAMAudioPlayer) -> Bool {
        print(#function)
        return true
    }
    func audioPlayer(didPlaying audioPlayer: SAMAudioPlayer) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [pauseItem, stopItem]
    }
    
    func audioPlayer(didPause audioPlayer: SAMAudioPlayer) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [playItem, stopItem]
    }
    
    func audioPlayer(didStop audioPlayer: SAMAudioPlayer) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [playItem]
    }
    func audioPlayer(didInterruption audioPlayer: SAMAudioPlayer) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [playItem, stopItem]
    }
    
    func audioPlayer(didFinishPlaying audioPlayer: SAMAudioPlayer, successfully flag: Bool) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [playItem]
    }
    
    func audioPlayer(didOccur audioPlayer: SAMAudioPlayer, error: Error?) {
        print(#function)
        
        navigationItem.rightBarButtonItems = [playItem]
    }
    
    var player: SAMAudioPlayer?
}
