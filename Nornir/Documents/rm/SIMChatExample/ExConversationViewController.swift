//
//  ViewController.swift
//  SIMChatExample
//
//  Created by sagesse on 2/2/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import SIMChat
import MMProgressHUD


class ExConversationViewController: UITableViewController {
    
    lazy var manager: SIMChatManager = SIMChatBaseManager()
    
    lazy var user2: SIMChatUserProtocol = {
        let identifier = "admin"
        let sign = "eJx1js1Og0AYRfc8BWFbI0MHOtbEBa1jQqRUS8HuJjA-zRfS6QTGgDG*uxWbyMa7PSc599NxXdfbp-ltxfn5XVtmP4z03HvXwyHG3s0fNwYEqyzDrRh5EKLLSBBEE0sOBlrJKmVl*2tFZHH3I6KJBUJqCwquTiVOoCe4Ew0bc-93OjiOcEOLdfI0A973KG123ZuJ5-kqqUNND5tmnq3T-rE02y1o7S81L2OgsSbJzEfIr3fFXlF1jF*ecz1kFPWULnBWcDWsDiU58-r1YZK0cJLXQxEJEMIYec6X8w07oFbB"
       
        return SIMChatBaseUser(identifier: identifier)
        //return ExUser(identifier: identifier, sign: sign, gender: .female)
    }()
    lazy var user1: SIMChatUserProtocol = {
        let identifier = "sagesse"
        let sign = "eJx1zk9PgzAYx-E7r6LptUbpgMFMPCDpMv*QQIREvTSlFHicg0q7qTG*dxWXyMXn*v0kv*fDQQjh4vbuVEg57HvL7btWGJ0j7Pmeh0-*utZQc2G5N9ZTp777fSGlwUypNw2j4qKxavxVQbiMfqA7U1Cr3kIDR2NEq4xRM2DqLZ8G-18y0E4xZWVyxWjJQsqSvKvI5S49YxZW*rUYsjyXCSkzf7vRskgfBr2JgcVAukP5HIu8XNw8dcXqEaoR1lkr*2g5VkCC6*ZAXtb79n64mE1a2KnjQ0FI3UXkudj5dL4AOi1Ydg__"
        
        return SIMChatBaseUser(identifier: identifier)
        //return ExUser(identifier: identifier, sign: sign, gender: .male)
    }()
    
    var own: SIMChatUserProtocol {
        if UIDevice.current.name == "iPhone Simulator" {
            return user2
        } else {
            return user1
        }
    }
    var other: SIMChatUserProtocol {
        if UIDevice.current.name == "iPhone Simulator" {
            return user1
        } else {
            return user2
        }
    }
    
    @IBAction func onPL(_ sender: AnyObject) {
        
//        let picker = SAPhotoPicker()
//        self.present(picker, animated: true) {
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //srand(UInt32(time(nil)))
        
//        SIMChatMessageBox.ActivityIndicator.begin()
//        
//        manager.login(own) {
//            SIMChatMessageBox.ActivityIndicator.end()
//            if let error = $0.error {
//                SIMChatMessageBox.Alert.error(error)
//                return
//            }
//        }
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var t1: UILabel!
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        guard manager.currentUser != nil else {
////            SIMChatMessageBox.Alert.error("用户未登录")
//            return
//        }
        
        // 和自己聊天
        let vc = SIMChatViewController()
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
