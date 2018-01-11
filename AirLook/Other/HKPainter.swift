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
    //    var contentImage:UIImage?
    var iconImage:UIImage?
    
    
    let sizeW:CGFloat = 300
    let sizeH:CGFloat = 300*0.75
    let margin:CGFloat = 8
    
    var  original_End:CGFloat = 0
    
    let nameFont = UIFont(name: "PingFangSC-Semibold",size: 10.0)!
    let timeFont = UIFont(name: "PingFangSC-Regular",size: 9.0)!
    let sourceFont = UIFont(name: "PingFangSC-Semibold",size: 9)!
    let font =  UIFont(name: "GillSans-Italic",size: 12.0)!
    let zfFont =  UIFont(name: "GillSans-Italic",size: 12.0)!
    
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
                self.iconImage = img
                DispatchQueue.main.async {
                    self.drawBegin(icon: img)
                }
            }
        }) 
        dataTask.resume()
    }
    
    func loadImage(){
        if let urlStr = model?.pic_urls?.first{
            let url = URL(string: urlStr)!
            let request = URLRequest(url: url)
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                if error != nil{
                    print(error.debugDescription)
                }else{
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
        
        let imageSize = CGSize(width: sizeW, height: sizeH)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        //获得 图形上下文
        let context = UIGraphicsGetCurrentContext()
        //背景色
        context?.addRect(CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillPath()
        //头像
        let iconRect = CGRect(x: margin, y: margin, width: sizeW*0.2, height: sizeW*0.2)
        icon?.draw(in: iconRect)
        //微博名
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let nameColor = UIColor.darkText
        let nameAttributes = [NSAttributedStringKey.foregroundColor: nameColor, NSAttributedStringKey.font: nameFont]
        let screen_name:String = self.model?.user?.screen_name ?? ""
        let nameRect = CGRect(x: sizeW*0.2+margin*2, y: margin*2, width: sizeW*0.8, height: 80)
        screen_name.draw(with: nameRect, options: option, attributes: nameAttributes, context: nil)
        //时间
        let timeOption = NSStringDrawingOptions.usesLineFragmentOrigin
        let timeColor = UIColor.darkGray
        let timeAttributes = [NSAttributedStringKey.foregroundColor: timeColor, NSAttributedStringKey.font: timeFont]
        let time:String =  self.model?.created_at ?? ""
        let tRect:CGRect = time.boundingRect(with: CGSize(width: sizeW*0.8 - 2*margin, height: 50.0), options: option, attributes: timeAttributes, context: nil)
        let timeRect = CGRect(x: nameRect.origin.x, y: sizeW*0.2-margin*2, width: tRect.size.width, height: 80)
        time.draw(with: timeRect, options: timeOption, attributes: timeAttributes, context: nil)
        
        //来源
        let sourceOption = NSStringDrawingOptions.usesLineFragmentOrigin
        let sourceColor = UIColor(red: 80/256.0, green: 182/256.0, blue: 244/256.0, alpha: 1)
        let sourceAttributes = [NSAttributedStringKey.foregroundColor: sourceColor, NSAttributedStringKey.font: sourceFont]
        let source:String =  self.model?.source ?? ""
        let sourceRect = CGRect(x: timeRect.maxX + margin, y: timeRect.origin.y, width: sizeW*0.8, height: timeRect.size.height)
        source.draw(with: sourceRect, options: sourceOption, attributes: sourceAttributes, context: nil)
        //文字
        let color = UIColor.darkText
        let attributes = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font]
        context?.setFillColor(UIColor.red.cgColor)
        let text = self.model?.text ?? ""
        let rect:CGRect = text.boundingRect(with: CGSize(width: sizeW - 2*margin, height: sizeH), options: option, attributes: attributes, context: nil)
        let textRect = CGRect(x: margin, y: iconRect.maxY + margin, width: rect.size.width, height: rect.size.height)
        text.draw(with: textRect, options: option, attributes: attributes, context: nil)
        original_End = textRect.maxY + 4 * margin
        
        //转发
        if ((self.model?.retweeted_status) != nil)  {
            let zfContext = UIGraphicsGetCurrentContext()
            let zfBackRect = CGRect(x: margin, y:textRect.maxY + margin, width: sizeW - 2*margin, height: sizeH - rect.maxY - 4 * margin)
            zfContext?.addRect(zfBackRect)
            let zfColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.1)
            zfContext?.setFillColor(zfColor.cgColor)
            zfContext?.fillPath()
            
            let zfTextcolor = UIColor.darkText
            let zfAttributes = [NSAttributedStringKey.foregroundColor: zfTextcolor, NSAttributedStringKey.font: zfFont]
            
            if let zfText = self.model?.retweeted_status?.text{
                let zfRect:CGRect = zfText.boundingRect(with: CGSize(width: sizeW - 2 * margin, height: 50.0), options: option, attributes: timeAttributes, context: nil)
                
                let zfR = CGRect(x: zfBackRect.minX + 0.5 * margin, y: zfBackRect.minY + 0.5 * margin, width: zfRect.size.width, height: zfRect.size.height)
                zfText.draw(with: zfR, options: sourceOption, attributes: zfAttributes, context: nil)
            }
        }else{
            //图片
            loadImage()
        }
        
        let contentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.senceNode?.contentImage = contentImage
    }
    
    
    
    func drawOriginal(){
        let imageSize = CGSize(width: sizeW, height: self.original_End)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        //获得 图形上下文
        let context = UIGraphicsGetCurrentContext()
        //背景色
        context?.addRect(CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillPath()
        //头像
        let iconRect = CGRect(x: margin, y: margin, width: sizeW*0.2, height: sizeW*0.2)
        iconImage?.draw(in: iconRect)
        //微博名
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let nameColor = UIColor.darkText
        let nameAttributes = [NSAttributedStringKey.foregroundColor: nameColor, NSAttributedStringKey.font: nameFont]
        let screen_name:String = self.model?.user?.screen_name ?? ""
        let nameRect = CGRect(x: sizeW*0.2+margin*2, y: margin*2, width: sizeW*0.8, height: 80)
        screen_name.draw(with: nameRect, options: option, attributes: nameAttributes, context: nil)
        //时间
        let timeOption = NSStringDrawingOptions.usesLineFragmentOrigin
        let timeColor = UIColor.darkGray
        let timeAttributes = [NSAttributedStringKey.foregroundColor: timeColor, NSAttributedStringKey.font: timeFont]
        let time:String =  self.model?.created_at ?? ""
        let tRect:CGRect = time.boundingRect(with: CGSize(width: sizeW*0.8 - 2*margin, height: 50.0), options: option, attributes: timeAttributes, context: nil)
        let timeRect = CGRect(x: nameRect.origin.x, y: sizeW*0.2-margin*2, width: tRect.size.width, height: 80)
        time.draw(with: timeRect, options: timeOption, attributes: timeAttributes, context: nil)
        
        //来源
        let sourceOption = NSStringDrawingOptions.usesLineFragmentOrigin
        let sourceColor = UIColor(red: 80/256.0, green: 182/256.0, blue: 244/256.0, alpha: 1)
        let sourceAttributes = [NSAttributedStringKey.foregroundColor: sourceColor, NSAttributedStringKey.font: sourceFont]
        let source:String =  self.model?.source ?? ""
        let sourceRect = CGRect(x: timeRect.maxX + margin, y: timeRect.origin.y, width: sizeW*0.8, height: timeRect.size.height)
        source.draw(with: sourceRect, options: sourceOption, attributes: sourceAttributes, context: nil)
        //文字
        let color = UIColor.darkText
        let attributes = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font]
        context?.setFillColor(UIColor.red.cgColor)
        let text = self.model?.text ?? ""
        let rect:CGRect = text.boundingRect(with: CGSize(width: sizeW - 2*margin, height: sizeH), options: option, attributes: attributes, context: nil)
        let textRect = CGRect(x: margin, y: iconRect.maxY + margin, width: rect.size.width, height: rect.size.height)
        text.draw(with: textRect, options: option, attributes: attributes, context: nil)
        //图片
        loadImage()
        let contentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.senceNode?.originalImage = contentImage
    }
}
