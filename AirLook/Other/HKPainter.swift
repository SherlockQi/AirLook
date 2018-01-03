//
//  HKPainter.swift
//  AirLook
//
//  Created by HeiKki on 2018/1/2.
//  Copyright © 2018年 XiaQi. All rights reserved.
//

import UIKit
import SceneKit

class HKPainter: NSObject {
    
    var model:HKWeiBoModel?
    var senceNode:SCNBox?
    var contentImage:UIImage?
    
    
    func drawImage(model:HKWeiBoModel,weiboBox:SCNBox){
        self.model = model
        self.senceNode = weiboBox
        self.loadIcon()
    }
    
    func loadIcon(){

        let url = URL(string: (model?.user?.profile_image_url!)!)!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil{
                print(error.debugDescription)
            }else{
                let img = UIImage(data:data!)
                print(img!)
                
                
                DispatchQueue.main.async {
                    
                    self.drawBegin(icon: img)
                }
                
            }
        }) 
        dataTask.resume()
    }
    
    
    func drawBegin(icon:UIImage?){
        let whiteColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let imageSize = CGSize(width: 1000, height: 750)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        //获得 图形上下文
        let context = UIGraphicsGetCurrentContext()
        //背景色
        context?.addRect(CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        context?.setFillColor(whiteColor.cgColor)
        context?.fillPath()
        //头像
        icon?.draw(in: CGRect(x: 15, y: 15, width: 200, height: 200))
        //微博名
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let nameColor = UIColor.darkText
        let nameFont = UIFont.systemFont(ofSize: 50)
        let nameAttributes = [NSAttributedStringKey.foregroundColor: nameColor, NSAttributedStringKey.font: nameFont]
        let screen_name:String = self.model?.user?.screen_name ?? ""
        let nameRect = CGRect(x: 230, y: 15, width: 800, height: 80)
        screen_name.draw(with: nameRect, options: option, attributes: nameAttributes, context: nil)
        
        
        //文字
        let color = UIColor.darkText
        let font = UIFont.systemFont(ofSize: 50)
        let attributes = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font]
        context?.setFillColor(UIColor.red.cgColor)
        let text = self.model?.text ?? ""
        let rect:CGRect = text.boundingRect(with: CGSize(width: 970, height: 500), options: option, attributes: attributes, context: nil)
        let textRect = CGRect(x: 15, y: 230, width: rect.size.width, height: rect.size.height)
        text.draw(with: textRect, options: option, attributes: attributes, context: nil)
        contentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //MARK:test{
        let imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imageView.image = contentImage
        UIApplication.shared.keyWindow?.addSubview(imageView)
        //MARK:test}
        
        let images = [contentImage!,whiteColor,whiteColor,whiteColor,whiteColor,whiteColor] as [Any]
        var materials:[SCNMaterial] = []
        for index in 0..<6 {
            let material = SCNMaterial()
            material.multiply.contents = images[index]
            materials.append(material)
        }
        self.senceNode?.materials = materials
    }
}
