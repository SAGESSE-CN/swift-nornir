//
//  TestLayoutViewController.swift
//  Browser
//
//  Created by sagesse on 11/14/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class TestLayoutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func x2(_ sender: Any) {
        
        var nframe = self.view.frame
        
        nframe.size.height = nframe.size.width * CGFloat(x3.value)
        nframe.origin.y = (self.view.frame.height - nframe.height) / 2
        
        x1.frame = nframe
    }
    
    @IBOutlet weak var x3: UISlider!
    @IBOutlet weak var x1: BrowseView!
}
