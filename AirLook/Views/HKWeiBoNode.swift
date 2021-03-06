//
//  HKWeiBoNode.swift
//  AirLook
//
//  Created by HeiKki on 2017/12/29.
//  Copyright © 2017年 XiaQi. All rights reserved.
//

import UIKit
import ARKit

class HKWeiBoNode: SCNNode {
    
    let painter:HKPainter = HKPainter()
    
    let MainColor = UIColor.red
    let MainSizeW = CGFloat(0.5)
    let MainSizeH = CGFloat(0.3)
    let MainSizeL = CGFloat(0.03)
    let MainRadius = CGFloat(0.02)
    let MainMargin = CGFloat(0.07)
    
    let maxCross = 5
    let maxLine  = 5
    let nodeAreaH:Float = 0.5
    
    var position_Original: SCNVector3?
    var rotation_Original: SCNVector4?
    var rotation_OriginalX:CGFloat?
    var index:Int?
    
    //本人图片
    var self_image_Nodes:[SCNNode] = NSMutableArray(capacity: 3) as! [SCNNode]
    //转发微博
    var retweeted_Node:SCNNode?
    //转发图片
    var retweeted_image_Nodes:[SCNNode]  = NSMutableArray(capacity: 3) as! [SCNNode]
    
    var model: HKWeiBoModel? {
        didSet{
            self.painter.model = model
            self.painter.senceNode = self
            if let url = model?.user?.profile_image_url{
                HKDownloader.readWithFile(imageName: url, completion: { (ima) in
                    DispatchQueue.main.async {
                        self.painter.drawBegin(icon: ima)
                    }
                    //下载第一个图片
                    if let largeImageUrl = self.model?.original_urls?.first{
                        DispatchQueue.global().async {
                            HKDownloader.readWithFile(imageName: largeImageUrl, completion: { (_) in })
                        }
                    }
                })
            }
        }
    }
    
    var contentImage:UIImage?{
        didSet{
            if contentImage != nil{
                setUpMaterialImage(image: contentImage!, node: self,color: UIColor.white)
            }
        }
    }
    //原创微博
    var originalImage:UIImage?{
        didSet{
            if originalImage != nil {
                setUpMaterialImage(image: originalImage!, node: self,color: UIColor.white)
            }
        }
    }
    //转发微博
    var retweetedImage:UIImage?{
        didSet{
            if retweetedImage != nil{
                setUpMaterialImage(image: retweetedImage!, node: self.retweeted_Node!,color: self.painter.zfColor)
            }
        }
    }
    
    convenience init(index:Int) {
        self.init()
        self.index = index
        let line:Float = Float(index%maxLine)
        let y:Float = nodeAreaH * 1.5 - (line * nodeAreaH)
        let z:Float = -2 + fabsf((2 - line)*0.1)
        self.position = SCNVector3Make(0,y,z)
        self.rotation = SCNVector4Make(1, 0, 0, -(line-2)*0.25)
        self.rotation_OriginalX = CGFloat(-(line-2)*0.25)
        self.position_Original = self.position
        self.rotation_Original = self.rotation
    }
    
    override init() {
        super.init()
        doInit()
    }
    
    private func doInit() {
        let previewBox = SCNBox(width: MainSizeW, height: MainSizeH, length: MainSizeL, chamferRadius: MainRadius)
        self.setValue(0.78, forKey: "opacity")
        previewBox.materials.first?.multiply.contents = UIColor.white
        self.geometry = previewBox
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toBig(){
        let newPosition  = SCNVector3Make(self.position.x/1.6, -0.1, -1.2)
        let comeOnMove = SCNAction.move(to: newPosition, duration: 0.5)
        let comeOnFade = SCNAction.fadeOpacity(by: 1.0, duration: 0.5)
        let comeOnRotation = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5)
        let comeOnGroup = SCNAction.group([comeOnMove,comeOnFade,comeOnRotation])
        self.runAction(comeOnGroup)
        
        if let boxNode:SCNBox = self.geometry as? SCNBox{
            //本人的 微博
            boxNode.height = self.painter.original_End / self.painter.sizeH * self.MainSizeH
            self.painter.drawOriginal()
            //本人的图片
            self.addSelfImages()
            //转发微博
            self.addRetweetedNode()
            //转发的图片
            self.addRetweetedImages()
        }
    }
    
    func toSmall() {
        let goAwayMove = SCNAction.move(to: self.position_Original!, duration: 0.5)
        let goAwayOnFade = SCNAction.fadeOpacity(to: 0.78, duration: 0.5)
        let rotation_OriginalX:CGFloat = CGFloat(self.rotation_OriginalX! )
        let goAwayRotation = SCNAction.rotateTo(x: rotation_OriginalX, y: 0, z: 0, duration: 0.5)
        let goAwayGroup = SCNAction.group([goAwayMove,goAwayOnFade,goAwayRotation])
        self.runAction(goAwayGroup)
        if let boxNode:SCNBox = self.geometry as? SCNBox{
            boxNode.height = self.MainSizeH
            self.painter.drawOriginal()
        }
        for node in self.childNodes {
            node.removeFromParentNode()
        }
        setUpMaterialImage(image: contentImage!, node: self,color:UIColor.white)
    }
    func setUpMaterialImage(image:UIImage,node:SCNNode,color:UIColor){
        DispatchQueue.main.async {
            let images = [image,color,color,color,color,color] as [Any]
            var materials:[SCNMaterial] = []
            for index in 0..<6 {
                let material = SCNMaterial()
                material.diffuse.contents = images[index]
                materials.append(material)
            }
            node.geometry?.materials = materials
        }  
    }
}



