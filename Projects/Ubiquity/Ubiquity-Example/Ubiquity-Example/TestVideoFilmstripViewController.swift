//
//  TestVideoFilmstripViewController.swift
//  Ubiquity-Example
//
//  Created by SAGESSE on 5/8/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation

@testable import Ubiquity

class ScrubberSettings {
    
    var minVideoDuration: TimeInterval = 1.5
    
    var baseVideoWidth: CGFloat = 150
    
    var filmstripAspectRatio: CGFloat = 16 / 9
    
    
    static let settings: ScrubberSettings = .init()
}

class FilmstripView: UIView {
    
    
}

class TestVideoFilmstripViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var asset: AVURLAsset!
    
    var generator: AVAssetImageGenerator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.asset = AVURLAsset(url: URL(string: "http://v4.music.126.net/20170512163709/202e0eceec83d17455634b807176f839/web/cloudmusic/Nzg5MzEyMTY=/b6f37d9ea0b4483212dece4f6ff4620d/a359f74e73667f6ff32fab9340277671.mp4")!)
        
        let setting = ScrubberSettings.settings
        let duration = max(self.asset.duration.seconds, setting.minVideoDuration)
        
        let content = CGSize(width: CGFloat(log2(duration)) * setting.baseVideoWidth, height: 38)
        
        let count = Int(ceil(content.width /  (content.height * setting.filmstripAspectRatio)) + 0.5)
        let item = CGSize(width: content.width / CGFloat(count), height: content.height)
        
        let step = duration / Double(count)
        
        print(duration, step, content)
        print(count, item)
        
        let values = (0 ..< count).map { v -> CMTime in
            let t = Double(v) * step
            return CMTime(seconds: t, preferredTimescale: 90000)
        }
        
        let view = FilmstripView(frame: .init(origin: .zero, size: content))
        
        (0 ..< count).forEach {
            
            let sv = UIImageView(frame: .init(x: item.width * CGFloat($0), y: 0, width: item.width, height: item.height))
            sv.backgroundColor = .random
            sv.contentMode = .scaleAspectFill
            sv.clipsToBounds = true
            view.addSubview(sv)
        }
        
        view.backgroundColor = .red
        scrollView.contentSize = content
        scrollView.addSubview(view)
        
        self.generator = AVAssetImageGenerator(asset: self.asset)
        self.generator.maximumSize = .init(width: item.width * 2, height: item.height * 2)
        
        self.generator.generateCGImagesAsynchronously(forTimes: values as [NSValue]) { rt, image, vt, rs, er in
            guard let index = values.index(where: { $0.seconds == rt.seconds }) else {
                return
            }
            print(CMTimeGetSeconds(rt),CMTimeGetSeconds(vt),rs.rawValue,image,er)
            let sv = view.subviews[index] as? UIImageView
            if let image = image {
                DispatchQueue.main.async {
                    sv?.image = UIImage(cgImage: image, scale: 2, orientation: .up)
                }
            }
        }
        
        
        
//        self.asset.loadValuesAsynchronously(forKeys: [#keyPath(AVURLAsset.duration)]) { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            let duration = CMTimeGetSeconds(self.asset.duration)
//            print(duration)
//        }
        
        //ScrubberSettings.settings.filmstripAspectRatio
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
