//
//  ViewController.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit


class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let s = SIMChatUser(identifier: "self", name: "self", gender: 1, portrait: nil)
        let o = SIMChatUser(identifier: "other", name: "other", gender: 2)
        let m = SIMChatManager.sharedManager
        
        //
        m.login(s, finish: nil)
        // ;
        let cc = SIMChatViewController(conversation: m.conversationWithRecver(o))
        // 显示
        self.navigationController?.pushViewController(cc, animated: true)
    }
}

