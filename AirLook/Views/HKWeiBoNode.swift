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
    var index:Int?
    
    
    

  

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
        self.geometry = previewBox
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
