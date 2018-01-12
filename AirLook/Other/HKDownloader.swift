//
//  HKDownloader.swift
//  AirLook
//
//  Created by HeiKki on 2018/1/12.
//  Copyright © 2018年 XiaQi. All rights reserved.
//

import UIKit


class HKDownloader: NSObject {
    //下载图片
    class func loadImage(url:String,completion: @escaping (_ image : UIImage)->()) -> () {
        let url = URL(string: url)
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil{
                print(error.debugDescription)
            }else{
                if let img = UIImage(data:data!){
                    DispatchQueue.main.async {
                        completion(img)
                    }
                }
            }
        })
        dataTask.resume()
    }
}


