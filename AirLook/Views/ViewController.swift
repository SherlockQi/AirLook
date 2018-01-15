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
    var selectNode:HKWeiBoNode?
    let animDuration = 0.50
    let mainNode = SCNNode()
    var weiboNodes:[SCNNode]?
    var loadButton :HKLoadingButton?
    
    var page:NSInteger = 0
    
    var timeLineSource:[HKWeiBoModel] = NSMutableArray(capacity: 25) as! [HKWeiBoModel]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.setSceneView()
        self.addGestureRecognizer()
        self.addLoadButton()
        self.weiboNodes = []
        if let token = UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN) {
            loadWeiBo(token:token as! String)
        }else{
            loginWeiBo()
        }
        
    }
    func setSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.antialiasingMode = SCNAntialiasingMode.multisampling4X
    }
    func addLoadButton(){
        let nextButton = HKLoadingButton(frame: CGRect(x: view.bounds.size.width - 80, y: view.bounds.size.height - 80, width: 50, height: 50))
        loadButton = nextButton
        nextButton.backgroundColor = UIColor(red: 60/255.0, green: 180/255.0, blue: 244/255.0, alpha: 0.5)
        nextButton.setImage(UIImage(named: "loadMore"), for: .normal)
        nextButton.setImage(UIImage(named: "nil"), for: .selected)
        nextButton.layer.cornerRadius = 25
        nextButton.layer.masksToBounds = true
        nextButton.addTarget(self, action: #selector(loadMoreButtonDidClick(sender:)), for: .touchUpInside)
        view.addSubview(nextButton)
    }
    func addGestureRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle(gesture:)))
        sceneView.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandle(gesture:)))
        sceneView.addGestureRecognizer(pan)
    }
    func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(onRecviceSINA_CODE_Notification(notification:)), name: NSNotification.Name(rawValue: "SINA_CODE"), object: nil)
    }
    @objc func loadMoreButtonDidClick(sender:UIButton){
        sender.isSelected = !sender.isSelected
        sender.setNeedsDisplay()
        
        if sender.isSelected {
            let token:String = UserDefaults.standard.object(forKey: KEY_ACCESS_TOKEN) as! String
            loadWeiBo(token: token)
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
        
        for wNode in self.weiboNodes! {
            wNode.removeFromParentNode()
        }
        
        print(timeLineSource)
        let sp = SCNSphere(radius: 0.02)
        mainNode.geometry = sp
        mainNode.position = SCNVector3Make(0, 0, 0.5)
        sceneView.scene.rootNode.addChildNode(mainNode)
        for index in 0..<25 {
            let weiBoNode = HKWeiBoNode(index: index)
            let cross:Float = Float(index/5)
            let emptyNode = SCNNode()
            emptyNode.position = SCNVector3Zero
            let rotateY:CGFloat = CGFloat((2 - cross)*0.40)
            let actionR = SCNAction.rotateBy(x: 0, y: rotateY, z: 0, duration: 0)
            emptyNode.runAction(actionR)
            emptyNode.addChildNode(weiBoNode)
            mainNode.addChildNode(emptyNode)
            
            self.weiboNodes?.append(weiBoNode)
            
            if timeLineSource.count > index {
                weiBoNode.model = timeLineSource[index]
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
        
        let parameters:[String : Any] =  ["access_token":token,"count":25,"page":page]
        
        
        Alamofire.request(timeLine, method: .get, parameters: parameters).responseJSON { (response) in
   
            /**
             SUCCESS: {
             error = "User requests out of rate limit!";
             "error_code" = 10023;
             request = "/2/statuses/home_timeline.json";
             }
             
             */
            
            if response.description.contains("\"error_code\" = 10023;") || response.description.contains("User requests out of rate limit") {
                print("responseString")
                
//                ITTPromptView.showMessage("-------", andFrameY: 0)
                
            }
            
            
            switch response.result {
            case .success(let value):
                
                self.timeLineSource.removeAll()
                if let timeJsonArr:[JSON] = JSON(value)["statuses"].array{
                    for index in 0..<timeJsonArr.count {
                        if let dic = timeJsonArr[index].dictionary{
                            let model:HKWeiBoModel = HKWeiBoModel.modelWithDic(dic:dic)
                            self.timeLineSource.append(model)
                        }
                    }
                    DispatchQueue.main.async {
                        self.addWeiBoSence()
                        self.loadButton?.isSelected = false
                    }
                    self.page =  self.page + 1
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
        let node = firstNode.node
        if firstNode.node == self.selectNode{
            self.toSmall(node:self.selectNode)
        }else{
            if self.selectNode != nil{
                if self.selectNode!.child_Nodes.contains(firstNode.node){
                    self.toSmall(node:selectNode)
                }else{
                    self.toSmall(node:selectNode)
                    self.toBig(node: (node as? HKWeiBoNode)!)
                }
            }else{
                self.toSmall(node:selectNode)
                self.toBig(node: (node as? HKWeiBoNode)!)
            }
        }
    }
    func toBig(node:HKWeiBoNode) {
        node.toBig()
        selectNode = node
    }
    func toSmall(node:HKWeiBoNode?) {
        if node != nil{
            node?.toSmall()
            selectNode = nil
        }
    }
}

//MARK:节点拖动事件
extension ViewController{
    @objc func panHandle(gesture:UIPanGestureRecognizer){
        print(gesture)
        let point = gesture.translation(in: self.view)
        print(point)
        
        let  x = self.selectNode?.position.x ?? 0
        let  y = self.selectNode?.position.y ?? 0
        let  z = self.selectNode?.position.z ?? 0
        let  yFloat = y - Float(point.y)*0.002
        self.selectNode?.position = SCNVector3Make(x,yFloat,z)
        selectNode?.rotation = SCNVector4Make(0, 0, 0, 0)
        gesture.setTranslation(CGPoint.zero, in: self.view)
    }
}
