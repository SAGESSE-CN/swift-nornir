//
//  TXPProgressViewController.swift
//  Example
//
//  Created by SAGESSE on 11/2/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import SAPhotos

class TXPProgressViewController: UIViewController {

    @IBAction func valueChanged(_ sender: Any) {
        _logger.trace(slider.value)
        
        
        stepper.value = Double(slider.value)
        progressView.progress = Double(slider.value)
        progressView2.progress = Double(slider.value)
    }
    @IBAction func stepChanged(_ sender: Any) {
        _logger.trace(stepper.value)
        
        
        slider.setValue(Float(stepper.value), animated: true)
        progressView.setProgress(stepper.value, animated: true)
        progressView2.setProgress(stepper.value, animated: true)
    }
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var stepper: UIStepper!
    
    @IBOutlet weak var progressView: SAPBrowseableProgressView!
    @IBOutlet weak var progressView2: SAPBrowseableProgressView!
}
