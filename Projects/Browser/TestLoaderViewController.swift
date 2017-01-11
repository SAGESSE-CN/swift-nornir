//
//  TestLoaderViewController.swift
//  Browser
//
//  Created by sagesse on 22/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class TestLoaderViewController: UIViewController, IBAssetResourceLoaderDelegate {
    
    lazy var asset = IBAsset()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        asset.resourceLoader.delegate = self

        asset.loadValuesAsynchronously(for: .init(version: .thumbnail, targetSize: .init(width: 80, height: 80))) { v, e in
            // 显示 or 处理错误 or 进度通知?
            print("\(v)", "\(e)")
        }
        asset.loadValuesAsynchronously(for: .init(version: .large, targetSize: .init(width: 320, height: 568))) { v, e in
            // 显示 or 处理错误 or 进度通知?
            print("\(v)", "\(e)")
        }
        asset.loadValuesAsynchronously(for: .init(version: .original, targetSize: .zero)) { v, e in
            // 显示 or 处理错误 or 进度通知?
            print("\(v)", "\(e)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func resourceLoader(_ resourceLoader: IBAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: IBAssetResourceLoadingRequest) -> Bool {
        // v1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            loadingRequest.respond(with: "xx")
            loadingRequest.progress(with: 0.9)
            loadingRequest.finishLoading()
            //loadingRequest.finishLoading(wiht: xxx)
        })
        
        logger.debug()
        return true
    }
    func resourceLoader(_ resourceLoader: IBAssetResourceLoader, didCancel loadingRequest: IBAssetResourceLoadingRequest) {
        logger.debug()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
