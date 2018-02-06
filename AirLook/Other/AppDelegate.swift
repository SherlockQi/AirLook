//
//  AppDelegate.swift
//  AirLook
//
//  Created by HeiKki on 2017/12/27.
//  Copyright © 2017年 XiaQi. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,WeiboSDKDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        WeiboSDK.registerApp("3161059495")
        //友盟
        UMSocialManager.default().openLog(true)
        UMSocialManager.default().umSocialAppkey = "5a698737f29d9875aa000113"
        
        UMSocialManager.default().platformProvider(with: UMSocialPlatformType.wechatSession).umSocial_setAppKey!("wx1285684d625ae787", withAppSecret: "3c79fc90e6bfea3a8a40df5db2f82792", withRedirectURL: "")
       
        UMSocialManager.default().platformProvider(with: UMSocialPlatformType.wechatTimeLine).umSocial_setAppKey!("wx1285684d625ae787", withAppSecret: "3c79fc90e6bfea3a8a40df5db2f82792", withRedirectURL: "")
        
        UMSocialManager.default().platformProvider(with: UMSocialPlatformType.sina).umSocial_setAppKey!("3161059495", withAppSecret: "b4078721c9f15fc630b9b0961bd3ecff", withRedirectURL: "https://github.com/SherlockQi")
        UMSocialManager.default().removePlatformProvider(with: UMSocialPlatformType.wechatFavorite)

        UMSocialManager.default().platformProvider(with: UMSocialPlatformType.QQ).umSocial_setAppKey!("1106121093", withAppSecret: "61HxCxG5ZbMYKrAv", withRedirectURL: "")
        UMSocialManager.default().removePlatformProvider(with: UMSocialPlatformType.qzone)


        Thread.sleep(forTimeInterval: 0.5)
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
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SINA_CODE"), object: nil, userInfo:userInfo )
            }else{
                ITTPromptView.showMessage("微博授权失败", andFrameY: 0)
            }
        }
    }
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        print(request)
    }
    
    //第二步  通过通知得到登录后获取的用户信息
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self)
    }
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self)
    }
    
}


