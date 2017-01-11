//
//  ExContainterViewController.swift
//  SIMChatExample
//
//  Created by sagesse on 25/10/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import SAPhotos

class ExContainterViewController: UIViewController, SPContainterViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 240)
        imageView.image = UIImage(named: "t1_g.jpg")
        
        containterView.delegate = self
        //containterView.contentSize = CGSize(width: 240, height: 180)
        containterView.contentSize = CGSize(width: 1600, height: 1200)
        containterView.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        
        tap.numberOfTapsRequired = 2
        
        containterView.addGestureRecognizer(tap)
    }
    
    func tapHandler(_ sender: UITapGestureRecognizer) {
        
        let pt = sender.location(in: imageView)
        
        if containterView.zoomScale != containterView.minimumZoomScale {
            // min
            containterView.setZoomScale(containterView.minimumZoomScale, at: pt, animated: true)
            
        } else {
            // max
            containterView.setZoomScale(containterView.maximumZoomScale, at: pt, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in containterView: SPContainterView) -> UIView? {
        return imageView
    }
    
    func containterViewShouldBeginRotationing(_ containterView: SPContainterView, with view: UIView?) -> Bool {
        return true
    }
    func containterViewDidEndRotationing(_ containterView: SPContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        imageView.image = imageView.image?.withOrientation(orientation)
    }
    
    lazy var imageView: UIImageView = UIImageView()
        

    @IBOutlet weak var containterView: SPContainterView!
}
