//
//  ViewController.swift
//  AirLook
//
//  Created by HeiKki on 2017/12/27.
//  Copyright © 2017年 XiaQi. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var inButton: UIButton!
    @IBOutlet weak var nickLabel: UILabel!
    let pscope = PermissionScope()
    override func viewDidLoad() {
        super.viewDidLoad()
        pscope.addPermission(CameraPermission(),message: "\rAirLook需要您的相机看世界")
        self.addNotification()
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func mainButtonDidClick(_ sender: UIButton) {
        loginWeiBo()
    }
    
    func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(onRecviceSINA_CODE_Notification(notification:)), name: NSNotification.Name(rawValue: "SINA_CODE"), object: nil)
    }
}
//MARK:登陆&获取信息
extension ViewController{
    //登陆
    @objc func loginWeiBo(){
        let request : WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = "https://github.com/SherlockQi"
        WeiboSDK.send(request)
    }
    
    @objc func onRecviceSINA_CODE_Notification(notification:NSNotification)
    {
        var userinfoDic : Dictionary = notification.userInfo!
        let userAppInfo: Dictionary<String,String> = userinfoDic["app"] as! Dictionary
        refeshUserInfo(dic: userAppInfo as NSDictionary)
        if let access_token = userinfoDic["access_token"]{
            UserDefaults.standard.setValue(access_token, forKey: KEY_ACCESS_TOKEN)
            UserDefaults.standard.synchronize()
            permissions()
        }
    }
    func refeshUserInfo(dic : NSDictionary){
        let headimgurl: String = dic["logo"] as! String
        let nickname: String = dic["name"] as! String
        HKDownloader.readWithFile(imageName: headimgurl, completion: { (ima) in
            self.inButton.setBackgroundImage(ima, for: .normal)
        })
        self.nickLabel.text = nickname
    }
}

// 判断权限
extension ViewController{
    func permissions(){
        pscope.show(
            { finished, results in
                self.pscope.hide()
                let videoAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
                switch videoAuthStatus {
                case .notDetermined: break//未询问
                case .denied: break//已悲剧
                default:
                    let weiBoVC = HKDoorViewController()
                    self.navigationController?.pushViewController(weiBoVC, animated: false)
                    break
                }
        },
            cancelled: { results in
                print("thing was cancelled")
                self.pscope.hide()
        }
        )
    }
}
