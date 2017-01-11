//
//  TestBadgeViewController.swift
//  Browser
//
//  Created by sagesse on 20/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class TestBadgeViewController: UIViewController {
    
    @IBOutlet weak var bar: IBBadgeBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        bar.leftBarItems = [.init(title: "99:99")]
        bar.rightBarItems = [.init(style: .loading)]
    }
}
