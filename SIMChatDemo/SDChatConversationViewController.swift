//
//  SDChatConversationViewController.swift
//  SIMChat
//
//  Created by sagesse on 10/4/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SDChatUser : NSObject, SIMChatUserProtocol {
    init(identifier: String, name: String?, portrait: String?, gender: SIMChatUserGender) {
        self.name = name
        self.identifier = identifier
        self.portrait = portrait
        super.init()
    }
    
    /// 用户名
    var name: String?
    /// 用户头像
    var portrait: String?
    /// 用户唯一标识符
    var identifier: String = NSUUID().UUIDString
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let m = SDChatManager()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        srand(UInt32(time(nil)))
        
        let s = SDChatUser(identifier: "self", name: "self", portrait: nil, gender: .Male)
        let o = SDChatUser(identifier: "other", name: "other", portrait: nil, gender: .Female)

        //
        m.login(s, finish: nil)
        // ;
        let cv = m.conversationWithRecver(o)
        let cc = SDChatViewController(conversation: cv)
        
//        for _ in 0 ..< 20 {
//            let m = SIMChatMessage(SIMChatMessageContentImage(origin: UIImage(named: "t1.jpg")))
//            cv.messages.append(m)
//        }
        
        // 显示
        self.navigationController?.pushViewController(cc, animated: true)
    }
}

