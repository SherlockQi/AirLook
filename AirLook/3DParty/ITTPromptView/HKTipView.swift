//
//  HKTipView.swift
//  AirLook
//
//  Created by HeiKki on 2018/1/15.
//  Copyright © 2018年 XiaQi. All rights reserved.
//

import UIKit

class HKTipView: UIView {

   class func tipView() ->HKTipView {
    let tipView:HKTipView = Bundle.main.loadNibNamed("HKTipView", owner: self, options: nil)?.first as! HKTipView
    tipView.layer.shadowColor = UIColor.black.cgColor
    tipView.layer.shadowOpacity = 0.8
    tipView.layer.shadowRadius = 4
    return tipView
    }
}
