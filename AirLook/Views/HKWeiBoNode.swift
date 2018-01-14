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
    let MainTransparency = CGFloat(0.78)
    
    let maxCross = 5
    let maxLine  = 5
    let nodeAreaH:Float = 0.5
    
    var position_Original: SCNVector3?
    var rotation_Original: SCNVector4?
    var rotation_OriginalX:CGFloat?
    var retweeted_Node:SCNNode?
    var index:Int?
    
    
    var model: HKWeiBoModel? {
        didSet{
            self.painter.model = model
            self.painter.senceNode = self
            if let url = model?.user?.profile_image_url{
                HKDownloader.loadImage(url: url, completion: { (ima) in
                    DispatchQueue.main.async {
                       self.painter.drawBegin(icon: ima)
                    }
                })
            }
        }
    }
    
    var contentImage:UIImage?{
        didSet{
            setUpMaterialImage(image: contentImage!, node: self,color: UIColor.white)
        }
    }
    //原创微博
    var originalImage:UIImage?{
        didSet{
            setUpMaterialImage(image: originalImage!, node: self,color: UIColor.white)
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
        let y:Float = nodeAreaH * 2 - (line * nodeAreaH)
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
            //转发的 微博
            
            if let url = model?.retweeted_status?.user?.profile_image_url{
                HKDownloader.loadImage(url: url, completion: { (ima) in
                    print(ima)
                    DispatchQueue.main.async {
                        let height = self.painter.retweete_H / self.painter.sizeH * self.MainSizeH + 0.1
                        let box = SCNBox(width: self.MainSizeW, height: height , length: self.MainSizeL, chamferRadius: self.MainRadius)
                        let nodeB = SCNNode(geometry: box)
                        self.retweeted_Node = nodeB
                        let a = boxNode.height*0.5
                        let b = height*0.5
                        let nodeB_Y =  -a-b-0.05
                        nodeB.position = SCNVector3Make(0,Float(nodeB_Y), 0)
                        self.addChildNode(nodeB)
                        self.painter.drawRetweeted(image: ima)
                    }
                })
            }
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
        self.retweeted_Node?.removeFromParentNode()
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
