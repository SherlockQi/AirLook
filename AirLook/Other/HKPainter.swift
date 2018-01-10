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
    var senceNode:HKWeiBoNode?
    var contentImage:UIImage?
    
    
    func drawImage(model:HKWeiBoModel,weiboBox:HKWeiBoNode){
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
                DispatchQueue.main.async {
                    self.drawBegin(icon: img)
                }
            }
        }) 
        dataTask.resume()
    }
    
    func loadImage(){

        if let urlStr = model?.pic_urls?.first{
            print(urlStr)

            let url = URL(string: urlStr)!
            let request = URLRequest(url: url)
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                if error != nil{
                    print(error.debugDescription)
                }else{
                    let img = UIImage(data:data!)
                    DispatchQueue.main.async {
//                        self.drawBegin(icon: img)
                        print(urlStr)
                    }
                }
            })
            dataTask.resume()
        }
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
        icon?.draw(in: CGRect(x: 25, y: 25, width: 200, height: 200))
        //微博名
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let nameColor = UIColor.darkText
        let nameFont = UIFont(name: "PingFangSC-Semibold",size: 50)!
        let nameAttributes = [NSAttributedStringKey.foregroundColor: nameColor, NSAttributedStringKey.font: nameFont]
        let screen_name:String = self.model?.user?.screen_name ?? ""
        let nameRect = CGRect(x: 250, y: 25, width: 800, height: 80)
        screen_name.draw(with: nameRect, options: option, attributes: nameAttributes, context: nil)
        //时间
        let timeOption = NSStringDrawingOptions.usesLineFragmentOrigin
        let timeColor = UIColor.darkGray
        let timeFont = UIFont(name: "PingFangSC-Regular",size: 40)!
        let timeAttributes = [NSAttributedStringKey.foregroundColor: timeColor, NSAttributedStringKey.font: timeFont]
        let time:String =  self.model?.created_at ?? ""
        let tRect:CGRect = time.boundingRect(with: CGSize(width: 970, height: 500), options: option, attributes: timeAttributes, context: nil)
        let timeRect = CGRect(x: 250, y: 140, width: tRect.size.width, height: 80)
        time.draw(with: timeRect, options: timeOption, attributes: timeAttributes, context: nil)
        //来源
        let sourceOption = NSStringDrawingOptions.usesLineFragmentOrigin
        let sourceColor = UIColor(red: 80/256.0, green: 182/256.0, blue: 244/256.0, alpha: 1)
        let sourceFont = UIFont(name: "PingFangSC-Semibold",size: 40)!
        let sourceAttributes = [NSAttributedStringKey.foregroundColor: sourceColor, NSAttributedStringKey.font: sourceFont]
        let source:String =  self.model?.source ?? ""
        let sourceRect = CGRect(x: timeRect.maxX + 15, y: 140, width: 500, height: 80)
        source.draw(with: sourceRect, options: sourceOption, attributes: sourceAttributes, context: nil)
        //文字
        let color = UIColor.darkText
        let font =  UIFont(name: "GillSans-Italic",size: 50)!
        let attributes = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font]
        context?.setFillColor(UIColor.red.cgColor)
        let text = self.model?.text ?? ""
        let rect:CGRect = text.boundingRect(with: CGSize(width: 950, height: 500), options: option, attributes: attributes, context: nil)
        let textRect = CGRect(x: 25, y: 230, width: rect.size.width, height: rect.size.height)
        text.draw(with: textRect, options: option, attributes: attributes, context: nil)
        
        //图片

        loadImage()
        
        
        
        
        
        //转发
        
        
        if ((self.model?.retweeted_status) != nil)  {
            
            
            
            let zfContext = UIGraphicsGetCurrentContext()
            let zfBackRect = CGRect(x: 25, y:textRect.maxY + 25, width: 1000 - 50, height: 600 - rect.maxY - 25)
            zfContext?.addRect(zfBackRect)
            let zfColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.1)
            zfContext?.setFillColor(zfColor.cgColor)
            zfContext?.fillPath()
            
            let zfTextcolor = UIColor.darkText
            let zfFont =  UIFont(name: "GillSans-Italic",size: 45)!
            let zfAttributes = [NSAttributedStringKey.foregroundColor: zfTextcolor, NSAttributedStringKey.font: zfFont]
            
            
            if let zfText = self.model?.retweeted_status?.text{
                let zfRect:CGRect = zfText.boundingRect(with: CGSize(width: 920, height: 500), options: option, attributes: timeAttributes, context: nil)
                let zfR = CGRect(x: zfBackRect.minX + 15, y: zfBackRect.minY + 15, width: zfRect.size.width, height: zfRect.size.height)
                zfText.draw(with: zfR, options: sourceOption, attributes: zfAttributes, context: nil)
            }
        }
        
        
        
        
        
        contentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        
        let images = [contentImage!,whiteColor,whiteColor,whiteColor,whiteColor,whiteColor] as [Any]
        var materials:[SCNMaterial] = []
        for index in 0..<6 {
            let material = SCNMaterial()
            material.multiply.contents = images[index]
            materials.append(material)
        }
//        self.senceNode?.materials = materials
        self.senceNode?.geometry?.materials = materials
    }
}
