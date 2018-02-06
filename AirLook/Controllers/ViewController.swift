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
    @IBOutlet weak var tipLabel: UILabel!
    
    let pscope = PermissionScope()
    override func viewDidLoad() {
        super.viewDidLoad()
        pscope.addPermission(CameraPermission(),message: "\rAirLook需要您的相机看世界")
        self.addNotification()
        refeshUserInfo()

        tipLabel.isHidden = !HKTools.show()
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func mainButtonDidClick(_ sender: UIButton) {
        if HKTools.show(){
            loginWeiBo()
        }else{
            let weiBoVC = HKDoorViewController()
            self.navigationController?.pushViewController(weiBoVC, animated: false)
        }
    }
    @IBAction func supportButtonDidClick(_ sender: UIButton) {
        toAppStore()
    }
    @IBAction func shareButtonDidClick(_ sender: UIButton) {
        UMSocialUIManager.showShareMenuViewInWindow(platformSelectionBlock: { (type, dic) in
            let messgaeObject = UMSocialMessageObject()
            
            let shareObject = UMShareWebpageObject.shareObject(withTitle: "AirLook", descr: "刷微博?何不换一种方式\n\nAR微博,了解一下", thumImage: UIImage(named: "hudie_4"))
            shareObject?.webpageUrl = "https://itunes.apple.com/cn/app/weare/id1325931978?mt=8"
            messgaeObject.shareObject = shareObject
            UMSocialManager.default().share(to: type, messageObject: messgaeObject, currentViewController: self, completion: { (data, error) in
            })
        })
    }
    
    func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(onRecviceSINA_CODE_Notification(notification:)), name: NSNotification.Name(rawValue: "SINA_CODE"), object: nil)
    }
}
//MARK:登陆&获取信息
extension ViewController{
    /** 登陆微博
     *
     * if(token){跳转}els{注册}
     *
     */
    @objc func loginWeiBo(){
        if  (UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN) != nil) {
            let weiBoVC = HKDoorViewController()
            self.navigationController?.pushViewController(weiBoVC, animated: false)
        }else{
            let request : WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
            request.redirectURI = "https://github.com/SherlockQi"
            WeiboSDK.send(request)
        }
    }
    
    @objc func onRecviceSINA_CODE_Notification(notification:NSNotification)
    {
        var userinfoDic : Dictionary = notification.userInfo!
        if let uid = userinfoDic["uid"]{
            UserDefaults.standard.setValue(uid, forKey: KEY_ACCESS_UID)
            UserDefaults.standard.synchronize()
            permissions()
        }
        
        if let access_token = userinfoDic["access_token"]{
            UserDefaults.standard.setValue(access_token, forKey: KEY_ACCESS_TOKEN)
            UserDefaults.standard.synchronize()
            permissions()
            loadUserInfo()
        }
    }
    func refeshUserInfo(){
        if let iconUrl = UserDefaults.standard.string(forKey: KEY_ACCESS_ICON){
            HKDownloader.readWithFile(imageName: iconUrl , completion: { (ima) in
                self.inButton.setBackgroundImage(ima, for: .normal)
            })
        }
        if  let name = UserDefaults.standard.string(forKey: KEY_ACCESS_NAME){
            self.nickLabel.text = name
        }
    }
}
extension ViewController{
    
    func toAppStore(){
        let alertController = UIAlertController(title: "去评分",
                                                message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "残忍拒绝", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "鼓励一下", style: .default,
                                     handler: {
                                        action in
                                        self.gotoAppStore()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    func gotoAppStore() {
        let url = URL(string: "itms-apps://itunes.apple.com/cn/app/airlook/id1325931978?action=write-review")
        UIApplication.shared.open(url!,options: [:], completionHandler: nil)
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
                self.pscope.hide()
        }
        )
    }
}
// 获取用户头像和昵称
extension ViewController{
    func loadUserInfo() {
        if let token = UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN) {
            if let uid = UserDefaults.standard.value(forKey: KEY_ACCESS_UID) {
                let userInfo = "https://api.weibo.com/2/users/show.json"
                let parameters:[String : Any] =  ["access_token":token,"uid":uid]
                Alamofire.request(userInfo, method: .get, parameters: parameters).responseJSON { (response) in
                    switch response.result {
                    case .success(let value):
                        let dic:Dictionary = JSON(value).dictionaryObject!
                        let headimgurl = dic["avatar_large"] ?? ""
                        let nickname = dic["screen_name"] ?? ""
                        UserDefaults.standard.setValue(headimgurl, forKey: KEY_ACCESS_ICON)
                        UserDefaults.standard.setValue(nickname, forKey: KEY_ACCESS_NAME)
                        UserDefaults.standard.synchronize()
                        DispatchQueue.main.async {
                            self.refeshUserInfo()
                        }
                    case .failure( _):break
                    }
                }
            }
        }
    }
}
