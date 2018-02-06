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
    var backButton :UIButton?
    var resetButton :UIButton?
    let tipView = HKTipView.tipView()
    var guideView:UIView?
    
    var page:NSInteger = 1
    
    var timeLineSource:[HKWeiBoModel] = NSMutableArray(capacity: 25) as! [HKWeiBoModel]
    /**
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        self.setSceneView()
        self.addGestureRecognizer()
        self.addLoadButton()
        self.addResetButton()
        self.addBackButton()
        self.weiboNodes = []
        loadWeiBo()
        tipView.frame = CGRect(x: 10, y: 100, width:self.view.bounds.size.width - 20, height: 200)
        showGuideView()
    }
    
    
    func setSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = false
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.antialiasingMode = SCNAntialiasingMode.multisampling4X
    }
    func addLoadButton(){
        let nextButton = HKLoadingButton(frame: CGRect(x: view.bounds.size.width - 55, y: view.bounds.size.height - 55, width: 40, height: 40))
        loadButton = nextButton
        nextButton.backgroundColor = UIColor(red: 60/255.0, green: 180/255.0, blue: 244/255.0, alpha: 0.5)
        nextButton.setImage(UIImage(named: "loadMore"), for: .normal)
        nextButton.setImage(UIImage(named: "loadMore"), for: .disabled)
        nextButton.layer.cornerRadius = nextButton.bounds.size.width * 0.5
        nextButton.layer.masksToBounds = true
        nextButton.addTarget(self, action: #selector(loadMoreButtonDidClick(sender:)), for: .touchUpInside)
        view.addSubview(nextButton)
    }
    func addResetButton(){
        resetButton = UIButton(frame: CGRect(x: view.bounds.size.width - 35, y: 20, width: 20, height: 20))
        resetButton?.setImage(#imageLiteral(resourceName: "reset"), for: .normal)
        resetButton?.setImage(#imageLiteral(resourceName: "reset"), for: .disabled)
        resetButton?.addTarget(self, action: #selector(loadResetButtonDidClick(sender:)), for: .touchUpInside)
        view.addSubview(resetButton!)
    }
    func addBackButton(){
        backButton = UIButton(frame: CGRect(x: 8, y: 16, width: 25, height: 25))
        backButton?.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton?.setImage(#imageLiteral(resourceName: "back"), for: .disabled)
        backButton?.addTarget(self, action: #selector(backButtonDidClick(sender:)), for: .touchUpInside)
        view.addSubview(backButton!)
    }
    
    func addGestureRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle(gesture:)))
        sceneView.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandle(gesture:)))
        sceneView.addGestureRecognizer(pan)
    }
    
    
    
    
    @objc func loadResetButtonDidClick(sender:UIButton){
        print("loadResetButtonDidClick")
        self.sceneView.removeFromSuperview()
        sceneView = ARSCNView(frame: view.bounds)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        view.insertSubview(sceneView, at: 0)
        self.addWeiBoSence()
        self.addGestureRecognizer()
    }
    @objc func backButtonDidClick(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func loadMoreButtonDidClick(sender:UIButton){
        sender.isSelected = !sender.isSelected
        sender.setNeedsDisplay()
        if sender.isSelected {
            loadWeiBo()
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
        sceneView.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    deinit {
        print("deinit")
    }
}
//MARK:节点组装
extension HKDoorViewController{
    
    func addWeiBoSence(){
        for wNode in self.weiboNodes! {
            wNode.removeFromParentNode()
        }
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
    
    
    
    /**
     *
     if token{
     下载微博
     }else{
     使用 goodData
     }
     *
     */
    func loadWeiBo(){
        self.loadButton?.isHidden = false
        if let token = UserDefaults.standard.value(forKey: KEY_ACCESS_TOKEN) {
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
                case .failure(_): break
                }
            }
        }else{
            self.timeLineSource = HKTools.goodData()
            self.addWeiBoSence()
            //            self.loadButton?.isHidden = true
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
        let tapNode = firstNode.node
        if tapNode == self.mainNode{
            return;
        }
        //点到转发微博
        if self.selectNode != nil{
            if self.selectNode!.retweeted_Node == tapNode{
                self.toSmall(node:selectNode)
                return
            }
            if self.selectNode!.childNodes.contains(tapNode){
                self.toSmall(node:selectNode)
                return
            }
        }
        if tapNode == self.selectNode{
            self.toSmall(node:self.selectNode)
        }else{
            self.toSmall(node:selectNode)
            self.toBig(node: (tapNode as? HKWeiBoNode)!)
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
extension HKDoorViewController{
    
    func showGuideView(){
    
        if !HKTools.show() {
            return
        }
        
        if  UserDefaults.standard.bool(forKey: KEY_ACCESS_NO_FIRST){
            return
        }
        
        
        loadButton?.isEnabled = false
        resetButton?.isEnabled = false
        backButton?.isEnabled = false
        
        guideView = UIView(frame:view.bounds)
        guideView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        view.insertSubview(guideView!, belowSubview: loadButton!)
        
        let r_arrow_iv = UIImageView(image: #imageLiteral(resourceName: "arrow_right"))
        let l_arrow_iv = UIImageView(image: #imageLiteral(resourceName: "arrow_left"))
        let b_arrow_iv = UIImageView(image: #imageLiteral(resourceName: "arrow_bottom"))
        l_arrow_iv.frame = CGRect(x: 30, y: 30, width: 50, height: 50)
        r_arrow_iv.frame = CGRect(x: view.bounds.size.width - 75, y: 45, width: 50, height: 50)
        b_arrow_iv.frame = CGRect(x: view.bounds.size.width - 70, y: view.bounds.size.height - 115, width: 50, height: 50)
        guideView?.addSubview(r_arrow_iv)
        guideView?.addSubview(l_arrow_iv)
        guideView?.addSubview(b_arrow_iv)
        
        let t_color = UIColor.white
        let t_font = UIFont.systemFont(ofSize: 12)
        
        let l_label = UILabel(frame: CGRect(x: 30, y: 80, width: 50, height: 20))
        l_label.textColor = t_color
        l_label.font = t_font
        l_label.text = "返回主页"
        
        let r_label = UILabel(frame: CGRect(x: view.bounds.size.width - 80, y: 100, width: 80, height: 20))
        r_label.textColor = t_color
        r_label.font = t_font
        r_label.text = "重置位置"
        
        let b_label = UILabel(frame: CGRect(x: view.bounds.size.width - 100, y: view.bounds.size.height - 140, width: 100, height: 20))
        b_label.textColor = t_color
        b_label.font = t_font
        b_label.text = "加载更多内容"
        
        let b_color = UIColor(red: 48/256.0, green: 150/256.0, blue: 209/256.0, alpha: 0.5)
        
        let knowButton = UIButton(frame: CGRect(x:0, y:0, width: 200, height: 60))
        knowButton.center = guideView!.center
        knowButton.backgroundColor = UIColor.white
        knowButton.setTitle("知道啦", for: .normal)
        knowButton.setTitleColor(b_color, for: .normal)
        knowButton.layer.cornerRadius = 5
        knowButton.layer.masksToBounds = true
        knowButton.layer.borderWidth = 4
        knowButton.layer.borderColor = b_color.cgColor
        
        knowButton.addTarget(self, action: #selector(knowButtonDidClick), for: .touchUpInside)
        guideView?.addSubview(l_label)
        guideView?.addSubview(r_label)
        guideView?.addSubview(b_label)
        guideView?.addSubview(knowButton)
    }
    @objc func knowButtonDidClick() {
        

         UserDefaults.standard.set(true, forKey: KEY_ACCESS_NO_FIRST)
        
        UserDefaults.standard.synchronize()
        
        loadButton?.isEnabled = true
        resetButton?.isEnabled = true
        backButton?.isEnabled = true
        guideView!.removeFromSuperview()
        guideView = nil
    }
}


