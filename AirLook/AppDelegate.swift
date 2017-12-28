//
//  AppDelegate.swift
//  AirLook
//
//  Created by HeiKki on 2017/12/27.
//  Copyright © 2017年 XiaQi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,WeiboSDKDelegate {

    

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        WeiboSDK.registerApp("3161059495")
        NotificationCenter.default.addObserver(self, selector: #selector(onRecviceSINA_CODE_Notification(notification:)), name: NSNotification.Name(rawValue: "SINA_CODE"), object: nil)

        
        return true
    }

    //回调
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        if response.isKind(of: WBAuthorizeResponse.self){
            if (response.statusCode == WeiboSDKResponseStatusCode.success) {
                let authorizeResponse : WBAuthorizeResponse = response as! WBAuthorizeResponse
                let userID = authorizeResponse.userID
                let accessToken = authorizeResponse.accessToken
                print("userID:\(String(describing: userID))\naccessToken:\(String(describing: accessToken))")
                let userInfo = response.userInfo as Dictionary
                
                /*
                 userID:Optional("2115672863")
                 accessToken:Optional("2.00rJJL_CZyTv8D5fd60ecacaZ5OGrB")
                 **/
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SINA_CODE"), object: nil, userInfo:userInfo )
            }
        }
    }
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        print(request)
    }
    
    //第二步  通过通知得到登录后获取的用户信息
    @objc func onRecviceSINA_CODE_Notification(notification:NSNotification)
    {
//        SVProgressHUD.showSuccessWithStatus("获取到用户信息", duration: 1)
        var userinfoDic : Dictionary = notification.userInfo!
        
        print("userInfo:\(userinfoDic)")
        
        /*
         userInfo:[AnyHashable("refresh_token"): 2.00rJJL_CZyTv8D05b152f6567LZcJC,
         AnyHashable("app"): {
         logo = "http://timg.sjs.sinajs.cn/miniblog2style/images/developer/default_50.gif";
         name = "\U672a\U901a\U8fc7\U5ba1\U6838\U5e94\U7528";
         },
         AnyHashable("access_token"): 2.00rJJL_CZyTv8D5fd60ecacaZ5OGrB,
         AnyHashable("isRealName")  : true,
         AnyHashable("remind_in")   : 157679999,
         AnyHashable("scope")       : follow_app_official_microblog,
         AnyHashable("uid")         : 2115672863,
         AnyHashable("expires_in")  : 157679999]
         */
        let userAppInfo: Dictionary<String,String> = userinfoDic["app"] as! Dictionary
        refeshUserInfo(dic: userAppInfo as NSDictionary)
    }
    
    //第三步 刷新用户界面
    func refeshUserInfo(dic : NSDictionary){
        let headimgurl: String = dic["logo"] as! String
        let nickname: String = dic["name"] as! String
        print(headimgurl)
        print(nickname)
//        self.headerImg.sd_setImageWithURL(NSURL(string: headimgurl))
//        self.nicknameLbl.text = nickname
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
         return WeiboSDK.handleOpen(url, delegate: self)
    }
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
         return WeiboSDK.handleOpen(url, delegate: self)
    }
    
}

