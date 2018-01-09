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
        model.pic_urls = dic["pic_urls"]?.arrayObject as? [String]
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
        print("---------")
        print(model.pic_urls ?? "---------")
        print(model.bmiddle_pic ?? "---------")
        print(model.original_pic ?? "---------")

        print("---------")

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






/*** 图片

 "pic_urls" =                 (
 {
 "thumbnail_pic" = "http://wx2.sinaimg.cn/thumbnail/005Axneely1fna7xtrzwij30pv0fp75n.jpg";
 },
 {
 "thumbnail_pic" = "http://wx4.sinaimg.cn/thumbnail/005Axneely1fna7xh4pbnj30u01o0dxq.jpg";
 },
 {
 "thumbnail_pic" = "http://wx3.sinaimg.cn/thumbnail/005Axneely1fna7xsds41j30mi1907fn.jpg";
 }
 );
 http://wx3.sinaimg.cn/thumbnail/5809ec90ly1fnab6611hfj20vl0hsjty.jpg
 http://wx3.sinaimg.cn/large/5809ec90ly1fnab6611hfj20vl0hsjty.jpg
 http://wx3.sinaimg.cn/bmiddle/5809ec90ly1fnab6611hfj20vl0hsjty.jpg
 thumbnail_pic
 original_pic
 bmiddle_pic
 pic_urls
 */
