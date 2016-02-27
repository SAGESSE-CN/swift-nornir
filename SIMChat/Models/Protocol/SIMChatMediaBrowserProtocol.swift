//
//  SIMChatMediaBrowserProtocol.swift
//  SIMChat
//
//  Created by sagesse on 2/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public protocol SIMChatMediaBrowserDelegate: class {
}

public protocol SIMChatMediaBrowserProtocol: class {
    func browse(URL: NSURL)
    func close()
    
    func show(fromView: UIView)
    //func showInViewController(viewController: UIViewController, animated: Bool)
}
