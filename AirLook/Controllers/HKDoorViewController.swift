//
//  HKDoorViewController.swift
//  AirLook
//
//  Created by HeiKki on 2018/1/16.
//  Copyright © 2018年 XiaQi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftyJSON
import Alamofire

class HKDoorViewController: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    var weibo:[UIView]?
    var selectNode:HKWeiBoNode?
    let animDuration = 0.50
    let mainNode = SCNNode()
    var weiboNodes:[SCNNode]?
    var loadButton :HKLoadingButton?
    let tipView = HKTipView.tipView()
    
    var page:NSInteger = 1
    
    var timeLineSource:[HKWeiBoModel] = NSMutableArray(capacity: 25) as! [HKWeiBoModel]
    
    override func loadView() {
        super.loadView()
        view = ARSCNView(frame: view.bounds)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        view.backgroundColor = UIColor.black
        sceneView = view as! ARSCNView
        
        self.setSceneView()
        self.addGestureRecognizer()
        self.addLoadButton()
        self.addResetButton()
        
        self.weiboNodes = []
        if let token = UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN) {
            loadWeiBo(token:token as! String)
        }
        tipView.frame = CGRect(x: 10, y: 100, width:self.view.bounds.size.width - 20, height: 200)
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
        nextButton.layer.cornerRadius = 25
        nextButton.layer.masksToBounds = true
        nextButton.addTarget(self, action: #selector(loadMoreButtonDidClick(sender:)), for: .touchUpInside)
        view.addSubview(nextButton)
    }
    func addResetButton(){
        let resetButton = UIButton(frame: CGRect(x: view.bounds.size.width - 80, y: 0, width: 50, height: 50))
        resetButton.backgroundColor = UIColor(red: 60/255.0, green: 180/255.0, blue: 244/255.0, alpha: 0.5)
        resetButton.setImage(UIImage(named: "loadMore"), for: .normal)
        resetButton.layer.cornerRadius = 25
        resetButton.layer.masksToBounds = true
        resetButton.addTarget(self, action: #selector(loadResetButtonDidClick(sender:)), for: .touchUpInside)
        view.addSubview(resetButton)
    }
    func addGestureRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle(gesture:)))
        sceneView.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandle(gesture:)))
        sceneView.addGestureRecognizer(pan)
    }
    
    @objc func loadResetButtonDidClick(sender:UIButton){
        print("loadResetButtonDidClick")
    }
    @objc func loadMoreButtonDidClick(sender:UIButton){
        sender.isSelected = !sender.isSelected
        sender.setNeedsDisplay()
        if sender.isSelected {
            if let token = UserDefaults.standard.object(forKey: KEY_ACCESS_TOKEN){
                loadWeiBo(token: token as! String)
            }
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
}
//MARK:节点组装
extension HKDoorViewController{
    
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
extension HKDoorViewController{
    func loadWeiBo(token:String){
        let timeLine = "https://api.weibo.com/2/statuses/home_timeline.json"
        let parameters:[String : Any] =  ["access_token":token,"count":25,"page":page]
        self.tipView.removeFromSuperview()
        Alamofire.request(timeLine, method: .get, parameters: parameters).responseJSON { (response) in
            if response.description.contains("\"error_code\" = 10023;") || response.description.contains("User requests out of rate limit") {
                self.view.addSubview(self.tipView)
                self.loadButton?.isSelected = false
            }
            switch response.result {
            case .success(let value):
                print(value)
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
extension HKDoorViewController{
    @objc func tapHandle(gesture:UITapGestureRecognizer){
        let results:[SCNHitTestResult] = (self.sceneView?.hitTest(gesture.location(ofTouch: 0, in: self.sceneView), options: nil))!
        guard let firstNode  = results.first else{
            return
        }
        // 点击到的节点
        let node = firstNode.node
        //点到转发微博
        if self.selectNode != nil{
            if self.selectNode!.retweeted_Node == firstNode.node{
                self.toSmall(node:selectNode)
                return
            }
        }
        if firstNode.node == self.selectNode{
            self.toSmall(node:self.selectNode)
        }else{
            self.toSmall(node:selectNode)
            self.toBig(node: (node as? HKWeiBoNode)!)
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
extension HKDoorViewController{
    @objc func panHandle(gesture:UIPanGestureRecognizer){
        let point = gesture.translation(in: self.view)
        let  x = self.selectNode?.position.x ?? 0
        let  y = self.selectNode?.position.y ?? 0
        let  z = self.selectNode?.position.z ?? 0
        let  yFloat = y - Float(point.y)*0.002
        self.selectNode?.position = SCNVector3Make(x,yFloat,z)
        selectNode?.rotation = SCNVector4Make(0, 0, 0, 0)
        gesture.setTranslation(CGPoint.zero, in: self.view)
    }
}
