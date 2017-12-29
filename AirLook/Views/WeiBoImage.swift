//
//  WeiBoImage.swift
//  AirLook
//
//  Created by HeiKki on 2017/12/27.
//  Copyright © 2017年 XiaQi. All rights reserved.
//

import UIKit

class WeiBoImage: NSObject {
    
    class func image(model:HKWeiBoModel) -> UIImage {
        let sourceImage = #imageLiteral(resourceName: "whiteImage")
        let imageSize = sourceImage.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        sourceImage.draw(at: CGPoint(x: 0, y: 0))
        //获得 图形上下文
        let context = UIGraphicsGetCurrentContext()
        context?.drawPath(using: .stroke)
        //画 自己想要画的内容
      

        
        let color = UIColor.red
        let font = UIFont.systemFont(ofSize: 30)
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let attributes = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font]
        context?.setFillColor(UIColor.red.cgColor)
        
        let text = model.text ?? ""
        let rect:CGRect = text.boundingRect(with: CGSize(width: 660, height: 1000), options: option, attributes: attributes, context: nil)
        
        text.draw(with: rect, options: option, attributes: attributes, context: nil)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
