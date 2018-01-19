//
//  HKDownloader.swift
//  AirLook
//
//  Created by HeiKki on 2018/1/12.
//  Copyright © 2018年 XiaQi. All rights reserved.
//

import UIKit
import Kingfisher

class HKDownloader: NSObject {
    class func loadImage(url:String){
        let manager = KingfisherManager.shared
        manager.downloader.downloadImage(with: URL(string: url)!)
    }
    class func readWithFile(imageName:String,completion: @escaping (_ image : UIImage)->()) {
        KingfisherManager.shared.downloader.downloadImage(with: URL(string: imageName)!, retrieveImageTask: nil, options: nil, progressBlock: nil) { (image, error, url, data) in
            if image != nil{
                DispatchQueue.main.async {
                    completion(image!)

                    #if DEBUG
//                        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//                        imageView.image = image
//                        UIApplication.shared.keyWindow?.addSubview(imageView)
                    #endif
                }
            }
        }
    }
}
