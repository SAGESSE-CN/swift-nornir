//
//  SAMVideoPlayerViewController.swift
//  SAMedia
//
//  Created by sagesse on 28/10/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit
import SIMChat

class SAMVideoPlayerViewController: UIViewController, SAMPlayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        player = SAMVideoPlayer(contentsOf: url)
        player?.delegate = self
        
        playView.player = player
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func play() {
        
        player?.play()
    }
    @IBAction func pause() {
        
        player?.pause()
    }
    @IBAction func stop() {
        
        player?.stop()
    }
    
    @IBAction func progressDidChange(_ sender: AnyObject) {
        
        print(playProgressView.value)
        
//        if player?.status.isPlayed ?? false {
//            player?.play(at: TimeInterval(playProgressView.value))
//        } else {
            player?.seek(to: TimeInterval(playProgressView.value))
//        }
    }
    
    func player(shouldPreparing player: SAMPlayerProtocol) -> Bool {
        print(#function)
        return true
    }
    func player(didPreparing player: SAMPlayerProtocol) {
        print(#function)
        
        playProgressView.maximumValue = Float(player.duration)
        playProgressView.value = Float(player.currentTime)
        
        loadProgressView.progress = Float(player.loadedTime) / max(playProgressView.maximumValue, 0)
    }
    
    func player(shouldPlaying player: SAMPlayerProtocol) -> Bool {
        print(#function)
        return true
    }
    func player(didPlaying player: SAMPlayerProtocol) {
        print(#function)
    }
    
    func player(didPause player: SAMPlayerProtocol) {
        print(#function)
    }
    
    func player(didStop player: SAMPlayerProtocol) {
        print(#function)
    }
    func player(didInterruption player: SAMPlayerProtocol) {
        print(#function)
    }
    func player(didStalled player: SAMPlayerProtocol) {
        print(#function)
    }
    
    func player(shouldRestorePlaying player: SAMPlayerProtocol) -> Bool {
        print(#function)
        return true
    }
    func player(didRestorePlaying player: SAMPlayerProtocol) {
        print(#function)
    }
    
    func player(didChange player: SAMPlayerProtocol, currentTime time: TimeInterval) {
        playProgressView.setValue(Float(time), animated: true)
    }
    
    func player(didChange player: SAMPlayerProtocol, loadedTime time: TimeInterval) {
        let progress = Float(time) / max(playProgressView.maximumValue, 0)
        
        loadProgressView.setProgress(progress, animated: true)
    }
    
    func player(didFinishPlaying player: SAMPlayerProtocol, successfully flag: Bool) {
        print(#function)
    }
    
    func player(didOccur player: SAMPlayerProtocol, error: Error?) {
        print(#function)
    }
    

    var player: SAMVideoPlayer?
    
    @IBOutlet weak var playView: SAMVideoPlayerView!

    @IBOutlet weak var playProgressView: UISlider!
    @IBOutlet weak var loadProgressView: UIProgressView!
}
