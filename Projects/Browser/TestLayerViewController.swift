//
//  TestLayerViewController.swift
//  Browser
//
//  Created by sagesse on 07/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class TestLayerViewController: UIViewController {
    
    let mpv = IBOverlayProgressView()
    let mpv2 = IBOverlayProgressView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mpv.frame = CGRect(x: 40, y: 40, width: 240, height: 240)
        mpv.radius = 100
        mpv2.frame = CGRect(x: mpv.frame.maxX, y: mpv.frame.maxY - 22, width: 22, height: 22)
        mpv2.radius = mpv2.frame.width / 2 - 3
        
        view.addSubview(mpv)
        view.addSubview(mpv2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func b1(_ sender: AnyObject) {
        updateProgress(min(max(mpv.progress - 0.35, -1), 1))
    }
    @IBAction func b2(_ sender: AnyObject) {
        updateProgress(min(max(mpv.progress + 0.35, -1), 1))
    }
    
    @IBAction func progressDidChange(_ sender: UISlider) {
        mpv.progress = Double(sender.value)
        mpv2.progress = mpv.progress
    }
    @IBAction func radiusDidChange(_ sender: UISlider) {
        mpv.radius = CGFloat(sender.value)
        //mpv2.radius = mlayer.radius
    }

    func updateProgress(_ progress: Double) {
        
        let oldValue = self.mpv.progress
        let newValue = progress
        
        let target = false
        
        // show if need
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            guard newValue != oldValue || !target else {
                return
            }
            self.mpv.alpha = 1
        }, completion: { isFinish in
            var delay: TimeInterval = 0.3
            // set if need
            if newValue == oldValue {
                delay = 0
            }
            self.mpv.setProgress(newValue, animated: true)
            self.mpv2.setProgress(newValue, animated: true)
            // hidden if need
            UIView.animate(withDuration: 0.25, delay: delay, options: .curveLinear, animations: {
                guard self.mpv.progress > 0.999999 || target else {
                    return
                }
                self.mpv.alpha = 0
            }, completion: { isFinish in
                guard isFinish, self.mpv.progress > 0.999999 || target else {
                    return
                }
                self.mpv.setProgress(0, animated: false)
                self.mpv2.setProgress(0, animated: false)
            })
        })
        
    }
}
