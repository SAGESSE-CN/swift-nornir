//
//  ViewController.swift
//  SIMChatExample
//
//  Created by sagesse on 2/2/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import SIMChat

public class ExUser: SIMChatBaseUser {
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

class ExConversationViewController: UITableViewController {

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

    let m = ExChatManager()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        srand(UInt32(time(nil)))
        
        let s = ExUser(identifier: NSUUID().UUIDString, name: "self", gender: .Male, portrait: nil)
        let o = ExUser(identifier: NSUUID().UUIDString, name: "other", gender: .Female, portrait: nil)
        
        m.login(s).response { _ in
            // 登录完成
            let cv = self.m.conversation(o) as! ExChatConversation
            let cc = ExChatViewController(conversation: cv)
            
            dispatch_async(dispatch_get_main_queue()) {
                // 显示
                self.navigationController?.pushViewController(cc, animated: true)
            }
        }
    }
}
