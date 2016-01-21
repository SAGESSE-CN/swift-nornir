//
//  SDChatConversationViewController.swift
//  SIMChat
//
//  Created by sagesse on 10/4/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit


public class SIMDemoUser: SIMChatBaseUser {
    ///
    /// 初始化
    ///
    public convenience init(
        identifier: String,
        name: String?,
        gender: SIMChatUserGender,
        portrait: String? = nil) {
            self.init(
                identifier: identifier,
                name: name,
                portrait: portrait)
            self.gender = gender
    }
}

class SDChatConversationViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.window?.backgroundColor = UIColor.whiteColor()
    }
    
    @IBOutlet weak var t1: UILabel!
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    let m = SDChatManager()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        srand(UInt32(time(nil)))
        
        let s = SIMDemoUser(identifier: NSUUID().UUIDString, name: "self", gender: .Male, portrait: nil)
        let o = SIMDemoUser(identifier: NSUUID().UUIDString, name: "other", gender: .Female, portrait: nil)
        
        m.login(s).response { _ in
            // 登录完成
            let cv = self.m.conversation(o) as! SDChatConversation
            cv.makeTestData()
            
            let cc = SDChatViewController(conversation: cv)
            
            dispatch_async(dispatch_get_main_queue()) {
                // 显示
                self.navigationController?.pushViewController(cc, animated: true)
            }
        }
    }
}

