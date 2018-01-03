//
//  ViewController.swift
//  AirLook
//
//  Created by HeiKki on 2017/12/27.
//  Copyright © 2017年 XiaQi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftyJSON
import Alamofire


class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var weibo:[UIView]?
    var selectNode:SCNNode?
    let animDuration = 0.75
    let mainNode = SCNNode()
    var timeLineSource:[HKWeiBoModel] = NSMutableArray(capacity: 25) as! [HKWeiBoModel]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.antialiasingMode = SCNAntialiasingMode.multisampling4X
        //MARK:点击事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle(gesture:)))
        sceneView.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(onRecviceSINA_CODE_Notification(notification:)), name: NSNotification.Name(rawValue: "SINA_CODE"), object: nil)
        
        if let token = UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN) {
            loadWeiBo(token:token as! String)
        }else{
            loginWeiBo()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
}
//MARK:节点组装
extension ViewController{
    
    func addWeiBoSence(){
        let maxCross = 5
        let maxLine  = 5
        let nodeSizeW = 0.4
        let nodeSizeH = 0.3
        let nodeAreaH:Float = Float(nodeSizeH)
        print(timeLineSource)
        let sp = SCNSphere(radius: 0.02)
        mainNode.geometry = sp
        mainNode.position = SCNVector3Make(0, 0, -0.5)
        sceneView.scene.rootNode.addChildNode(mainNode)
        
        
        for index in 0..<(maxCross*maxLine) {
            let weiBoBox = SCNBox(width: CGFloat(nodeSizeW), height: CGFloat(nodeSizeH), length: 0.02, chamferRadius: 0.02)
            
            let weiBoNode = SCNNode(geometry: weiBoBox)
            let cross:Float = Float(index/maxCross)
            let line:Float = Float(index%maxLine)
            
            let y:Float = nodeAreaH * 2 - (line*nodeAreaH)
            let z:Float = -1
            weiBoNode.position = SCNVector3Make(0,y,z)
            let emptyNode = SCNNode()
            
            emptyNode.position = SCNVector3Zero
            emptyNode.rotation = SCNVector4Make(1, 0, 0, -(line-2)*0.15)
           
            let actionR = SCNAction.rotateBy(x: 0, y: CGFloat(-(cross-2)*0.6), z: 0, duration: 0)
            emptyNode.runAction(actionR)
            emptyNode.addChildNode(weiBoNode)
            mainNode.addChildNode(emptyNode)
            //透明度
            emptyNode.setValue(0.85, forKey: "opacity")
            if timeLineSource.count > index {
                HKPainter().drawImage(model: timeLineSource[index], weiboBox: weiBoBox)
            }
        }
    }
    
}
//MARK:登陆&获取信息
extension ViewController{
    //登陆
    @objc func loginWeiBo(){
        let request : WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = "https://github.com/SherlockQi"
        request.scope = "all"
        //        request.userInfo = ["SSO_Key":"SSO_Value"]
        WeiboSDK.send(request)
    }
    
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
        
        if let access_token = userinfoDic["access_token"]{
            UserDefaults.standard.setValue(access_token, forKey: KEY_ACCESS_TOKEN)
            loadWeiBo(token: access_token as! String)
        }
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
    func loadWeiBo(token:String){
        let timeLine = "https://api.weibo.com/2/statuses/home_timeline.json"
        let parameters:[String : Any] =  ["access_token":token,"count":25]
        /**
         2.00rJJL_CZyTv8Db55698d3c6wzY_EE
         */
        Alamofire.request(timeLine, method: .get, parameters: parameters).responseJSON { (response) in
            print(response)
            switch response.result {
            case .success(let value):
                if let timeJsonArr:[JSON] = JSON(value)["statuses"].array{
                    for index in 0..<timeJsonArr.count {
                        if let dic = timeJsonArr[index].dictionary{
                            let model:HKWeiBoModel = HKWeiBoModel.modelWithDic(dic:dic)
                            self.timeLineSource.append(model)
                        }
                    }
                    DispatchQueue.main.async {
                        self.addWeiBoSence()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}


//MARK:节点点击事件
extension ViewController{
    @objc func tapHandle(gesture:UITapGestureRecognizer){
        
        
        let results:[SCNHitTestResult] = (self.sceneView?.hitTest(gesture.location(ofTouch: 0, in: self.sceneView), options: nil))!
        guard let firstNode  = results.first else{
            return
        }
        // 点击到的节点
        let node = firstNode.node.copy() as! SCNNode
        
        if firstNode.node == self.selectNode {
            
            let newPosition  = SCNVector3Make(firstNode.node.worldPosition.x*2, firstNode.node.worldPosition.y*2, firstNode.node.worldPosition.z*2)
            let comeOut = SCNAction.move(to: newPosition, duration: animDuration)
            firstNode.node.runAction(comeOut)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + animDuration, execute: {
                firstNode.node.removeFromParentNode()
            })
        }else{
            self.selectNode?.removeFromParentNode()
            node.position = firstNode.node.worldPosition
            let newPosition  = SCNVector3Make(firstNode.node.worldPosition.x/2, firstNode.node.worldPosition.y/2, firstNode.node.worldPosition.z/2)
            node.rotation = (sceneView.pointOfView?.rotation)!
            sceneView.scene.rootNode.addChildNode(node)
            //            rootNode.addChildNode(node)
            let comeOn = SCNAction.move(to: newPosition, duration: animDuration)
            node.runAction(comeOn)
            selectNode = node
        }
    }
}
