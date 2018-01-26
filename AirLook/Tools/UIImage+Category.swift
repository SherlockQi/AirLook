//
//  UIImage+Category.swift
//  AirLook
//
//  Created by HeiKki on 2018/1/10.
//  Copyright © 2018年 XiaQi. All rights reserved.
//

import Foundation

extension UIImage {
    //截取图片一部分
    func snip(rect:CGRect) -> UIImage {
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: 1/self.scale, orientation: self.imageOrientation)
        return image
    }
    
}