extension HKWeiBoNode{
    //添加本人的图片
    func addSelfImages(){
        
        //移除
        for image_Node in self_image_Nodes {
            image_Node.removeFromParentNode()
        }
        self_image_Nodes.removeAll()
        
        //添加
        if let urls = self.model?.original_urls{
            for i in 0..<urls.count {
                print(i)
                let image_Box = SCNBox(width: self.MainSizeW, height: 0.3 , length: self.MainSizeL, chamferRadius: self.MainRadius)
                let image_Node = SCNNode(geometry: image_Box)
                HKDownloader.readWithFile(imageName: urls[i], completion: { (image) in
                    self.setUpMaterialImage(image: image, node: image_Node, color: UIColor.white)
                    let imageH = self.MainSizeW * image.size.height / image.size.width
                    image_Box.height = imageH
                    
                    self.adjustPosition()
                })
                image_Node.position = SCNVector3Make(0,Float(-0.4),0)
                self.adjustPosition()
                self.addChildNode(image_Node)
                self.self_image_Nodes.append(image_Node)
            }
        }
    }
    
    func addRetweetedNode(){
        //转发的 微博
        if let url = model?.retweeted_status?.user?.profile_image_url{
            let height = self.painter.retweete_H / self.painter.sizeH * self.MainSizeH
            let box = SCNBox(width: self.MainSizeW, height: height , length: self.MainSizeL, chamferRadius: self.MainRadius)
            let nodeB = SCNNode(geometry: box)
            self.retweeted_Node = nodeB
            self.addChildNode(nodeB)
            self.adjustPosition()
            HKDownloader.readWithFile(imageName: url, completion: { (ima) in
                DispatchQueue.main.async {
                    self.painter.drawRetweeted(image: ima)
                }
            })
        }
    }
    
    func addRetweetedImages(){
        //移除
        for image_Node in retweeted_image_Nodes{
            image_Node.removeFromParentNode()
        }
        retweeted_image_Nodes.removeAll()
        
        //添加
        if let urls = self.model?.retweeted_status?.original_urls{
            for i in 0..<urls.count {
                print(i)
                let image_Box = SCNBox(width: self.MainSizeW, height: 0.3 , length: self.MainSizeL, chamferRadius: self.MainRadius)
                let image_Node = SCNNode(geometry: image_Box)
                HKDownloader.readWithFile(imageName: urls[i], completion: { (image) in
                    self.setUpMaterialImage(image: image, node: image_Node, color: UIColor.white)
                    let imageH = self.MainSizeW * image.size.height / image.size.width
                    image_Box.height = imageH
                    
                    self.adjustPosition()
                })
                let retweeted_Geo:SCNBox = retweeted_Node?.geometry as! SCNBox
                let changeY = (retweeted_Geo.height + 0.3) * 0.5 + MainMargin
                let y = CGFloat((retweeted_Node?.position.y)!) - changeY
                image_Node.position = SCNVector3Make(0,Float(y),0)
                self.adjustPosition()
                self.addChildNode(image_Node)
                self.retweeted_image_Nodes.append(image_Node)
                
            }
        }
    }
    func adjustPosition(){
        //排版个人图片
        if ((self.model?.original_urls) != nil) {
            var tempNode:SCNNode = self
            for node in self_image_Nodes {
                let tNode_Geometry = tempNode.geometry  as! SCNBox
                let node_Geometry = node.geometry  as! SCNBox
                let tempY = tempNode == self ? 0 : CGFloat(tempNode.position.y)
                let y = tempY - (tNode_Geometry.height + node_Geometry.height) * 0.5 - MainMargin
                node.position = SCNVector3Make(0,Float(y),0)
                tempNode = node
            }
        }
        //排版转发微博
        if((self.model?.retweeted_status) != nil){
            var upNode:SCNNode = self
            if self.self_image_Nodes.count>0{
                upNode = self.self_image_Nodes.last!
            }
            let up_Geo:SCNBox = upNode.geometry as! SCNBox
            let retweeted_Geo:SCNBox = retweeted_Node?.geometry as! SCNBox
            let tempY = upNode == self ? 0 : CGFloat(upNode.position.y)
            let y = tempY - (up_Geo.height + retweeted_Geo.height) * 0.5 - MainMargin
            retweeted_Node?.position = SCNVector3Make(0,Float(y), 0)
        }
        
        //排版转发图片
        if ((self.model?.retweeted_status?.original_urls) != nil) {
            var tempNode:SCNNode = retweeted_Node!
            for node in retweeted_image_Nodes {
                let tNode_Geometry = tempNode.geometry  as! SCNBox
                let node_Geometry = node.geometry  as! SCNBox
                let tempY = CGFloat(tempNode.position.y)
                let y = tempY - (tNode_Geometry.height + node_Geometry.height) * 0.5 - MainMargin
                node.position = SCNVector3Make(0,Float(y),0)
                tempNode = node
            }
        }
    }
}
