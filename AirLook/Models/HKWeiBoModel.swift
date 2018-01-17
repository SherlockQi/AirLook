//
//  HKWeiBoModel.swift
//  AirLook
//
//  Created by HeiKki on 2017/12/28.
//  Copyright © 2017年 XiaQi. All rights reserved.
//

import UIKit
import SwiftyJSON

class HKWeiBoModel: NSObject {
    
    var user:HKUserModel?
    //微博ID
    var id:Int?
    //微博内容文字
    var text:String?
    //微博来源
    var source:String?
    //转发数
    var reposts_count:Int?
    //评论数
    var comments_count:Int?
    //表态数
    var attitudes_count:Int?
    //配图图片
    var pic_urls:[String]?
    //配图图片(中)
    var bmiddle_pic:String?
    //配图图片(原)
    var original_pic:String?
    //时间
    var created_at:String?
    //被转发内容
    var retweeted_status:HKWeiBoModel?
    
    class func modelWithDic(dic:[String : JSON]) -> HKWeiBoModel {
        let model = HKWeiBoModel()
        model.id = dic["id"]?.int
        model.text = dic["text"]?.string
        
        model.reposts_count = dic["reposts_count"]?.int
        model.comments_count = dic["comments_count"]?.int
        model.attitudes_count = dic["attitudes_count"]?.int
        //        model.pic_urls = dic["pic_urls"]?.arrayObject as? [String]
        model.bmiddle_pic = dic["bmiddle_pic"]?.string
        model.original_pic = dic["original_pic"]?.string
        
        if let time = dic["created_at"]?.string{
            model.created_at  = HKTools.weiBoTime(time: time)
        }
        if let source = dic["source"]?.string{
            model.source = HKTools().takeUpSource(source: source)
        }
        
        if let jsonUser =  dic["user"]?.dictionary{
            let userModel = HKUserModel.modelWithDic(dic:jsonUser )
            model.user = userModel
        }
        
        if let retweeted_status =  dic["retweeted_status"]?.dictionary{
            let userModel = HKWeiBoModel.modelWithDic(dic: retweeted_status)
            model.retweeted_status = userModel
        }
        var pic_url_arrM:[String] = NSMutableArray() as! [String]
        print(dic["pic_urls"] ?? "dic[dic[dic[dic[pic_urls] ] ")
        if let pic_url_arr = dic["pic_urls"]?.arrayValue{
            print(pic_url_arr)
            for imageDic in pic_url_arr {
                if let urlDic = imageDic.dictionary{
                    print(urlDic["thumbnail_pic"] ?? "")
                    if let imageStrJson = urlDic["thumbnail_pic"]{
                        if let imageStr = imageStrJson.string{
                            pic_url_arrM.append(imageStr)
                          let largeImageUrl  = imageStr.replacingOccurrences(of: "thumbnail", with: "large")
                            print(largeImageUrl)
                        }
                    }
                }
            }
        }
        model.pic_urls = pic_url_arrM
        return model
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        print("forUndefinedKey:\(key)")
    }
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
        
    }
}

class HKUserModel: NSObject {
    var id:Int?
    //用户昵称
    var screen_name:String?
    var name:String?
    //是否是微博认证用户，即加V用户，true：是，false：否
    var verified:Bool?
    var verified_type:Int?
    var profile_image_url:String?
    
    class func modelWithDic(dic:[String:JSON]) -> HKUserModel {
        let model = HKUserModel()
        model.id = dic["comments_count"]?.int
        model.screen_name = dic["screen_name"]?.string
        model.verified = dic["verified"]?.bool
        model.verified_type = dic["verified_type"]?.int
        model.profile_image_url = dic["profile_image_url"]?.string
        return model
    }
}

