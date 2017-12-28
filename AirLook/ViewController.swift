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

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var weibo:[UIView]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        //去锯齿
        sceneView.antialiasingMode = SCNAntialiasingMode.multisampling4X
        //
        addWeiBoSence()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    func addWeiBoSence(){
        let maxCross = 5
        let maxLine  = 5
        let nodeSizeW = 0.4
        let nodeSizeH = 0.3
//        let nodeMargin = 0.1
        
        let nodeAreaW:Float = Float(nodeSizeW/* + nodeMargin*/)
        let nodeAreaH:Float = Float(nodeSizeH/* + nodeMargin*/)
        
        
        
        
        let sp = SCNSphere(radius: 0.02)
//        sp.firstMaterial?.diffuse.contents = UIColor.
        let rootNode = SCNNode(geometry: sp)
        rootNode.position = SCNVector3Make(0, 0, 0)
        sceneView.scene.rootNode.addChildNode(rootNode)
        
        
        
        
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
            let action = SCNAction.rotateBy(x: 0, y: CGFloat(-(cross-2)*0.6), z: 0, duration: 0)
            emptyNode.runAction(action)
            emptyNode.addChildNode(weiBoNode)
            rootNode.addChildNode(emptyNode)
            

            let contentImage = WeiBoImage.image(text: "一二三四五六七八九十十一十二十三十四十五十六十七十八十九二十")
            let image = UIImage(named: "whiteImage")
            
            let images = [contentImage,image,image,image,image,image]
            
            var materials:[SCNMaterial] = []
            for index in 0..<6 {
                let material = SCNMaterial()
                material.multiply.contents = images[index]
                materials.append(material)
            }
            weiBoBox.materials = materials
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          loginWeiBo()
    }
    //登陆
    func loginWeiBo(){
        let request : WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = "https://github.com/SherlockQi"
        request.scope = "all"
//        request.userInfo = ["SSO_Key":"SSO_Value"]
        WeiboSDK.send(request)
    }
}
//149023EB-E6BB-464B-87F2-73EE1C233EB8
