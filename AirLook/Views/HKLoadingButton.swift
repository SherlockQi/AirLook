//
//  HKLoadingButton.swift
//  HKLoadButton
//
//  Created by HeiKki on 2018/1/15.
//  Copyright © 2018年 XiaQi. All rights reserved.
//

import UIKit

class HKLoadingButton: UIButton {
    
    var childLayers:[CALayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.isSelected{
            let top_Point = CGPoint(x: rect.size.width * 0.5, y:  rect.size.height * 0.1)
            let left_Point = CGPoint(x: rect.size.width * 0.2, y:  rect.size.height * 0.8)
            let right_Point = CGPoint(x: rect.size.width * 0.8, y:  rect.size.height * 0.8)
            
            move(starPoint: top_Point, endPoint: left_Point)
            move(starPoint: left_Point, endPoint: right_Point)
            move(starPoint: right_Point, endPoint: top_Point)
            move(starPoint: left_Point, endPoint: top_Point)
            move(starPoint: right_Point, endPoint: left_Point)
            move(starPoint: top_Point, endPoint: right_Point)
        }else{
            for l in self.childLayers {
                l.removeFromSuperlayer()
            }
        }
    }
    
    func move(starPoint:CGPoint , endPoint:CGPoint) {
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = 0.5
        bezierPath.move(to: starPoint)
        bezierPath.addLine(to: endPoint)
        
        UIColor.clear.set()
        bezierPath.stroke()
        let aniLayer = CALayer()
        aniLayer.backgroundColor = UIColor.white.cgColor
        aniLayer.position = starPoint
        aniLayer.bounds = CGRect(x: 0, y: 0, width: 4, height: 4)
        aniLayer.cornerRadius = 2
        self.layer.addSublayer(aniLayer)
        childLayers.append(aniLayer)
        
        let keyFrameAni = CAKeyframeAnimation(keyPath: "position")
        keyFrameAni.repeatCount = Float(NSIntegerMax)
        keyFrameAni.path = bezierPath.cgPath
        keyFrameAni.duration = 1.5
        keyFrameAni.beginTime = CACurrentMediaTime() + 0.5
        aniLayer.add(keyFrameAni, forKey: "keyFrameAnimation")
    }
}
