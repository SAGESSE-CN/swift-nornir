//
//  ViewController.swift
//  Ubiquity-Example
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import Ubiquity

class ViewController: UIViewController, UIActionSheetDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func show(_ sender: Any) {
        let sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
//        
//        sheet.addButton(withTitle: "Browser")
//        sheet.addButton(withTitle: "Picker")
//        sheet.addButton(withTitle: "Editor")
//        
//        sheet.show(in: self.view)
        
        // skip
        actionSheet(sheet, clickedButtonAt: 1)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        guard buttonIndex != actionSheet.cancelButtonIndex else {
            return
        }
        switch buttonIndex {
        case 1:
            let browser = Ubiquity.Browser()
            present(browser, animated: true, completion: nil)
            
//        case 2:
//            let browser = Ubiquity.Picker()
//            present(browser, animated: true, completion: nil)
//            
//        case 3:
//            let browser = Ubiquity.Picker()
//            present(browser, animated: true, completion: nil)
//            
        default:
            break
        }
    }
}

