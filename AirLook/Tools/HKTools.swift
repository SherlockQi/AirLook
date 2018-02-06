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
    
    ///是否显示
   class func show() -> Bool {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let day = dateFormatter.string(from: currentDate)
        print(day)
        return Int(day)! > 20180209
    }
    
    
    
   class func goodData() -> [HKWeiBoModel] {
    var goodData:[HKWeiBoModel] = [HKWeiBoModel]()
    
    let icons = ["http://tvax4.sinaimg.cn/crop.0.0.798.798.50/61e36371gy1fi7oczmdymj20m80m83yx.jpg",
                 "http://tva4.sinaimg.cn/crop.0.0.180.180.50/70e539a3jw1e8qgp5bmzyj2050050aa8.jpg",
                 "http://tvax3.sinaimg.cn/crop.0.0.1242.1242.50/70979163ly8fkyxn8duwlj20yi0yj446.jpg",
                 "http://tva1.sinaimg.cn/crop.0.0.549.549.50/006qmhkjjw8f24wkchzhaj30f90f9mxw.jpg",
                 "http://tva1.sinaimg.cn/crop.0.0.1125.1125.50/bc98413ejw8f5a7m9p47uj20v90v9gng.jpg",
                 "http://tva1.sinaimg.cn/crop.13.0.724.724.50/006wX4Kxjw8fb7q5lr8a7j30ku0k4gmw.jpg",
                 "http://tva1.sinaimg.cn/crop.0.0.549.549.50/006qmhkjjw8f24wkchzhaj30f90f9mxw.jpg",
                 "http://tva4.sinaimg.cn/crop.0.0.180.180.50/67dd74e0jw1e8qgp5bmzyj2050050aa8.jpg",
                 "http://tva3.sinaimg.cn/crop.0.0.512.512.50/593af2a7jw8et89uat9olj20e80e80t1.jpg",
                 "http://tvax4.sinaimg.cn/crop.0.0.512.512.50/006YSOtnly8fnjc2h138fj30e80e8dg2.jpg",
                 ]
    
    let names = ["虎扑篮球",
                 "北京纹身俊绣刺青-Tattoo",
                 "敖天羽",
                 "EyreFree",
                 "程大牛",
                 "故事馆长",
                 "EyreFree",
                 "思想聚焦",
                 "梁斌penny",
                 "神奇博士",
                 ]
    
    let texts = ["【Woj：骑士不会解雇主帅泰伦-卢】著名NBA记者Adrian Wojnarowski报道，尽管在过去18场比赛中已经输掉了12场，包括在刚刚结束的一场比赛中以88-120惨败给火箭，但骑士主帅泰伦-卢的岗位是安全的。一名球队官员告诉记者：“我们不会解雇我们的主教练。” ​",
                 "到底有多少人到现在还是不明白，人和人之间想要保持长久舒适的关系，靠的是共性和吸引。而不是压迫，捆绑，奉承，和一味的付出以及道德式的自我感动。",
                "我说的好有道理[吃瓜][吃瓜][吃瓜]",
                "[哆啦A梦吃惊]//@eli-lien://@月刊勇者KuMa君://@兽儿:。。。[跪了][跪了]//@什么什么厨://@孤星_泪://@本吱:真可怕//@金末冉然://@橘久月://@夜月瑾://@保育院的兔小娜小朋友://@抱团教教众-纸鱼子://@虾饺智才不是真的虾饺://@MizutaniEven:转发微博",
                "现在闲着无聊，我在想要不要瞎搞一下。。[哈哈][哈哈] http://t.cn/R8OFFpU ​",
                "分享一个真实经历的事情，想起来十分后怕。\n\n大学期间和女友冷战，那天晚上我俩像陌生人一样走在街上（间隔两米左右）。\n\n突然一个女孩儿（同龄人，长相还不错）出现在女友旁边，挽起女友的胳臂神色紧张地说：“求求你，救救我！后面那两个人一直跟着我！”。\n\n这时女友可能也是被吓到了，也立马靠了过...全文： http://m.weibo.cn/5983719357/4203416022563562 ​",
                "[doge]",
                "我坚持过最好的习惯 ​​​​",
                "继续有网友提问，我水平不高，谈谈看法。工作了再出国读书少之又少，工作后苦大仇深，你去的单位活巨苦，肯定没心思学习了。在国内读研不丢人。当然现在房价很贵，晚几年工作，代价巨大无比，这个扭曲的大时代，一定要尊重自己的意愿，做自己热爱的事情，将来才不后悔；第二个问题，考研残酷无比，现在...全文： http://m.weibo.cn/1497035431/4203707375030034 ​",
                "哇塞，宅人的终极福利！八个能让你马上舒服到上天的#黑科技#产品，简直是死宅的量身定制[抓狂]cr.人人视频http://t.cn/R8OFAfa ​",
                ]
    for i in 0..<25 {
        let index = i%10
        let weibo = HKWeiBoModel()
        weibo.user = HKUserModel()
        weibo.user?.profile_image_url = icons[index]
        weibo.user?.screen_name = names[index]
        weibo.text = texts[index]
        goodData.append(weibo)
    }
     
    return goodData
    }
    
    
}

