//
//  HKTools.swift
//  AirLook
//
//  Created by HeiKki on 2018/1/4.
//  Copyright © 2018年 XiaQi. All rights reserved.
//

import UIKit

class HKTools: NSObject {
    //时间
    class func weiBoTime(time:String) -> String {
        let timeDate = Date.timeStringToDate(timeString: time)
        return timeDate.dateToShowTime()
    }
    
    //来源
    func takeUpSource(source:String) -> String {
        if let range2:Range = source.range(of: "\">"){
            let s3 = source.substring(from: range2.lowerBound)
            let i  =  String.Index(encodedOffset: 2)
            let s4 = s3.substring(from: i)
            if let range:Range = s4.range(of: "</a>"){
                let from = s4.substring(to: range.lowerBound)
                return from
            }
        }
        return ""
    }
}

/**
 
 - (void)setSource:(NSString *)source
 {
 // abc>微 3 1
 //  微博 weibo.com</a>
 //  <a href="http://weibo.com/" rel="nofollow">微博 weibo.com</a>
 // 微博 weibo.com
 NSRange range = [source rangeOfString:@">"];
 source = [source substringFromIndex:range.location + range.length];
 range = [source rangeOfString:@"<"];
 source = [source substringToIndex:range.location];
 source = [NSString stringWithFormat:@"来自%@",source];
 
 _source = source;
 }
 */
