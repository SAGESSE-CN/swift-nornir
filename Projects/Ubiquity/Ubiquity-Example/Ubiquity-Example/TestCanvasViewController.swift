//
//  TXPContainerViewController.swift
//  Example
//
//  Created by SAGESSE on 03/11/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
@testable import Ubiquity

class TestCanvasViewController: UIViewController, Ubiquity.CanvasViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
        
        //imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 240)
        imageView.image = UIImage(named: "t1_g.jpg")
        imageView.frame = .init(x: 0, y: 0, width: 1600, height: 1200)
        
        containerView.delegate = self
        //containerView.contentSize = CGSize(width: 240, height: 180)
        containerView.contentSize = CGSize(width: 1600, height: 1200)
        containerView.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        
        tap.numberOfTapsRequired = 2
        
        containerView.addGestureRecognizer(tap)
    }
    
    func tapHandler(_ sender: UITapGestureRecognizer) {
        
        let pt = sender.location(in: imageView)
        
        if containerView.zoomScale != containerView.minimumZoomScale {
            // min
            containerView.setZoomScale(containerView.minimumZoomScale, at: pt, animated: true)
            
        } else {
            // max
            containerView.setZoomScale(containerView.maximumZoomScale, at: pt, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in canvasView: CanvasView) -> UIView? {
        return imageView
    }
    
    func canvasViewShouldBeginRotationing(_ canvasView: CanvasView, with view: UIView?) -> Bool {
        return true
    }
    func canvasViewDidEndRotationing(_ canvasView: CanvasView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        imageView.image = imageView.image?.withOrientation(orientation)
        
    }
    
    lazy var imageView: UIImageView = UIImageView()
    
    
    @IBOutlet weak var containerView: Ubiquity.CanvasView!
}
