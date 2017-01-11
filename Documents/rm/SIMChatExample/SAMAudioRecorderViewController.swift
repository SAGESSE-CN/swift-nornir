//
//  SAMAudioRecorderViewController.swift
//  SAMedia
//
//  Created by sagesse on 27/10/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit
import SIMChat

class SAMAudioRecorderViewController: UIViewController, SAMAudioRecorderDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let url = URL(fileURLWithPath: NSTemporaryDirectory() + "a.m3a")
        
        recorder = try? SAMAudioRecorder(contentsOf: url)
        recorder?.delegate = self
        
        player = try? SAMAudioPlayer(contentsOf: url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func record(_ sender: AnyObject) {
        
        recorder?.record()
    }
    @IBAction func pause(_ sender: AnyObject) {
        recorder?.pause()
    }
    @IBAction func stop(_ sender: AnyObject) {
        recorder?.stop()
    }
    
    @IBAction func startPlay(_ sender: AnyObject) {
        player?.play()
    }
    @IBAction func stopPlay(_ sender: AnyObject) {
        player?.stop()
    }
    
    func audioRecorder(shouldPreparing audioRecorder: SAMAudioRecorder) -> Bool {
        print(#function)
        return true
    }
    func audioRecorder(didPreparing audioRecorder: SAMAudioRecorder) {
        print(#function)
    }
    
    func audioRecorder(shouldRecording audioRecorder: SAMAudioRecorder) -> Bool {
        print(#function)
        return true
    }
    func audioRecorder(didRecording audioRecorder: SAMAudioRecorder) {
        print(#function)
    }
    
    func audioRecorder(didPause audioRecorder: SAMAudioRecorder) {
        print(#function)
    }
    
    func audioRecorder(didStop audioRecorder: SAMAudioRecorder) {
        print(#function)
    }
    func audioRecorder(didInterruption audioRecorder: SAMAudioRecorder) {
        print(#function)
    }
    
    func audioRecorder(didFinishRecording audioRecorder: SAMAudioRecorder, successfully flag: Bool) {
        print(#function, flag)
    }
    
    func audioRecorder(didOccur audioRecorder: SAMAudioRecorder, error: Error?) {
        print(#function, error)
    }

    var recorder: SAMAudioRecorder?
    var player: SAMAudioPlayer?
}
